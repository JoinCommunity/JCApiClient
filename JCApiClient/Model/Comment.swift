//
//  Comment.swift
//  JCApiClient
//
//  Created by Jose Lino Neto on 25/05/18.
//  Copyright © 2018 Jose Lino Neto. All rights reserved.
//

import Foundation

public struct Comment : Codable {
    
    public var commentId: String?
    public var author: String?
    public var eventId: String?
    public var comment: String?
    public var rate: Int?
    public var createdAt : Date?
    
    enum CodingKeys: String, CodingKey {
        case commentId = "_id"
        case author = "author"
        case eventId = "_event"
        case comment = "comment"
        case rate = "rate"
        case createdAt = "createAt"
    }
    
    //MARK: Local Api Service
    private static let service: ServiceApi = ServiceApi<Comment>()
    
    public static func getCommentsFromEvent(event: Event?, completeCall: @escaping([Comment]?) -> (), errorCall:@escaping(String) -> ()) {
        // get remote data
        let route = "comment/\(event?.eventId ?? "")"
        service.get(route: route, completeCall: { (returnData) in
            // Complete call block
            let sorted : [Comment]? = returnData?.sorted(by: { (first, second) -> Bool in
                guard let firstDate = first.createdAt else {
                    return false
                }
                
                guard let secondDate = second.createdAt else {
                    return false
                }
                
                return firstDate > secondDate
            })
            completeCall(sorted)
        }) { (errorMessage) in
            errorCall(errorMessage)
        }
    }
    
    public func createComment() {
        
    }
}
