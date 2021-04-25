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
import URLImage
import BackgroundTasks
import WidgetKit

extension RSSFeedViewModel: Identifiable {

}

class RSSFeedViewModel: NSObject, ObservableObject {
    typealias Element = RSSItem
    typealias Context = RSSItem
    typealias Model = Post
    private(set) lazy var rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    
    @Published var isOn = false
    @Published var unreadIsOn = false
    @Published var items = [RSSItem]()
    @Published var filteredArticles: [RSSItem] = []
    @Published var selectedPost: RSSItem?
    @Published var shouldReload = false
    @ObservedObject var store = RSSStore.instance
    @Published var filteredPosts: [RSSItem] = []
    @Published var filterType = FilterType.unreadIsOn
    @Published var showingDetail = false
    @Published var showFilter = false
    @Published var rss: RSS
    @Published var rssItem = RSSItem()
    
    private var cancellable: AnyCancellable? = nil
    private var cancellable2: AnyCancellable? = nil
    
    let dataSource: RSSItemDataSource
    
    var start = 0
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
        
    let urls = [URL]()
    
    init(rss: RSS, dataSource: RSSItemDataSource) {
        self.dataSource = dataSource
        self.rss = rss
        super.init()
        
        
        
        let publishers = urls.map { URLImageService.shared.remoteImagePublisher($0) }
        cancellable = Publishers.MergeMany(publishers)
            .tryMap { $0.cgImage }
            .catch { _ in
                Just(nil)
            }
            .collect()
            .sink { images in
                if let objects = dataSource.fetchedResult.fetchedObjects {
                    self.items.insert(contentsOf: objects, at: 0)
            }
        }
        
        
                
        self.filteredPosts = rss.posts.filter { self.filterType == .unreadIsOn ? !$0.isRead : true }
        cancellable = Publishers.CombineLatest3(self.$rss, self.$filterType, self.$shouldReload)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (newValue) in
                self.filteredPosts = newValue.0.posts.filter { newValue.1 == .unreadIsOn ? !$0.isRead : true }
        })
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
    
    func markAllPostsRead() {
        self.store.markAllPostsRead(feed: self.rss)
        shouldReload = true
    }
    
    func markPostRead(index: Int) {
        self.store.setPostRead(post: self.filteredArticles[index], feed: self.rss)
        shouldReload = true
    }
    
    func reloadPosts() {
        store.reloadFeedPosts(feed: rss)
    }
    
    func selectPost(index: Int) {
        self.selectedPost = self.filteredArticles[index]
        self.showingDetail.toggle()
        self.markPostRead(index: index)
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
    var name: String
    var url: URL
    var posts: [Post] {
        didSet {
            objectWillChange.send()
        }
    }
    
    var imageURL: URL?
    
    var lastUpdateDate: Date
    
    init?(feed: Feed, url: URL) {
        self.url = url
        lastUpdateDate = Date()
        
        switch feed {
        case .rss(let rssFeed):
            self.name =  rssFeed.title ?? ""
            
            let items = rssFeed.items ?? []
            self.posts = items
                .compactMap { Post(feedItem: $0) }
                .sorted(by: { (lhs, rhs) -> Bool in
                    return Calendar.current.compare(lhs.date, to: rhs.date, toGranularity: .minute) == ComparisonResult.orderedDescending
                })
            
            if let urlStr = rssFeed.image?.url, let url = URL(string: urlStr) {
                self.imageURL = url
            } else {
                FaviconFinder(url: URL(string: rssFeed.link ?? "")!).downloadFavicon { (_) in
                    self.imageURL = url
                }
            }
            
        case .atom(let atomFeed):
            self.name =  atomFeed.title ?? ""
            
            let items = atomFeed.entries ?? []
            self.posts = items
                .compactMap { Post(atomFeed: $0) }
                .sorted(by: { (lhs, rhs) -> Bool in
                    return Calendar.current.compare(lhs.date, to: rhs.date,     toGranularity: .minute) ==  ComparisonResult.orderedDescending
                })
            
            if let urlStr = atomFeed.logo, let url = URL(string: urlStr) {
                self.imageURL = url
            } else {
                FaviconFinder(url: URL(string: atomFeed.links?.first?.attributes?.href ?? "")!).downloadFavicon { (_) in
                    self.imageURL = url
                }
            }
        default:
            return nil
        }
        
    }
    
    init(name: String, url: URL, posts: [Post]) {
        self.name = name
        self.url = url
        self.posts = posts
        lastUpdateDate = Date()
    }
    
    static var testObject: FeedObject {
        return FeedObject(name: "Test feed",
        url: URL(string: "https://www.google.com")!,
        posts: [Post.testObject])
    }
}

class Post: Codable, Identifiable, ObservableObject {
    var id = UUID()
    var title: String
    var description: String
    var url: URL
    var date: Date

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
    }

    static var testObject: Post {
        return Post(title: "This Is A Test Post Title",
        description: "This is a test post description",
        url: URL(string: "https://www.google.com")!)
    }
}
