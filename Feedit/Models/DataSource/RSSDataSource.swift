//
//  RSSDataSource.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import FeedKit
import Combine
import BackgroundTasks
import CoreData
import Foundation
import FaviconFinder



//@objc(RSS)

class RSSDataSource: NSObject, DataSource, ObservableObject {
    
    var parentContext: NSManagedObjectContext
    
    var createContext: NSManagedObjectContext
    
    var updateContext: NSManagedObjectContext
    
    var fetchedResult: NSFetchedResultsController<RSS>
    
    var newObject: RSS?
    
    var updateObject: RSS?
    
    var markAllPostsRead: RSS?
    
    var filteredPosts: NSManagedObjectContext

    
    var isRead: Bool {
        return readDate != nil
    }
    
    var readDate: Date? {
        didSet {
            objectWillChange.send()
        }
    }

        
    required init(parentContext: NSManagedObjectContext) {
        self.parentContext = parentContext
        filteredPosts = parentContext.newChildContext()
        createContext = parentContext.newChildContext()
        updateContext = parentContext.newChildContext()
        
        let request = Model.fetchRequest() as NSFetchRequest<RSS>
        request.sortDescriptors = []
//            NSSortDescriptor(keyPath: \RSS.title, ascending: true)
        fetchedResult = .init(
            fetchRequest: request,
            managedObjectContext: parentContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
    }
}

extension RSSDataSource {
    func prepareNewObject() {
        guard newObject == nil else { return }
        newObject = RSS.create(in: createContext)
    }
}
