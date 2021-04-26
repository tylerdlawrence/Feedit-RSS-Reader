//
//  RSSItem+CoreDataProperties.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import Foundation
import CoreData
import FeedKit
import FaviconFinder
import Combine
import BackgroundTasks

extension RSSItem: Identifiable {
    
}

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
    @NSManaged public var image: String?
    @NSManaged public var thumbnailURL: URL?
    @NSManaged public var unread: Bool
    @NSManaged public var itemCount: Int64
    
    @NSManaged public var imageUrl: String?
    
    @NSManaged public var unreadArticles: [RSSItem]
    @NSManaged public var starredArticles: [RSSItem]
    @NSManaged public var todayArticles: [RSSItem]
//    let unreadArticles: [LatestArticle]
//    let starredArticles: [LatestArticle]
//    let todayArticles: [LatestArticle]
        
    @NSManaged public var readDate: Date?
    
    @NSManaged public var avatar: String?
    @NSManaged public var next_url: String?
    @NSManaged public var icon: String?
    @NSManaged public var favicon: String?
    @NSManaged public var home_page_url: String?
    
    @NSManaged public var external_url: String?
    @NSManaged public var content_text: String?
    @NSManaged public var content_html: String?
    @NSManaged public var summary: String?
    @NSManaged public var banner_image: String?
    @NSManaged public var date_published: Date?
    @NSManaged public var date_modified: Date?
    @NSManaged public var tags: String?
    @NSManaged public var attachments: String?
        
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        uuid = UUID()
    }
    
    static func create(uuid: UUID, title: String, desc: String = "", author: String, url: String, createTime: Date = Date(), image: String = "", progress: Double = 0, in context: NSManagedObjectContext) -> RSSItem {
        let item = RSSItem(context: context)
        item.rssUUID = uuid
        item.uuid = UUID()
        item.title = title
        item.desc = desc
        item.author = author
        item.url = url
        item.createTime = createTime
        item.image = image
        
        item.progress = 0
        item.isArchive = false
        item.isRead = false
        return item
    }
        
    static func requestObjects(rssUUID: UUID, start: Int = 0) -> NSFetchRequest<RSSItem> {
        let request = RSSItem.fetchRequest() as NSFetchRequest<RSSItem>
        let predicate = NSPredicate(format: "rssUUID = %@", argumentArray: [rssUUID])
        request.predicate = predicate
        request.sortDescriptors = [.init(key: #keyPath(RSSItem.createTime), ascending: false)]

        request.fetchOffset = start
        return request
    }
    static func requestCountObjects(start: Int = 0, limit: Int = 5000) -> NSFetchRequest<RSSItem> {
        let request = RSSItem.fetchRequest() as NSFetchRequest<RSSItem>
        let predicate = NSPredicate(format: "rssUUID = %@")
        request.predicate = predicate
        request.fetchOffset = start
        request.fetchLimit = limit
        return request
    }
    static func requestDefaultObjects() -> NSFetchRequest<RSSItem> {
        let request = RSSItem.fetchRequest() as NSFetchRequest<RSSItem>
        return request
    }
    
    //MARK: STARRED
    static func requestArchiveObjects(start: Int = 0, limit: Int = 10000) -> NSFetchRequest<RSSItem> {
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
    
    //MARK: ALL ARTICLES
    static func requestAllObjects(start: Int = 0, limit: Int = 10000) -> NSFetchRequest<RSSItem> {
        let request = RSSItem.fetchRequest() as NSFetchRequest<RSSItem>
        request.sortDescriptors = [.init(key: #keyPath(RSSItem.createTime), ascending: false)]
        request.fetchOffset = start
        request.fetchLimit = limit
        return request
    }
    static func requestCountAllObjects(start: Int = 0) -> NSFetchRequest<RSSItem> {
        let request = RSSItem.fetchRequest() as NSFetchRequest<RSSItem>
        request.fetchOffset = start
        return request
    }
    
    //MARK: UNREAD
    static func requestUnreadObjects(start: Int = 0, limit: Int = 10000) -> NSFetchRequest<RSSItem> {
        let request = RSSItem.fetchRequest() as NSFetchRequest<RSSItem>
        let predicate = NSPredicate(format: "isRead = false")
        request.predicate = predicate
        request.sortDescriptors = [.init(key: #keyPath(RSSItem.createTime), ascending: false)]
        request.fetchOffset = start
        request.fetchLimit = limit
        return request
    }
    static func requestCountUnreadObjects(start: Int = 0) -> NSFetchRequest<RSSItem> {
        let request = RSSItem.fetchRequest() as NSFetchRequest<RSSItem>
        let predicate = NSPredicate(format: "isRead = false")
        request.predicate = predicate
        request.fetchOffset = start
        return request
    }
}

extension RSSItem: ObjectValidatable {
    func hasChangedValues() -> Bool {
        return hasPersistentChangedValues
    }
}
