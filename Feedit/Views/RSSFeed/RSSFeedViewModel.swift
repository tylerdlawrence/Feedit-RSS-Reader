//
//  RSSFeedViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//


import SwiftUI
import FeedKit
import FaviconFinder
import Combine
import CoreData
import BackgroundTasks

public class RSSFeedViewModel: NSObject, ObservableObject {
//    @ObservedObject var rssFeedViewModel: RSSFeedViewModel

    
            
    @Published var items: [RSSItem] = []
    @Published var feed: [RSS] = []
    @ObservedObject var store = RSSStore.instance
    @Published var filteredPosts: [RSSItem] = []
    @Published var filterType = FilterType.unreadOnly
    @Published var selectedPost: RSSItem?
    @Published var showingDetail = false
    @Published var shouldReload = false
    @Published var showFilter = false


    private var cancellable: AnyCancellable? = nil
    private var cancellable2: AnyCancellable? = nil
    
    let dataSource: RSSItemDataSource
    let rss: RSS
    var start = 0
    static let instance = RSSStore()
    var readDate: Date? {
        didSet {
            objectWillChange.send()
        }
    }
    init(rss: RSS, dataSource: RSSItemDataSource) { //, rssViewModel: RSSFeedViewModel
        self.dataSource = dataSource
        self.rss = rss
        super.init()
    }

//    init(rss: RSS, dataSource: RSSItemDataSource) {
//        self.dataSource = dataSource
//        self.rss = rss
//        self.filteredPosts = rss.context.filter { self.filterType == .unreadOnly ? !$0.isRead : true }
//
//        cancellable = Publishers.CombineLatest3(self.$feed, self.$filterType, self.$shouldReload)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { (newValue) in
//                self.filteredPosts = newValue.0.context.filter { newValue.1 == .unreadOnly ? !$0.isRead : true }
//            })
////        super.init()
//    }

    
    func setPostRead(rss: RSS, feed: RSS) {
        rss.readDate = Date()
        feed.objectWillChange.send()
    }
    
    func markAllPostsRead() {
        rss.context.forEach { (context) in
            setPostRead(rss: rss, feed: rss)
        }
    }
    
    

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

    func selectPost(index: Int) {
        self.selectedPost = self.filteredPosts[index]
        self.showingDetail.toggle()
//        self.wasRead(index: index)
    }
    
    func archiveOrCancel(_ item: RSSItem) {
        let updatedItem = dataSource.readObject(item)
        updatedItem.isArchive = !item.isArchive
        updatedItem.updateTime = Date()
        dataSource.setUpdateObject(updatedItem)
        
        _ = dataSource.saveUpdateObject()
    }
    
    
    
    func markAsRead(_ item: RSSItem) {
        let updatedItem = dataSource.readObject(item)
//        updatedItem.isRead = false
        updatedItem.updateTime = Date()
        dataSource.setUpdateObject(updatedItem)

        let rs = dataSource.saveUpdateObject()
        switch rs {
        case .failed:
            print("----> \(#function) failed")
        case .saved:
            items.removeAll { item == $0 }
        case .unchanged:
            print("----> \(#function) unchanged")

        }

    }
    
    func readOrCancel(_ item: RSSItem) {
        let updatedItem = dataSource.readObject(item)
//        updatedItem.isRead = !item.isRead
        updatedItem.updateTime = Date()
        updatedItem.objectWillChange.send()
        dataSource.setUpdateObject(updatedItem)

        _ = dataSource.saveUpdateObject()
    }
    
    func loadMore() {
        start = items.count
        fecthResults(start: start)
    }
    func fecthResults(start: Int = 0) {
        if start == 0 {
            items.removeAll()
        }
        dataSource.performFetch(RSSItem.requestObjects(rssUUID: rss.uuid!, start: start))
        if let objects = dataSource.fetchedResult.fetchedObjects {
            items.append(contentsOf: objects)
        }
    }
    
    
    
    func fetchRemoteRSSItems() {
        guard let url = URL(string: rss.url) else {
            return
        }
        guard let uuid = self.rss.uuid else {
            return
        }
        fetchNewRSS(url: url) { result in
            switch result {
            case .success(let feed):
                var items = [RSSItem]()
                switch feed {
                    case .atom(let atomFeed):
                        for item in atomFeed.entries ?? [] {
                            if let fetchDate = self.rss.lastFetchTime, let pubDate = item.published, pubDate < fetchDate {
                                continue
                            }
                            guard let title = item.title, items.filter({ $0.title == title }).count <= 0 else {
                                continue
                            }
                            items.append(item.asRSSItem(container: uuid, in: self.dataSource.createContext))
                        }
//                        .removeDuplicates(by: { (lhs, rhs) -> Bool in
//                            return lhs.0?.url.absoluteURL != rhs.0?.url.absoluteURL && lhs.1 != rhs.1
//                        })
                    case .json(let jsonFeed):
                        for item in jsonFeed.items ?? [] {
                            if let fetchDate = self.rss.lastFetchTime, let pubDate = item.datePublished, pubDate < fetchDate {
                                continue
                            }
                            guard let title = item.title, items.filter({ $0.title == title }).count <= 0 else {
                                continue
                            }
                            items.append(item.asRSSItem(container: uuid, in: self.dataSource.createContext))
                        }
                    case .rss(let rssFeed):
                        for item in rssFeed.items ?? [] {
                            if let fetchDate = self.rss.lastFetchTime, let pubDate = item.pubDate, pubDate < fetchDate {
                                continue
                            }
                            guard let title = item.title, items.filter({ $0.title == title }).count <= 0 else {
                                continue
                            }
                            items.append(item.asRSSItem(container: uuid, in: self.dataSource.createContext))
                        }
                    }
                    self.rss.lastFetchTime = Date()
                    self.dataSource.saveCreateContext()
                    
                    self.fecthResults()
                
                case .failure(let error):
                    print("feed error \(error)")
            }
        }
    }
}



extension UserDefaultsBacked where Value: ExpressibleByNilLiteral {
    init(key: String, storage: UserDefaults = .standard) {
        self.init(key: key, defaultValue: nil, storage: storage)
    }
}

struct SettingsViewModel {
    
    @UserDefaultsBacked(key: "mark-as-read", defaultValue: true)
    var autoMarkMessagesAsRead: Bool

    @UserDefaultsBacked(key: "search-page-size", defaultValue: 20)
    var numberOfSearchResultsPerPage: Int

    @UserDefaultsBacked(key: "signature")
    var messageSignature: String?
}

class FlagToggleViewController: UIViewController {
    private let flag: Flag<Bool>
    private lazy var label = UILabel()
    private lazy var toggle = UISwitch()
    
    let flags: FeatureFlags

//    let searchToggleVC = FlagToggleViewController(
//        flag: flags.$isSearchEnabled
//    )

//    init(flag: Flag<Bool>) {
//        self.flag = flag
//        super.init(nibName: nil, bundle: nil)
//    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = flag.name
        toggle.isOn = flag.wrappedValue

        toggle.addTarget(self,
            action: #selector(toggleFlag),
            for: .valueChanged
        )
        
    }

    @objc private func toggleFlag() {
        flag.wrappedValue = toggle.isOn
    }
}
