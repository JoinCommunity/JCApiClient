//
//  Event.swift
//  JCApiClient
//
//  Created by Jose Lino Neto on 22/05/18.
//  Copyright © 2018 Jose Lino Neto. All rights reserved.
//

import Foundation
import CoreData

public struct Event : Codable {
    
    public var eventId: String?
    public var name: String?
    public var subject: String?
    public var speaker: String?
    public var room: String?
    public var schedule: String?
    public var asset: String?
    
    enum CodingKeys: String, CodingKey {
        case eventId = "_id"
        case name = "name"
        case subject = "subject"
        case speaker = "speaker"
        case room = "room"
        case schedule = "schedule"
        case asset = "asset"
    }
    
    //MARK: Local Api Service
    private static let service: ServiceApi = ServiceApi<Event>()
    
    public static func searchEvents(terms: String, completeCall:@escaping([Event]?) ->(), errorCall:@escaping(String) -> ()) {
        do {
            let context : NSManagedObjectContext = ServiceCoreData.viewContext
            let request : NSFetchRequest<LocalEvent> = LocalEvent.fetchRequest()
            let predicate : NSPredicate = NSPredicate(format: "name contains[cd] %@ OR speaker contains[cd] %@ OR room contains[cd] %@", terms, terms, terms)
            request.predicate = predicate
            
            let results = try context.fetch(request)
            let returnData : NSMutableArray = []
            for item in results {
                let event = Event(eventId: item.eventId, name: item.name, subject: item.subject, speaker: item.speaker, room: item.room, schedule: item.schedule, asset: item.asset)
                returnData.add(event)
            }
            
            let returnArray = returnData.copy() as? [Event]
            completeCall(returnArray)
        } catch {
            print(error.localizedDescription)
            errorCall(error.localizedDescription)
        }
    }
    
    public static func getAllEvents(completeCall: @escaping([Event]?) -> (), errorCall:@escaping(String) -> ()) {
        // get remote data
        service.get(route: "event", completeCall: { (returnData) in
            if let array = returnData {
                
                // Remove local cache
                self.clear()
                
                // For each result include locally
                for item in array {
                    item.save()
                }
            }
            
            // Complete call block
            completeCall(returnData)
        }) { (errorMessage) in
            errorCall(errorMessage)
        }
    }
    
    public static func getAllLocalEvents() -> [Event]? {
        do {
            let context : NSManagedObjectContext = ServiceCoreData.viewContext
            let request : NSFetchRequest<LocalEvent> = LocalEvent.fetchRequest()
            
            let results = try context.fetch(request)
            let returnData : NSMutableArray = []
            for item in results {
                let event = Event(eventId: item.eventId, name: item.name, subject: item.subject, speaker: item.speaker, room: item.room, schedule: item.schedule, asset: item.asset)
                returnData.add(event)
            }
            
            return returnData.copy() as? [Event]
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    public func save() {
        do {
            let context : NSManagedObjectContext = ServiceCoreData.viewContext
            let localEvent = LocalEvent(context: context)

            localEvent.eventId = self.eventId
            localEvent.name = self.name
            localEvent.room = self.room
            localEvent.speaker = self.speaker
            localEvent.subject = self.subject

            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    private static func clear() {
        let context : NSManagedObjectContext = ServiceCoreData.viewContext
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: LocalEvent.fetchRequest())

        let _ = try? context.execute(batchDeleteRequest)
    }
}
