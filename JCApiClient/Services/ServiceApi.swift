//
//  ServiceApi.swift
//  JCApiClient
//
//  Created by Jose Lino Neto on 22/05/18.
//  Copyright © 2018 Jose Lino Neto. All rights reserved.
//

import Foundation

public class ServiceApi<T: Codable> {
    
    private var urlapi: String = ""
    private var urlApi: String {
        get {
            if urlapi != "" {
                return urlapi
            }
            else {
                guard let url = Bundle.main.infoDictionary?["JOINCOMMUNITY_URL_API"] as? String else {
                    return urlapi
                }
                
                urlapi = url
                return urlapi
            }
        }
    }
    
    public init(){
        
    }
    
    public func get(route: String, completeCall: @escaping([T]?) -> (), errorCall: @escaping (String) -> ()) {
        let finalurl = self.urlApi + route
        if let url = URL(string: finalurl) {
            let session = URLSession(configuration: .default)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = session.dataTask(with: request) { (data, response, errorApi) in
                if let error = errorApi {
                    DispatchQueue.main.async {
                        errorCall(error.localizedDescription)
                    }
                }
                else if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        // https://bugs.swift.org/browse/SR-5823
                        // TODO: Remove all this strategy when referal bug on swift will be fixed.
                        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
                            let container = try decoder.singleValueContainer()
                            let dateStr = try container.decode(String.self)
                            
                            let formatter = DateFormatter()
                            formatter.calendar = Calendar(identifier: .iso8601)
                            formatter.locale = Locale(identifier: "en_US_POSIX")
                            formatter.timeZone = TimeZone(secondsFromGMT: 0)
                            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
                            if let date = formatter.date(from: dateStr) {
                                return date
                            }
                            
                            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
                            if let date = formatter.date(from: dateStr) {
                                return date
                            }
                            
                            return Date()
                        })
                        let object = try decoder.decode([T]?.self, from: data)
                        DispatchQueue.main.async {
                            completeCall(object)
                        }
                    }
                    catch {
                        DispatchQueue.main.async {
                            errorCall(error.localizedDescription)
                        }
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func post(route:String, entity: T, keyPath: String?, completeCall: @escaping (T?) -> (), errorCall: @escaping (String) -> ()) {
        
        let finalurl = self.urlApi + route
        if let url = URL(string: finalurl) {
            let session = URLSession(configuration: .default)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try? JSONEncoder().encode(entity)
            
            let task = session.dataTask(with: request) { (data, response, errorApi) in
                if let error = errorApi {
                    DispatchQueue.main.async {
                        errorCall(error.localizedDescription)
                    }
                }
                else if let data = data {
                    do {
                        let object = try JSONDecoder().decode(T.self, from: data)
                        DispatchQueue.main.async {
                            completeCall(object)
                        }
                        
                    }
                    catch {
                        DispatchQueue.main.async {
                            errorCall(error.localizedDescription)
                        }
                    }
                }
            }
            
            task.resume()
        }
    }
    
    //func getImage(urlString: String, fileName: String, completeCall: @escaping (UIImage?) -> (), errorCall: @escaping (String) -> ()) {
    func getImage(urlString: String, fileName: String) {
        let documentsDirectory = ServiceIO.getDocumentDirectoryUrl()
        let localFileName = documentsDirectory.appendingPathComponent(fileName)
        let fileManager = FileManager.default
        let testFileExist = fileManager.fileExists(atPath: localFileName.path)
        
        if (!testFileExist) {
            let imageURL = URL(string: urlString)
            if imageURL != nil {
                (URLSession(configuration: URLSessionConfiguration.default))
                    .dataTask(with: imageURL!, completionHandler: { (imageData, response, error) in
                        if error == nil {
                            if let data = imageData {
                                //let image : UIImage? = UIImage(data: data)
                                try? data.write(to: localFileName)
                                //completeCall(image)
                            }
                        }
                        else{
                            print(error!)
                            //errorCall(error!.localizedDescription)
                        }
                    }).resume()
            }
        }
    }
}
