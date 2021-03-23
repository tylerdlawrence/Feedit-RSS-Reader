//
//  RSSDataSource.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import CoreData

class RSSDataSource: NSObject, DataSource, Identifiable {
    
    var parentContext: NSManagedObjectContext
    
    var createContext: NSManagedObjectContext
    
    var updateContext: NSManagedObjectContext
    
    var fetchedResult: NSFetchedResultsController<RSS>
    
    var newObject: RSS?
    
    var updateObject: RSS?
    
    required init(parentContext: NSManagedObjectContext) {
        self.parentContext = parentContext
        createContext = parentContext.newChildContext()
        updateContext = parentContext.newChildContext()
        
        let request = Model.fetchRequest() as NSFetchRequest<RSS>
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

extension RSSDataSource {
    func prepareNewObject() {
        guard newObject == nil else { return }
        newObject = RSS.create(in: createContext)
    }
}

//extension RSSDataSource {
//    func simple() -> RSS? {
//        let rss = RSS.init(context: createContext)
//        rss.title = "Lorem ipsum dolor"
//        rss.image = "getInfo"
//        return rss
//    }
//}
