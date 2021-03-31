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
//        let item = RSSItem.init()
//        item.title = "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
//        item.desc = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque ultrices sed nulla nec blandit. Suspendisse in facilisis velit. Donec vitae ligula ut purus fermentum sodales a ac urna. Morbi pellentesque justo tortor, nec placerat nunc tempus vitae. Curabitur vehicula volutpat massa, eget commodo nisl ultricies ac. Etiam in tempor nulla. Pellentesque pellentesque, odio in bibendum luctus, urna mauris ullamcorper elit, sed semper purus orci vitae dolor. Sed condimentum sem nisi, eu venenatis libero suscipit vel. Mauris arcu orci, luctus vitae augue a, ultricies congue mi. Praesent malesuada a sem interdum rhoncus. Nulla a facilisis neque, ac rutrum lacus. Fusce sit amet eleifend odio, quis cursus massa. Vestibulum sodales tempus lectus, non fermentum justo auctor a. Donec quis augue ornare, faucibus nibh id, posuere urna. Ut orci urna, semper id ex condimentum, gravida euismod neque. Suspendisse tincidunt nisi a odio molestie porta. Quisque dui libero, vehicula maximus sapien quis, ullamcorper feugiat nibh. Cras odio elit, ullamcorper at erat nec, tincidunt porta turpis. Morbi cursus ligula quis sapien semper tincidunt. Vestibulum blandit libero libero, non aliquam ante porttitor ac. Praesent lorem ex, ultrices nec neque ut, ultricies ultricies libero. Sed tempus ante id sapien luctus, a efficitur felis posuere. Integer id eros quam. Mauris finibus urna nec vestibulum lobortis. Vivamus vel egestas erat, in facilisis urna. Curabitur vitae nisi orci. Sed sed dui faucibus, dignissim nulla in, vulputate neque. Morbi maximus nunc eget lacus consequat egestas."
//        item.createTime = Date()
//        item.author = "tyler d lawrence"
//        item.url = "https://www.google.com"
//        item.image = "data:image/png;base64,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"
//        return item
//    }
//}
//
//extension RSSItemDataSource {
//    var settingRowPreview: RSSItem? {
//        let feed = RSSItem.init()
//        feed.title = "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
//        feed.desc = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque ultrices sed nulla nec blandit. Suspendisse in facilisis velit. Donec vitae ligula ut purus fermentum sodales a ac urna. Morbi pellentesque justo tortor, nec placerat nunc tempus vitae. Curabitur vehicula volutpat massa, eget commodo nisl ultricies ac. Etiam in tempor nulla. Pellentesque pellentesque, odio in bibendum luctus, urna mauris ullamcorper elit, sed semper purus orci vitae dolor. Sed condimentum sem nisi, eu venenatis libero suscipit vel. Mauris arcu orci, luctus vitae augue a, ultricies congue mi. Praesent malesuada a sem interdum rhoncus. Nulla a facilisis neque, ac rutrum lacus. Fusce sit amet eleifend odio, quis cursus massa. Vestibulum sodales tempus lectus, non fermentum justo auctor a. Donec quis augue ornare, faucibus nibh id, posuere urna. Ut orci urna, semper id ex condimentum, gravida euismod neque. Suspendisse tincidunt nisi a odio molestie porta. Quisque dui libero, vehicula maximus sapien quis, ullamcorper feugiat nibh. Cras odio elit, ullamcorper at erat nec, tincidunt porta turpis. Morbi cursus ligula quis sapien semper tincidunt. Vestibulum blandit libero libero, non aliquam ante porttitor ac. Praesent lorem ex, ultrices nec neque ut, ultricies ultricies libero. Sed tempus ante id sapien luctus, a efficitur felis posuere. Integer id eros quam. Mauris finibus urna nec vestibulum lobortis. Vivamus vel egestas erat, in facilisis urna. Curabitur vitae nisi orci. Sed sed dui faucibus, dignissim nulla in, vulputate neque. Morbi maximus nunc eget lacus consequat egestas."
//        feed.createTime = Date()
//        feed.author = "tyler d lawrence"
//        feed.url = "https://www.google.com"
//        feed.image = "data:image/png;base64,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"
//        return feed
//    }
//}
