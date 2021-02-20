//
//  RSSFeedViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation

class RSSFeedViewModel: NSObject, ObservableObject {

    @Published var items: [RSSItem] = []
    @Published var feed: [RSS] = []
//    @ObservedObject var store = RSSStore.instance
    @Published var filteredPosts: [RSSItem] = []
    @Published var filterType = FilterType.unreadOnly
    @Published var selectedPost: RSSItem?
    @Published var showingDetail = false
    @Published var shouldReload = false
    @Published var showFilter = false
    let dataSource: RSSItemDataSource
    let rss: RSS
    var start = 0

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
                    self.rss.lastFetchTime = Date()
                    self.dataSource.saveCreateContext()

                    self.fecthResults()

                case .failure(let error):
                    print("feed error \(error)")
            }
        }
    }
}
extension RSSStore {

    func reloadAllPosts(handler: (() -> Void)? = nil) {
        var updatedCount = 0
        for _ in self.items {
            print("RELOADING POST")

//            reloadFeedPosts(feed: items) { success in
//                print("GOT POST")

                updatedCount += 1
                if updatedCount >= self.items.count {
                    handler?()
            }
        }
    }
}
//import SwiftUI
//import Foundation
//import FeedKit
//import FaviconFinder
//import Combine
//import CoreData
//import BackgroundTasks
//
//class RSSFeedViewModel: NSObject, ObservableObject {
////    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
//
//
//
//    @Published var items: [RSSItem] = []
//    @Published var feed: [RSS] = []
////    @ObservedObject var store = RSSStore.instance
//    @Published var filteredPosts: [RSSItem] = []
//    @Published var filterType = FilterType.unreadOnly
//    @Published var selectedPost: RSSItem?
//    @Published var showingDetail = false
//    @Published var shouldReload = false
//    @Published var showFilter = false
//
//
//    private var cancellable: AnyCancellable? = nil
//    private var cancellable2: AnyCancellable? = nil
//
//    let dataSource: RSSItemDataSource
//    let rss: RSS
//    var start = 0
//    static let instance = RSSStore()
//    var readDate = Date() {
//        didSet {
//            objectWillChange.send()
//        }
//    }
//    init(rss: RSS, dataSource: RSSItemDataSource) {
//        self.dataSource = dataSource
//        self.rss = rss
////        self.readDate = readDate
//        super.init()
//    }
//
//    func setPostRead(rss: RSS, feed: RSS) {
//        rss.readDate = Date()
//        feed.objectWillChange.send()
//    }
//
//    func selectPost(index: Int) {
//        self.selectedPost = self.filteredPosts[index]
//        self.showingDetail.toggle()
////        self.wasRead(index: index)
//    }
//
//    func archiveOrCancel(_ item: RSSItem) {
//        let updatedItem = dataSource.readObject(item)
//        updatedItem.isArchive = !item.isArchive
//        updatedItem.updateTime = Date()
//        dataSource.setUpdateObject(updatedItem)
//
//        _ = dataSource.saveUpdateObject()
//    }
//
//
//
//    func isRead(_ item: RSSItem) {
//        let updatedItem = dataSource.readObject(item)
//        updatedItem.updateTime = Date()
//        dataSource.setUpdateObject(updatedItem)
//
//        let rs = dataSource.saveUpdateObject()
//        switch rs {
//        case .failed:
//            print("----> \(#function) failed")
//        case .saved:
//            items.removeAll { item == $0 }
//        case .unchanged:
//            print("----> \(#function) unchanged")
//
//        }
//
//    }
//
//    func readOrCancel(_ item: RSSItem) {
//        let updatedItem = dataSource.readObject(item)
////        updatedItem.isRead = !item.isRead
//        updatedItem.updateTime = Date()
//        updatedItem.objectWillChange.send()
//        dataSource.setUpdateObject(updatedItem)
//        let rs = dataSource.saveUpdateObject()
//        switch rs {
//        case .failed:
//            print("----> \(#function) failed")
//        case .saved:
//            items.removeAll { item == $0 }
//        case .unchanged:
//            print("----> \(#function) unchanged")
//
//        }
//        _ = dataSource.saveUpdateObject()
//    }
//
//    func loadMore() {
//        start = items.count
//        fecthResults(start: start)
//    }
//
//    //Will attempt to recover by breaking constraint
////    <NSLayoutConstraint:0x280634e10 H:[_UIButtonBarStackView:0x12ec95310]-(16)-|   (active, names: '|':_UIToolbarContentView:0x12ec196a0 )>
////
////    Make a symbolic breakpoint at UIViewAlertForUnsatisfiableConstraints to catch this in the debugger.
////    The methods in the UIConstraintBasedLayoutDebugging category on UIView listed in <UIKitCore/UIView.h> may also be helpful.
////    2021-02-05 17:47:01.389112-0500 Feedit[11568:1426408] [tcp] tcp_input [C2.1:3] flags=[R.] seq=4267782120, ack=3896267118, win=4096 state=CLOSE_WAIT rcv_nxt=4267782120, snd_una=3896267118
////    2021-02-05 17:47:01.390779-0500 Feedit[11568:1426408] [tcp] tcp_input [C3.1:3] flags=[R.] seq=353994381, ack=2384421399, win=4096 state=CLOSE_WAIT rcv_nxt=353994381, snd_una=2384421399
////    2021-02-05 17:47:01.436616-0500 Feedit[11568:1426547] [tcp] tcp_input [C1.1:3] flags=[R] seq=3954640174, ack=0, win=0 state=FIN_WAIT_1 rcv_nxt=3954640174, snd_una=3246465668
//    func fecthResults(start: Int = 0) {
//        if start == 0 {
//            items.removeAll()
//        }
//        dataSource.performFetch(RSSItem.requestObjects(rssUUID: self.rss.uuid!, start: start))
//        if let objects = dataSource.fetchedResult.fetchedObjects {
//            items.append(contentsOf: objects)
//        }
//    }
//}
//
//extension RSSStore {
//
//    func reloadAllPosts(handler: (() -> Void)? = nil) {
//        var updatedCount = 0
//        for _ in self.items {
//            print("RELOADING POST")
//
////            reloadFeedPosts(feed: items) { success in
////                print("GOT POST")
//
//                updatedCount += 1
//                if updatedCount >= self.items.count {
//                    handler?()
//            }
//        }
//    }
//}
