//
//  RSS+CoreDataClass.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation
import CoreData
import SwiftUI
import FeedKit
import FaviconFinder
import Combine
import BackgroundTasks

@objc(RSS)
class RSS: NSManagedObject, Identifiable {
        
    //MARK: Helpers
    
    class func count() -> Int {
        
        let context = CoreData.stack.context
        
        let fetchRequest: NSFetchRequest<RSS> = RSS.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            return count
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    class func nextOrderFor(item: RSS) -> Int {
        
        let keyPathExpression = NSExpression.init(forKeyPath: "order")
        let maxNumberExpression = NSExpression.init(forFunction: "max:", arguments: [keyPathExpression])
        
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "maxNumber"
        expressionDescription.expression = maxNumberExpression
        expressionDescription.expressionResultType = .decimalAttributeType
        
        var expressionDescriptions = [AnyObject]()
        expressionDescriptions.append(expressionDescription)
        
        let predicate = NSPredicate(format: "item == %@", item)
        
        // Build out our fetch request the usual way
        let request: NSFetchRequest<NSFetchRequestResult> = RSS.fetchRequest()
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = expressionDescriptions
        request.predicate = predicate
        
        // Our result should to be an array of dictionaries.
        var results: [[String:AnyObject]]?
        
        do {
            results = try CoreData.stack.context.fetch(request) as? [[String:NSNumber]]
            
            if let maxNumber = results?.first!["maxNumber"]  {
                // Return one more than the current max order
                return maxNumber.intValue + 1
            } else {
                // If no items present, return 0
                return 0
            }
        } catch _ {
            // If any failure, just return default
            return 0
        }
    }
    
    class func allInOrder() -> [RSS] {
        
        let dataSource = CoreDataDataSource<RSS>(sortKey1: "item.order",
                                                       sortKey2: "order",
                                                       sectionNameKeyPath: "item.name")
        let objects = dataSource.fetch()
        return objects
    }
    
    #if DEBUG
    class func preview() -> RSS {
        
        let attributes =  RSS.allInOrder()
        if attributes.count > 0 {
            return attributes.first!
        } else {
            let item = RSSItem.createItem(title: "Item Preview", order: 999)
            return RSS.createAttributeFor(item: item, title: "Attribute Preview", order: 999)
        }
    }
    #endif
    
    //MARK: CRUD
    
    class func newAttribute() -> RSS {
        
        return RSS(context: CoreData.stack.context)
    }
    
    class func createAttributeFor(item: RSSItem, title: String, order: Int?) -> RSS {
        
        let attribute = RSS.newAttribute()
        attribute.title = title
        attribute.order = Int32(order ?? 0)
        attribute.item = item
        CoreData.stack.save()
        return attribute
    }
    
    public func update(title: String, order: String) {
        
        self.title = title
        self.order = Int32(order)!
        CoreData.stack.save()
    }
    
    public func delete() {
        
        CoreData.stack.context.delete(self)
    }
    
}

extension Sequence {
    func sum<T: Numeric>(for keyPath: KeyPath<Element, T>) -> T {
        return reduce(0) { sum, element in
            sum + element[keyPath: keyPath]
        }
    }
}
