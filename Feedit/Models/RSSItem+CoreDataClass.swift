//
//  RSSItem+CoreDataClass.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//


import SwiftUI
import FeedKit
import FaviconFinder
import Combine
import Foundation
import CoreData
import BackgroundTasks

@objc(RSSItem)
public class RSSItem: NSManagedObject, Identifiable {
    
    //MARK: Helpers
    
    class func count() -> Int {
        
        let fetchRequest: NSFetchRequest<RSSItem> = RSSItem.fetchRequest()
        
        do {
            let count = try CoreData.stack.context.count(for: fetchRequest)
            return count
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    class func nextOrder() -> Int {
        
        let keyPathExpression = NSExpression.init(forKeyPath: "order")
        let maxNumberExpression = NSExpression.init(forFunction: "max:", arguments: [keyPathExpression])
        
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "maxNumber"
        expressionDescription.expression = maxNumberExpression
        expressionDescription.expressionResultType = .decimalAttributeType
        
        var expressionDescriptions = [AnyObject]()
        expressionDescriptions.append(expressionDescription)
        
        // Build out our fetch request the usual way
        let request: NSFetchRequest<NSFetchRequestResult> = RSSItem.fetchRequest()
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = expressionDescriptions
        request.predicate = nil
        
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
    
    class func allInOrder() -> [RSSItem] {
        
        let datasource = CoreDataDataSource<RSSItem>()
        return datasource.fetch()
    }

    #if DEBUG
    class func preview() -> RSSItem {
        
        let items = RSSItem.allInOrder()
        if items.count > 0 {
            return items.first!
        } else {
            return RSSItem.createItem(title: "Item Preview", order: 999)
        }
    }
    #endif
    
    class func allSelectedItems() -> [RSSItem] {
        
        let predicate = NSPredicate(format:"selected = true")
        let datasource = CoreDataDataSource<RSSItem>(predicate: predicate)
        return datasource.fetch()
    }
    
    //MARK: CRUD
    
    class func newItem() -> RSSItem {
        
        return RSSItem(context: CoreData.stack.context)
    }
    
    class func createItem(title: String, order: Int?) -> RSSItem {
        
        let item = RSSItem.newItem()
        item.title = title
        item.order = Int32(order ?? 0)
        CoreData.stack.save()
        
        return item
    }
    
    public func update(title: String, order: String) {
        
        self.title = title
        self.order = Int32(order)!
        CoreData.stack.save()
    }
    
    public func update(selected: Bool, commit: Bool) {
        
        self.selected = selected
        CoreData.stack.save()
    }
    
    public func delete() {
        
        CoreData.stack.context.delete(self)
    }
    
}

