//
//  RSSFeedViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation
import CoreData
import SwiftUI
import Combine
import UIKit
import FeedKit
import FaviconFinder
import BackgroundTasks
import WidgetKit

extension RSSFeedViewModel: Identifiable {

}


class RSSFeedListItem: Identifiable, Codable {
    var uuid = UUID()
    var author: String?
    var title: String
    var urlToImage: String?
    var url: String
    
    enum CodingKeys: String, CodingKey {
        case author, title, urlToImage, url
    }
}



class RSSFeedViewModel: NSObject, ObservableObject {
    typealias Element = RSSItem
    typealias Context = RSSItem
    private(set) lazy var rssFeedViewModel = RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem) //, feed: feed)
//    var changeReadFilterSubject = PassthroughSubject<Bool, Never>()
//    var selectNextUnreadSubject = PassthroughSubject<Bool, Never>()
//    var readFilterAndFeedsPublisher: AnyPublisher<([RSS], Bool?), Never>?
//    @Published var nameForDisplay = ""
//    @Published var selectedTimelineItemIDs = Set<String>()  // Don't use directly.  Use selectedTimelineItemsPublisher
//    @Published var selectedTimelineItemID: String? = nil    // Don't use directly.  Use selectedTimelineItemsPublisher
//    @Published var listID = ""
//    private var bag = Set<AnyCancellable>()
    
    @Published var isOn = false
    @Published var unreadIsOn = false
    @Published var items = [RSSItem]()
    @Published var filteredArticles: [RSSItem] = []
    @Published var selectedPost: RSSItem?
    @Published var shouldReload = false
//    @ObservedObject var store = RSSStore.instance
//    @Published var filterType = FilterType.unreadIsOn
//    private var cancellable: AnyCancellable? = nil
//    private var cancellable2: AnyCancellable? = nil
    @ObservedObject var store = RSSStore.instance
    
    var startIndex: Int { items.startIndex }
    var endIndex: Int { items.endIndex }
    subscript(position: Int) -> RSSItem {
            return items[position]
    }
    
    func placeholder(in with: Context) -> RSSFeedViewModel {
        RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem)
    }
    let dataSource: RSSItemDataSource
    let rss: RSS
    var start = 0
    
//    init(rss: RSS, dataSource: RSSItemDataSource, feed: FeedObject) {
//        self.feed = feed
//        self.filteredArticles = feed.posts.filter { self.filterType == .unreadIsOn ? !$0.isRead : true }
//
//        cancellable = Publishers.CombineLatest3(self.$feed, self.$filterType, self.$shouldReload)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { (newValue) in
//                self.filteredArticles = newValue.0.posts.filter { newValue.1 == .unreadIsOn ? !$0.isRead : true }
//            })
//
    
    init(rss: RSS, dataSource: RSSItemDataSource) {
        self.dataSource = dataSource
        self.rss = rss
        super.init()
    }


    
    func archiveOrCancel(_ item: RSSItem) {
        let updatedItem = dataSource.readObject(item)
        updatedItem.isArchive = !item.isArchive
        updatedItem.updateTime = Date()
        dataSource.setUpdateObject(updatedItem)

        _ = dataSource.saveUpdateObject()
    }
    
    func unreadOrCancel(_ item: RSSItem) {
        let updatedItem = dataSource.readObject(item)
        updatedItem.isRead = !item.isRead
        updatedItem.updateTime = Date()
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
    
//    func markAllPostsRead(_ item: RSSItem) {
//        item.title.forEach { (item) in
//            items.removeAll()
//        }
//    }
    
//    func markAllPostsRead() {
//        self.store.markAllPostsRead(item: self.item)
//        shouldReload = true
//    }

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
                            if let fetchDate = self.rss.lastFetchTime, let pubDate = item.updated, pubDate < fetchDate {
                                continue
                            }
                            guard let title = item.title, items.filter({ $0.title == title }).count <= 0 else {
                                continue
                            }
                            items.append(item.asRSSItem(container: uuid, in: self.dataSource.createContext))
                        }
                        
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

class FeedObject: Codable, Identifiable, ObservableObject {
    var id = UUID()
//    var count: Int
    var articles: [Post] = [] {
        didSet {
            objectWillChange.send()
        }
    }

//    let feed = ""
//    var imageURL: URL?
//    var lastUpdateDate: Date

    init?(articles: [Post]) {
//        self.feed = feed
//        self.count = count
//        lastUpdateDate = Date()
        self.articles = articles
    }
}

extension RSS {
    func totalUnreadCount() -> Int {
        return self.children.reduce(0) { count, rss in
            // Reduce closures get passed the previous value, as well
            // as the next element within the sequence that's being
            // reduced, and then returns a new value.
            count + self.children.count
        }
    }
}

class Post: Codable, Identifiable, ObservableObject {
    var id = UUID()
    var title: String
    var description: String
    var url: URL
    var date: Date
    var isToday: Bool
    var isStarred: Bool


    var isRead: Bool
    {
        return readDate != nil
    }

    var readDate: Date? {
        didSet {
            objectWillChange.send()
        }
    }

    var lastUpdateDate: Date

    init?(feedItem: RSSFeedItem) {
        self.title =  feedItem.title ?? ""
        self.description = feedItem.description ?? ""
        self.isStarred = false
        self.isToday = false

        if let link = feedItem.link, let url = URL(string: link) {
            self.url = url
        } else {
            return nil
        }
        self.date = feedItem.pubDate ?? Date()
        lastUpdateDate = Date()
    }

    init?(atomFeed: AtomFeedEntry) {
        self.title =  atomFeed.title ?? ""
        self.isStarred = false
        self.isToday = false
        let description = atomFeed.content?.value ?? ""

        let attributed = try? NSAttributedString(data: description.data(using: .unicode)!, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        self.description = attributed?.string ?? ""

        if let link = atomFeed.links?.first?.attributes?.href, let url = URL(string: link) {
            self.url = url
        } else {
            return nil
        }
        self.date = atomFeed.updated ?? Date()
        lastUpdateDate = Date()
    }

    init(title: String, description: String, url: URL) {
        self.title = title
        self.description = description
        self.url = url
        self.date = Date()
        lastUpdateDate = Date()
        self.isStarred = false
        self.isToday = false
    }

    static var testObject: Post {
        return Post(title: "This Is A Test Post Title",
        description: "This is a test post description",
        url: URL(string: "https://www.google.com")!)
    }
}
