//
//  RSSItem+CoreDataProperties.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import Foundation
import CoreData

extension RSSItem: Identifiable {
    
}

extension RSSItem {
    static func == (lhs: RSSItem, rhs: RSSItem) -> Bool {
        return lhs.title == rhs.title && lhs.isArchive == rhs.isArchive
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
    @NSManaged public var imageURL: String
    //@NSManaged public var isDone: Bool
    @NSManaged public var isRead: Bool
    @NSManaged public var isStarred: Bool
    @NSManaged public var isSwiped: Bool
    @NSManaged public var offset: CGFloat
    @NSManaged public var status: String
    @NSManaged public var useReadText: Bool

    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        uuid = UUID()
    }
    
    static func create(uuid: UUID, isDone: Bool, isRead: Bool, imageURL: String, title: String = "", desc: String = "", author: String = "", url: String = "",
                       createTime: Date = Date(), progress: Double = 0, in context: NSManagedObjectContext) -> RSSItem {
        let item = RSSItem(context: context)
        item.rssUUID = uuid
        item.uuid = UUID()
        item.imageURL = imageURL
        item.title = title
        item.desc = desc
        item.author = author
        item.url = url
        item.createTime = createTime
        item.progress = 0
        item.isArchive = false
        //item.isDone = false
        item.isRead = false
        item.isStarred = false
        item.useReadText = false
        

        return item
    }
    
    enum Status: String {
        case read = "Read"
        case unread = "Unread"
        case remove = "Remove"
    }
    
    var readStatus: Status {
        set {
            status = newValue.rawValue
        }
        get {
            Status(rawValue: status) ?? .read
        }
    }
    
    var wrappedTitle: String {
        title 
    }

    var wrappedDTitle: String {
        title 
    }
        
    static func requestObjects(rssUUID: UUID, start: Int = 0, limit: Int = 20) -> NSFetchRequest<RSSItem> {
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
    
    func requestCountArchiveObjects() -> NSFetchRequest<RSSItem> {
            let request = RSSItem.fetchRequest() as NSFetchRequest<RSSItem>
            let predicate = NSPredicate(format: "isArchive = true")
            request.predicate = predicate
            return request
        }
    
    static func requestRSSReadObjects(start: Int = 0, limit: Int = 20) -> NSFetchRequest<RSSItem> {
        let request = RSSItem.fetchRequest() as NSFetchRequest<RSSItem>
        let predicate = NSPredicate(format: "isRead = false")
        request.predicate = predicate
        request.sortDescriptors = [.init(key: #keyPath(RSSItem.updateTime), ascending: false)]
        request.fetchOffset = start
        request.fetchLimit = limit
        return request
    }
    
    func requestCountRSSObjects() -> NSFetchRequest<RSSItem> {
            let request = RSSItem.fetchRequest() as NSFetchRequest<RSSItem>
            let predicate = NSPredicate(format: "isRead = false")
            request.predicate = predicate
            return request
        }

    static func requestDefaultObjects() -> NSFetchRequest<RSSItem> {
        let request = RSSItem.fetchRequest() as NSFetchRequest<RSSItem>
        return request
        }
    }

class Model: ObservableObject {
    @Published var feed: RSSItem?
    @Published var error: IdentifiableError?
    @Published var isReadStatuses: [URL: Bool]
    
    var task: URLSessionDataTask?
    init() {
        self.isReadStatuses = UserDefaults.standard.data(forKey: "isReadStatuses")
            .flatMap { try? JSONDecoder().decode([URL: Bool].self, from: $0) } ?? [:]
        //reload()
    }
    
    func setIsRead(_ value: Bool, url: URL) {
        var statuses = isReadStatuses
        statuses[url] = value
        isReadStatuses = statuses
        UserDefaults.standard.set(try? JSONEncoder().encode(isReadStatuses), forKey: "isReadStatuses")
    }
}


extension RSSItem: ObjectValidatable {
    func hasChangedValues() -> Bool {
        return hasPersistentChangedValues
    }
}

public struct IdentifiableError: Error, Identifiable {
    public let underlying: Error
    public init(underlying: Error) {
        self.underlying = underlying
    }
    
    public var id: String {
        localizedDescription
    }
    
    public var localizedDescription: String {
        underlying.localizedDescription
    }
}
