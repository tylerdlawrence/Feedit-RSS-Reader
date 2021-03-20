//
//  RSSStore.swift
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

class RSSStore: NSObject, ObservableObject {
    @Published var feeds: [RSSItem] = []
    @Published var shouldSelectFeedURL: String?
    @Published var shouldOpenSettings: Bool = false
    @Published var notificationsEnabled: Bool = false
    @Published var fetchContentTime: String = ContentTimeType.minute60.rawValue
    @Published var fetchContentType: ContentTimeType = .minute60
    @Published var totalUnreadPosts: Int = 0
    @Published var totalReadPostsToday: Int = 0

    static let instance = RSSStore()
    private let persistence = Persistence.current
    
    private lazy var fetchedResultsController: NSFetchedResultsController<RSS> = {
        let fetchRequest: NSFetchRequest<RSS> = RSS.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createTime", ascending: false)]

        let fetechedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: persistence.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetechedResultsController.delegate = self
        return fetechedResultsController
    }()
    
//    func markAllPostsRead(start: Int = 0, _ item: RSSItem) {
//        self.markAllPostsRead(item)
//        shouldReload = true
//    }
    
    var isRead: Bool {
        return readDate != nil
    }
    
    var readDate: Date? {
        didSet {
            objectWillChange.send()
        }
    }
    
    func setPostRead(rss: RSS, item: RSSItem) {
        rss.readDate = Date()
        item.objectWillChange.send()
        
        if let index = self.rssSources.firstIndex(where: {$0.url == rss.url}) {
            self.feeds.remove(at: index)
            self.feeds.insert(item, at: index)
            
        }
    }
    
//    func setPostRead(rss: RSS, item: RSSItem) {
//        rss.readDate = Date()
//        rss.objectWillChange.send()
//        totalUnreadPosts -= 1
//        totalReadPostsToday += 1
//        if let index = feed.posts.firstIndex(where: {$0.url.absoluteString == post.url.absoluteString}) {
//            feed.posts.remove(at: index)
//            feed.posts.insert(post, at: index)
//        }
//
//        if let index = self.feeds.firstIndex(where: {$0.url.absoluteString == feed.url.absoluteString}) {
//            self.feeds.remove(at: index)
//            self.feeds.insert(feed, at: index)
//        }
//
//        self.updateFeeds()
//    }
    
    var context: NSManagedObjectContext {
        return persistence.context
    }
    
    let didChange = PassthroughSubject<RSSStore, Never>()
    
    public var items: [RSS] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    public var rssSources: [RSS] = []
    
    override init() {
        super.init()
        fetchRSS()
        self.rssSources = items;
    }
    
    public func createAndSave(url: String, title: String = "", desc: String = "") -> RSS {
        let rss = RSS.create(
            url: url,
            title: title,
            desc: desc,
            in: context
        )
        saveChanges()
        return rss
    }
    
    public func delete(_ object: RSS) {
        context.delete(object)
        saveChanges()
    }
    
    public func update(_ item: RSS) {
        do {
            try update(RSS: item)
        } catch let error {
            print("\(#function) error = \(error)")
        }
    }
    
    private func update(RSS item: RSS) throws {
        guard let uuid = item.uuid else {
            return
        }
        let fetchRequest: NSFetchRequest<RSS> = RSS.fetchRequest()
        let predicate = NSPredicate(format: "uuid = %@", argumentArray: [uuid])
        fetchRequest.predicate = predicate
        do {
            let rs = try fetchedResultsController.managedObjectContext.fetch(fetchRequest)
            if let rss = rs.first {
                rss.title = item.title
                rss.desc = item.desc
                rss.url = item.url
                rss.lastFetchTime = item.lastFetchTime
                rss.createTime = item.createTime
                rss.updateTime = Date()
                saveChanges()
            } else {
                // TODO: throw Error
            }
        } catch let error {
            throw error
        }
    }
    
    private func fetchRSS() {
        do {
            try fetchedResultsController.performFetch()
            dump(fetchedResultsController.sections)
        } catch {
            fatalError()
        }
    }
    
    func saveChanges() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
}

extension RSSStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        didChange.send(self)
    }
}

enum ContentTimeType: String, CaseIterable {
    case minute60 = "1 hour"
    case minute120 = "2 hours"
    case hour12 = "12 hours"
    case hour24 = "1 day"

    var seconds: Int {
        switch self {
            
        case .minute60:
            return 60 * 60
        case .minute120:
            return 120 * 60
        case .hour12:
            return 12 * 60 * 60
        case .hour24:
            return 24 * 60 * 60
        }
    }
}
