//
//  RSSItemDataSource.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import CoreData
import Foundation
import SwiftUI

class RSSItemDataSource: NSObject, DataSource {
    
    var parentContext: NSManagedObjectContext
    
    var createContext: NSManagedObjectContext
    
    var updateContext: NSManagedObjectContext
    
    var fetchedResult: NSFetchedResultsController<RSSItem>
    
    var newObject: RSSItem?
    
    var updateObject: RSSItem?
        
    required init(parentContext: NSManagedObjectContext) {
        self.parentContext = parentContext
        createContext = parentContext.newChildContext()
        updateContext = parentContext.newChildContext()
        
        let request = Model.fetchRequest() as NSFetchRequest<RSSItem>
        request.sortDescriptors = []
        
        fetchedResult = .init(
            fetchRequest: request,
            managedObjectContext: parentContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        fetchedResult.delegate = self
    }
}

//extension RSSItemDataSource {
//    func simple() -> RSSItem? {
//        let item = RSSItem.init(context: createContext)
//        item.author = "Brent Simmons"
//        item.title = "Benefits of NetNewsWire's Threading Model"
//        item.desc = "In my previous post I describe how NetNewsWire handles threading, and I touch on some of the benefits — but I want to be more explicit about them."
//        item.url = "https://inessential.com/feed.json"
//        item.createTime = Date()
//        return item
//    }
//}
