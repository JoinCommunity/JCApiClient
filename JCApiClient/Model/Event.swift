//
//  Event.swift
//  JCApiClient
//
//  Created by Jose Lino Neto on 22/05/18.
//  Copyright © 2018 Jose Lino Neto. All rights reserved.
//

import Foundation

public struct Event : Codable {
    
    public var eventId: String
    public var name: String
    public var subject: String
    public var speaker: String
    public var room: String
    public var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case eventId = "_id"
        case name = "name"
        case subject = "subject"
        case speaker = "speaker"
        case room = "room"
        case createdAt = "createdAt"
    }
    
    //MARK: Local Api Service
    private static let service: ServiceApi = ServiceApi<Event>()
    
    public static func getAllEvents(completeCall: @escaping([Event]?) -> (), errorCall:@escaping(String) -> ()) {
        service.get(route: "", completeCall: { (returnData) in
            completeCall(returnData)
        }) { (errorMessage) in
            errorCall(errorMessage)
        }
    }
}
