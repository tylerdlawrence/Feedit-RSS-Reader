//
//  RSSItemDataSource.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import CoreData
import Foundation

class RSSItemDataSource: NSObject, DataSource, NSFetchedResultsControllerDelegate {
    
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

extension RSSItemDataSource {
    func simple() -> RSSItem? {
        let item = RSSItem.init(context: createContext)
        item.url = "https://github.blog/feed"
        item.image = "launch"
        return item
    }
}
