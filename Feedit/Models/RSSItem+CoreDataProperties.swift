//
//  RSSItem+CoreDataProperties.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import Foundation
import CoreData

extension RSSItem {
    static func == (lhs: RSSItem, rhs: RSSItem) -> Bool {
        return lhs.title == rhs.title && lhs.isArchive == rhs.isArchive && lhs.isRead == rhs.isRead
    }
}

extension RSSItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RSSItem> {
        return NSFetchRequest<RSSItem>(entityName: "RSSItem")
    }

    @NSManaged public var updateTime: Date?
    @NSManaged public var createTime: Date?
    @NSManaged public var desc: String
    @NSManaged public var progress: Double
    @NSManaged public var rssUUID: UUID?
    @NSManaged public var title: String
    @NSManaged public var url: String
    @NSManaged public var uuid: UUID?
    @NSManaged public var author: String
    @NSManaged public var isArchive: Bool
    @NSManaged public var isRead: Bool
    @NSManaged public var image: String
    @NSManaged public var order: Int32
    @NSManaged public var selected: Bool
//    @NSManaged public var attribute: RSS
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        uuid = UUID()
    }
    
    static func create(uuid: UUID, isRead: Bool, title: String = "", desc: String = "", image: String, author: String = "", url: String = "",
                       createTime: Date = Date(), progress: Double = 0, in context: NSManagedObjectContext) -> RSSItem {
        let item = RSSItem(context: context)
        item.rssUUID = uuid
        item.uuid = UUID()
        item.title = title
        item.desc = desc
        item.author = author
        item.url = url
        item.createTime = createTime
        item.progress = 0
        item.image = image
        item.isArchive = false
        item.isRead = false
        return item
    }
    
    static func requestObjects(rssUUID: UUID, start: Int = 0, limit: Int = 10) -> NSFetchRequest<RSSItem> {
        let request = RSSItem.fetchRequest() as NSFetchRequest<RSSItem>
        let predicate = NSPredicate(format: "rssUUID = %@", argumentArray: [rssUUID])
        request.predicate = predicate
        request.sortDescriptors = [.init(key: #keyPath(RSSItem.createTime), ascending: false)]
        request.fetchOffset = start
        request.fetchLimit = limit
        return request
    }
    
    static func requestArchiveObjects(start: Int = 0, limit: Int = 20) -> NSFetchRequest<RSSItem> {
        let request = RSSItem.fetchRequest() as NSFetchRequest<RSSItem>
        let predicate = NSPredicate(format: "isArchive = true")
        request.predicate = predicate
        request.sortDescriptors = [.init(key: #keyPath(RSSItem.updateTime), ascending: false)]
        request.fetchOffset = start
        request.fetchLimit = limit
        return request
    }
    
    static func requestCountArchiveObjects() -> NSFetchRequest<RSSItem> {
        let request = RSSItem.fetchRequest() as NSFetchRequest<RSSItem>
        let predicate = NSPredicate(format: "isArchive = true")
        request.predicate = predicate
        return request
    }
    
    static func requestUnreadObjects(start: Int = 0, limit: Int = 20) -> NSFetchRequest<RSSItem> {
        let request = RSSItem.fetchRequest() as NSFetchRequest<RSSItem>
        let predicate = NSPredicate(format: "isRead = true")
        request.predicate = predicate
        request.sortDescriptors = [.init(key: #keyPath(RSSItem.isRead), ascending: false)]
        request.fetchOffset = start
        request.fetchLimit = limit
        return request
    }
    
    static func requestCountUnreadObjects() -> NSFetchRequest<RSSItem> {
        let request = RSSItem.fetchRequest() as NSFetchRequest<RSSItem>
        let predicate = NSPredicate(format: "isRead = true")
        request.predicate = predicate
        return request
    }
    
    static func requestDefaultObjects() -> NSFetchRequest<RSSItem> {
        let request = RSSItem.fetchRequest() as NSFetchRequest<RSSItem>
        return request
    }
}

extension RSSItem: ObjectValidatable {
    func hasChangedValues() -> Bool {
        return hasPersistentChangedValues
    }
}
