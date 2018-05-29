//
//  ServiceIO.swift
//  JCApiClient
//
//  Created by Jose Lino Neto on 29/05/18.
//  Copyright © 2018 Jose Lino Neto. All rights reserved.
//

import Foundation

public class ServiceIO {
    public class func getDocumentDirectoryUrl() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    public class func fileExist(name: String?) -> Bool {
        if let name = name {
            let documentsDirectory = getDocumentDirectoryUrl()
            let fileName = documentsDirectory.appendingPathComponent(name)
            let fileManager = FileManager.default
            let testFileExist = fileManager.fileExists(atPath: fileName.path)
            
            return testFileExist
        }
        else{
            return false
        }
    }
    
    public class func getFileData(name: String?) -> Data? {
        if fileExist(name: name) {
            let fileName = getDocumentDirectoryUrl().appendingPathComponent(name!)
            let data : Data? = try? Data(contentsOf: fileName)
            return data
        }
        else {
            return nil
        }
    }
}

