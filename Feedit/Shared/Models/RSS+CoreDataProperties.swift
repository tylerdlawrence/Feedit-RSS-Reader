//
//  RSS+CoreDataProperties.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation
import CoreData
import FeedKit
import FaviconFinder
import Combine
import BackgroundTasks


extension RSS {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RSS> {
        return NSFetchRequest<RSS>(entityName: "RSS")
    }
    
    @nonobjc public class func fetchAllRequest() -> NSFetchRequest<RSSItem> {
        return NSFetchRequest<RSSItem>(entityName: "RSS")
    }

    @NSManaged public var urlString: String?
    @NSManaged public var url: String
    @NSManaged public var title: String
    @NSManaged public var desc: String
    @NSManaged public var createTime: Date?
    @NSManaged public var updateTime: Date?
    @NSManaged public var lastFetchTime: Date?
    @NSManaged public var uuid: UUID?
    @NSManaged public var image: String
    @NSManaged public var isFetched: Bool
    @NSManaged public var isArchive: Bool
    @NSManaged public var isRead: Bool
    @NSManaged public var readDate : Date?
    
    @NSManaged public var item: RSSItem
    @NSManaged public var groups: NSSet?
    @NSManaged public var itemCount: Int64
    @NSManaged public var children: String
    
    @NSManaged public var articles: NSSet?
    
    public var rssURL: URL? {
        return URL(string: url)
    }
    
    
    
    
    public var createTimeStr: String {
        return "\(self.createTime?.string() ?? "")"
    }

    static func create(url: String = "", title: String = "", desc: String = "", image: String = "", in context: NSManagedObjectContext) -> RSS {
        let rss = RSS(context: context)
        rss.title = title
        rss.desc = desc
        rss.url = url
        rss.image = image
        rss.uuid = UUID()
        rss.createTime = Date()
        rss.updateTime = Date()
        rss.isFetched = false
        return rss
    }

    static func simple() -> RSS {
        let rss = RSS(context: Persistence.current.context)
        rss.title = "demo"
        rss.image = ""
        rss.desc = "desc demo"
        rss.url = "http://images.apple.com/main/rss/hotnews/hotnews.rss"
        return rss
    }
    
    static func requestFolderObjects() -> NSFetchRequest<RSS> {
        let request = RSS.fetchRequest() as NSFetchRequest<RSS>
        request.predicate = .init(value: true)
        request.sortDescriptors = [.init(key: #keyPath(RSS.groups), ascending: true)]
        return request
    }

    static func requestObjects() -> NSFetchRequest<RSS> {
        let request = RSS.fetchRequest() as NSFetchRequest<RSS>
        request.predicate = .init(value: true)
        request.sortDescriptors = [.init(key: #keyPath(RSS.title), ascending: true)]
        return request
    }

    static func requestStarredObjects() -> NSFetchRequest<RSS> {
        let request = RSS.fetchRequest() as NSFetchRequest<RSS>
        request.predicate = .init(value: true)
        request.sortDescriptors = [.init(key: #keyPath(RSS.isArchive), ascending: true)]
        return request
    }
    
    static func requestUnreadObjects(start: Int = 0) -> NSFetchRequest<RSS> {
        let request = RSS.fetchRequest() as NSFetchRequest<RSS>
        request.predicate = .init(value: true)
        request.sortDescriptors = [.init(key: #keyPath(RSS.isRead), ascending: true)]
        return request
    }

    static func requestDefaultObjects() -> NSFetchRequest<RSS> {
        let request = RSS.fetchRequest() as NSFetchRequest<RSS>
        return request
    }
}

extension RSS {
    static func == (lhs: RSS, rhs: RSS) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

extension RSS {
    func update(from feed: Feed) {
        let rss = self
        switch feed {
        case .atom(let atomFeed):
            rss.title = atomFeed.title ?? ""
        case .json(let jsonFeed):
            rss.title = jsonFeed.title ?? ""
            rss.desc = jsonFeed.description?.trimWhiteAndSpace ?? ""
        case .rss(let rssFeed):
            rss.title = rssFeed.title ?? ""
            rss.desc = rssFeed.description?.trimWhiteAndSpace ?? ""
        }
    }
}

extension RSS: ObjectValidatable {
    func hasChangedValues() -> Bool {
        return hasPersistentChangedValues
    }
}
