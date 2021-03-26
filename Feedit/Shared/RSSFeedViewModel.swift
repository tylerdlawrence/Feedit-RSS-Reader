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
    private(set) lazy var rssFeedViewModel = RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem)
        
    var changeReadFilterSubject = PassthroughSubject<Bool, Never>()
    var selectNextUnreadSubject = PassthroughSubject<Bool, Never>()
    var readFilterAndFeedsPublisher: AnyPublisher<([RSS], Bool?), Never>?
    @Published var nameForDisplay = ""
    @Published var selectedTimelineItemIDs = Set<String>()  // Don't use directly.  Use selectedTimelineItemsPublisher
    @Published var selectedTimelineItemID: String? = nil    // Don't use directly.  Use selectedTimelineItemsPublisher
    @Published var listID = ""
    
    private var bag = Set<AnyCancellable>()
        
    @Published var isOn = false
    @Published var unreadIsOn = false
    @Published var items = [RSSItem]()// = []
    
    @Published var selectedPost: RSSItem?
    @Published var shouldReload = false
    
    var startIndex: Int { items.startIndex }
    var endIndex: Int { items.endIndex }
    subscript(position: Int) -> RSSItem {
            return items[position]
        }
    
    let dataSource: RSSItemDataSource
    
    let rss: RSS
    var start = 0
    
    init(rss: RSS, dataSource: RSSItemDataSource) {
        self.dataSource = dataSource
        self.rss = rss
        super.init()
    }
    
    func markAllAsRead() {
        rssFeedViewModel.markAllAsRead()
    }
    
//    func markAllPostsRead(start: Int = 0, _ item: RSSItem) {
//        self.markAllPostsRead(item)
//        shouldReload = true
//    }
    
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
//                    self.rss.title = self.rss.title
                    self.rss.lastFetchTime = Date()
                    self.dataSource.saveCreateContext()

                    self.fecthResults()

                case .failure(let error):
                    print("feed error \(error)")
            }
        }
    }
    
    // Phantom type placeholder for undefined methods
    func undefined<T>(_ message:String="",file:String=#file,function:String=#function,line: Int=#line) -> T {
        fatalError("[File: \(file),Line: \(line),Function: \(function),]: Undefined: \(message)")
    }
}