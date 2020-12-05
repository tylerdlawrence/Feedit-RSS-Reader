//
//  RSS+CoreDataProperties.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation
import CoreData
import FeedKit


extension RSS {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RSS> {
          
        return NSFetchRequest<RSS>(entityName: "RSS")
    }

    @NSManaged public var author: String?
    @NSManaged public var urlString: String?
    @NSManaged public var imageURL: String
    @NSManaged public var url: String
    @NSManaged public var title: String
    @NSManaged public var desc: String
    @NSManaged public var createTime: Date!
    @NSManaged public var updateTime: Date!
    @NSManaged public var lastFetchTime: Date?
    @NSManaged public var uuid: UUID?
    @NSManaged public var image: String
    @NSManaged public var isFetched: Bool
    
    @NSManaged public var name: String
    @NSManaged public var order: Int32
    @NSManaged public var selected: Bool
    //@NSManaged public var attribute: Attribute
    
    public var rssURL: URL? {
        return URL(string: url)
    }
    
    public var createTimeStr: String {
        return "\(self.createTime?.string() ?? "")"
    }
    
    static func create(url: String = "", title: String = "", desc: String = "", imageURL: String = "", in context: NSManagedObjectContext) -> RSS {
        let rss = RSS(context: context)
        rss.title = title
        rss.desc = desc
        rss.url = url
        rss.imageURL = imageURL
        rss.uuid = UUID()
        rss.createTime = Date()
        rss.updateTime = Date()
        rss.isFetched = false
        return rss
    }
    
    static func simple(imageURL: String = "") -> RSS {
        let rss = RSS(context: Persistence.current.context)
        rss.image = "f"
        rss.title = "Daring Fireball"
        rss.desc = "description of RSS feed"
        rss.url = "https://daringfireball.net/feeds/main"
        return rss
    }
    
    static func requestObjects() -> NSFetchRequest<RSS> {
        let request = RSS.fetchRequest() as NSFetchRequest<RSS>
        request.predicate = .init(value: true)
        request.sortDescriptors = [.init(key: #keyPath(RSS.createTime), ascending: false)]
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

