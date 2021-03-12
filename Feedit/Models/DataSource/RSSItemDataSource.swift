//
//  RSSItemDataSource.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import CoreData

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

extension RSSItemDataSource {
    func simple() -> RSSItem? {
        let item = RSSItem.init(context: createContext)
        item.title = "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
        item.desc = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque ultrices sed nulla nec blandit. Suspendisse in facilisis velit. Donec vitae ligula ut purus fermentum sodales a ac urna. Morbi pellentesque justo tortor, nec placerat nunc tempus vitae. Curabitur vehicula volutpat massa, eget commodo nisl ultricies ac. Etiam in tempor nulla. Pellentesque pellentesque, odio in bibendum luctus, urna mauris ullamcorper elit, sed semper purus orci vitae dolor. Sed condimentum sem nisi, eu venenatis libero suscipit vel. Mauris arcu orci, luctus vitae augue a, ultricies congue mi. Praesent malesuada a sem interdum rhoncus. Nulla a facilisis neque, ac rutrum lacus. Fusce sit amet eleifend odio, quis cursus massa. Vestibulum sodales tempus lectus, non fermentum justo auctor a. Donec quis augue ornare, faucibus nibh id, posuere urna. Ut orci urna, semper id ex condimentum, gravida euismod neque. Suspendisse tincidunt nisi a odio molestie porta. Quisque dui libero, vehicula maximus sapien quis, ullamcorper feugiat nibh. Cras odio elit, ullamcorper at erat nec, tincidunt porta turpis. Morbi cursus ligula quis sapien semper tincidunt. Vestibulum blandit libero libero, non aliquam ante porttitor ac. Praesent lorem ex, ultrices nec neque ut, ultricies ultricies libero. Sed tempus ante id sapien luctus, a efficitur felis posuere. Integer id eros quam. Mauris finibus urna nec vestibulum lobortis. Vivamus vel egestas erat, in facilisis urna. Curabitur vitae nisi orci. Sed sed dui faucibus, dignissim nulla in, vulputate neque. Morbi maximus nunc eget lacus consequat egestas."
        item.createTime = Date()
        item.author = "tyler d lawrence"
        item.url = "https://www.google.com"
        return item
    }
}
