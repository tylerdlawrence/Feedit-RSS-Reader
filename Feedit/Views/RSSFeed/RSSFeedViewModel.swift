//
//  RSSFeedViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation
import UIKit
import CoreData
import Combine

class RSSFeedViewModel: NSObject, ObservableObject {
    
    let defaultFeeds: [DefaultFeeds] = Bundle.main.decode("DefaultFeeds.json")
    @Published var sources: [DefaultFeeds] = []
    
    @Published var items: [RSSItem] = []
    
    let dataSource: RSSItemDataSource
    let rss: RSS
    var start = 0
    
    init(rss: RSS, dataSource: RSSItemDataSource) {
        self.dataSource = dataSource
        self.rss = rss
//        self.sources = defaultFeeds
        super.init()
    }
    
    func archiveOrCancel(_ item: RSSItem) {
        let updatedItem = dataSource.readObject(item)
        updatedItem.isArchive = !item.isArchive
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
//    func fecthResults(start: Int = 0) {
//        if start == 0 {
//            items.removeAll()
//        }
//        dataSource.performFetch(RSSItem.requestObjects(rssUUID: rss.uuid!, start: start))
//        if let objects = dataSource.fetchedResult.fetchedObjects {
//            items.append(contentsOf: objects)
//        }
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
                            if let fetchDate = self.rss.lastFetchTime, let pubDate = item.published, pubDate < fetchDate {
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
