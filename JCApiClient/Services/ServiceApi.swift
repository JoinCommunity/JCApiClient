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
                        let object = try JSONDecoder().decode([T]?.self, from: data)
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
}
