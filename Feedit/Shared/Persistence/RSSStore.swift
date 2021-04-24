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

    @Published var shouldSelectFeedURL: String?
    @Published var shouldOpenSettings: Bool = false
    @Published var notificationsEnabled: Bool = false
    @Published var fetchContentTime: String = ContentTimeType.minute60.rawValue
    @Published var fetchContentType: ContentTimeType = .minute60
    @Published var totalUnreadPosts: Int = 0
    @Published var totalReadPostsToday: Int = 0
    @Published var feeds: [RSS] = []
    

    static let instance = RSSStore()
    
    private let persistence = Persistence.current
    
    var userDefaults = UserDefaults(suiteName: "group.com.tylerdlawrence.feedit.shared");
    
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
    
    lazy var applicationDocumentsDirectory: URL = {
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.tylerdlawrence.feedit.shared")!
        return containerURL
    }()
    
    var isRead: Bool {
        return readDate != nil
    }
    
    var readDate: Date? {
        didSet {
            objectWillChange.send()
        }
    }
    
    func setPostRead(_ rss: RSS, item: RSSItem) {
        rss.readDate = Date()
        item.objectWillChange.send()
        
        if self.rssSources.firstIndex(where: {$0.url == rss.url}) != nil {
        }
    }

    var context: NSManagedObjectContext {
        return persistence.context
    }
    
    let didChange = PassthroughSubject<RSSStore, Never>()
    
    public var items: [RSS] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    public var rssSources: [RSS] = []
    var cancellables = Set<AnyCancellable>()
    
    var posts = [RSSItem]() {
        didSet {
            objectWillChange.send()
        }
    }
    
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
                rss.itemCount = Int64()
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
    func fetchContents(feedURL: URL, handler: @escaping (_ feed: Feed?) -> Void) {
        let parser = FeedParser(URL: feedURL)
        
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            
            switch result {
                
            case .success(let feed):
                DispatchQueue.main.async {
                    handler(feed)
                }
            case .failure(let error):
                handler(nil)
                print(error)
            }
        }
    }
    func removeFeed(at index: Int) {
        feeds.remove(at: index)
        updateFeeds()
    }
    func updateFeeds() {
        UserDefaults.feeds = self.feeds
    }
    
    func refreshExtensionFeeds() {
        print("New feeds (\(UserDefaults.newFeedsToAdd)")
        for feed in UserDefaults.newFeedsToAdd {
            addFeed(feedURL: feed) { (success) in
                print("New feed (\(feed.absoluteString): \(success)")
            }
        }
        UserDefaults.newFeedsToAdd = []
    }
    
    func addFeedFromExtension(url: URL) {
        UserDefaults.newFeedsToAdd = UserDefaults.newFeedsToAdd + [url]
    }
    
    func addFeed(feedURL: URL, handler: @escaping (_ success: Bool) -> Void) {
        if self.feeds.contains(where: {$0.url == feedURL.absoluteString }) {
            handler(false)
            return
        }
        
        update(RSS())
    }
}

extension RSSStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        didChange.send(self)
    }
}

// MARK: - Public Methods
extension RSSStore {
    
    func reloadAllPosts(handler: (() -> Void)? = nil) {
        var updatedCount = 0
        for rss in self.items {
            print("RELOADING POST")

            updateFeeds()
            update(rss)
            reloadAllPosts()
            reloadAllPosts(handler: handler)
            print("GOT POST")
            
            updatedCount += 1
                
            if updatedCount >= self.items.count {
                    handler?()
            }
        }
    }
    
    func reloadFeedPosts(feed: RSS, handler: ((_ success: Bool) -> Void)? = nil) {
        fetchContents(feedURL: feed.rssURL?.absoluteURL ?? URL(string: "")!) { (feedObject) in

            guard let feedObject = feedObject,
                  let newFeed = self.shouldSelectFeedURL else { return }
            let recentFeedPosts = newFeed.description.filter { newPost in
                return !(self.feeds.contains { (post) -> Bool in
                    return post.title == newPost.description
                })
            }

            guard !recentFeedPosts.isEmpty else {
                handler?(true)
                return
            }

            self.posts.insert(contentsOf: self.posts, at: 0)

            if let index = self.feeds.firstIndex(where: {$0.url == feed.url }) {
                self.feeds.remove(at: index)
                self.feeds.insert(feed, at: index)
            }
            self.updateFeeds()
            self.scheduleNewPostNotification(for: feed)
            handler?(true)
        }
    }
    
    func markAllPostsRead(feed: RSS) {
        feed.posts.forEach { (post) in
            setPostRead(post: post, feed: feed)
        }
    }
    
    func setPostRead(post: RSSItem, feed: RSS) {
        post.readDate = Date()
        feed.objectWillChange.send()
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
        
        self.updateFeeds()
    }
    
    func totalReadPosts(in date: Date) -> Int {
        let allPosts = feeds.map { $0.posts }.reduce([], +)
        
        return allPosts.filter { (post) -> Bool in
            guard  let readDate = post.readDate else {
                return false
            }
            return Calendar.current.isDate(readDate, inSameDayAs: date)
        }.count
    }
}

// MARK: - Notifications
extension RSSStore {
    func scheduleNewPostNotification(for feed: RSS) {
        Notifier.notify(title: "New post from \(feed.title)", body: feed.posts.first?.title ?? "", info: ["feedURL": feed.url])
    }
}

struct Notifier {
    static func notify(title: String, body: String, info: [AnyHashable: Any]? = nil) {
        Notifier.requestAuthorization { _ in
            let center = UNUserNotificationCenter.current()
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body

            if let info = info {
                content.userInfo = info
            }
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }

    }
    
    static func requestAuthorization(handler: @escaping (_ isAccepted: Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (isAccepted, error) in
            handler(isAccepted)
        }
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
