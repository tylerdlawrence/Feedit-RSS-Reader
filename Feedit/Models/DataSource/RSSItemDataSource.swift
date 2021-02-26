//
//  RSSItemDataSource.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import CoreData

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

extension RSSItemDataSource {
    func simple() -> RSSItem? {
        let item = RSSItem.init(context: createContext)
        item.title = "Lorem Ipsum Dolor"
        item.desc = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        item.createTime = Date()
        item.author = "tyler d lawrence"
        return item
    }
}

//class RSSItemDataSource: NSObject, DataSource {
//
//    var parentContext: NSManagedObjectContext
//
//    var createContext: NSManagedObjectContext
//
//    var updateContext: NSManagedObjectContext
//
//    var fetchedResult: NSFetchedResultsController<RSSItem>
//
//    var newObject: RSSItem?
//
//    var updateObject: RSSItem?
//
//    var save: RSSItem?
//
//    var markAllPostsRead: RSSItem?
//
//    static let instance = RSSStore()
//
//    @Published var feeds: [FeedObject] = []
//    @Published var shouldSelectFeedURL: String?
//    @Published var shouldOpenSettings: Bool = false
//    @Published var notificationsEnabled: Bool = false
//    @Published var fetchContentTime: String = ContentTimeType.minute60.rawValue
//    @Published var fetchContentType: ContentTimeType = .minute60
//    @Published var totalUnreadPosts: Int = 0
//    @Published var totalReadPostsToday: Int = 0
//    @Published var shouldReload = false
//
////    var cancellables = Set<AnyCancellable>()
//
//
//
//    func markAllPostsRead(feeds: RSSItem) {
//
//    }
//
//    var isRead: Bool
//    {
//        return readDate != nil
//    }
//
//    var readDate: Date? {
//        didSet {
//            objectWillChange.send()
//        }
//    }
//    func setPostRead(post: RSSItem, feed: FeedObject) {
//        post.readDate = Date()
//        feed.objectWillChange.send()
//        totalUnreadPosts -= 1
//        totalReadPostsToday += 1
//        if let index = feed.posts.firstIndex(where: {$0.url == post.url}) {
//            feed.posts.remove(at: index)
//            feed.posts.insert(post, at: index)
//        }
//
//        if let index = self.feeds.firstIndex(where: {$0.url == feed.url}) {
//            self.feeds.remove(at: index)
//            self.feeds.insert(feed, at: index)
//        }
//
////        self.updateFeeds()
//    }
//
//    func totalReadPosts(in date: Date) -> Int {
//        let allPosts = feeds.map { $0.posts }.reduce([], +)
//
//        return allPosts.filter { (post) -> Bool in
//            guard  let readDate = post.readDate else {
//                return false
//            }
//            return Calendar.current.isDate(readDate, inSameDayAs: date)
//        }.count
//    }
//
//    required init(parentContext: NSManagedObjectContext) {
//        self.parentContext = parentContext
//        createContext = parentContext.newChildContext()
//        updateContext = parentContext.newChildContext()
//
//
//        let request = Model.fetchRequest() as NSFetchRequest<RSSItem>
//        request.sortDescriptors = []
//
//        fetchedResult = .init(
//            fetchRequest: request,
//            managedObjectContext: parentContext,
//            sectionNameKeyPath: nil,
//            cacheName: nil
//        )
//
//        super.init()
//        fetchedResult.delegate = self
//    }
//
//}
//
//extension RSSItemDataSource {
//    func simple() -> RSSItem? {
//        let item = RSSItem.init(context: createContext)
//        item.url = ""
//        return item
//    }
//}
