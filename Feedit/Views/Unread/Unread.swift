//
//  Unread.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/17/21.
//

import SwiftUI
import Foundation
import CoreData
import Combine
import WidgetKit

public class Unread: NSObject, ObservableObject {
    
    @Published var items: [RSSItem] = []
    @Published var isOn: Bool = false
    @Published var unreadIsOn: Bool = true
    
    @ObservedObject var store = RSSStore.instance
    //@Published var feed: RSS
    @Published var filteredPosts: [RSSItem] = []
    @Published var filterType = FilterType.unreadIsOn
    @Published var selectedPost: RSSItem?
    @Published var showingDetail = false
    @Published var shouldReload = false
    @Published var showFilter = false
    
    private var cancellable: AnyCancellable? = nil
    private var cancellable2: AnyCancellable? = nil
    
    let dataSource: RSSItemDataSource
    var start = 0
    
    init(dataSource: RSSItemDataSource) {
        self.dataSource = dataSource
        super.init()
    }
    
//    init(dataSource: RSSItemDataSource, feed: RSS) {
//        self.dataSource = dataSource
//        self.feed = feed
//        super.init()
//
//        self.filteredPosts = feed.posts.filter { self.filterType == .unreadIsOn ? !$0.isRead : true }
//
//        cancellable = Publishers.CombineLatest3(self.$feed, self.$filterType, self.$shouldReload)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { (newValue) in
//                self.filteredPosts = newValue.0.posts.filter { newValue.1 == .unreadIsOn ? !$0.isRead : true }
//        })
//    }
    
    func loadMore() {
        start = items.count
        fecthResults(start: start)
    }
    
    func fecthResults(start: Int = 0) {
        if start == 0 {
            items.removeAll()
        }
        dataSource.performFetch(RSSItem.requestUnreadObjects(start: start))
        if let objects = dataSource.fetchedResult.fetchedObjects {
            items.append(contentsOf: objects)
        }
    }
    
    func fetchUnreadCount(start: Int = 0) {
        if start == 0 {
            items.removeAll()
        }
        dataSource.performFetch(RSSItem.requestObjects(rssUUID: UUID.init(), start: start))
        if let objects = dataSource.fetchedResult.fetchedObjects {
            items.append(contentsOf: objects)
        }
    }
    
    func unarchive(_ item: RSSItem) {
        let updatedItem = dataSource.readObject(item)
        updatedItem.isArchive = false
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
    
    func archiveOrCancel(_ item: RSSItem) {
        let updatedItem = dataSource.readObject(item)
        updatedItem.isArchive = !item.isArchive
        updatedItem.updateTime = Date()
        updatedItem.objectWillChange.send()
        dataSource.setUpdateObject(updatedItem)
        
        _ = dataSource.saveUpdateObject()
    }
    
    func markAllPostsRead() {
        self.store.markAllPostsRead(feed: RSS())
        shouldReload = true
    }
    
    func markPostRead(index: Int) {
        self.store.setPostRead(post: self.filteredPosts[index], feed: RSS())
        shouldReload = true
    }
    
    func reloadPosts() {
        store.reloadFeedPosts(feed: RSS())
    }
    
    func selectPost(index: Int) {
        self.selectedPost = self.filteredPosts[index]
        self.showingDetail.toggle()
        self.markPostRead(index: index)
    }
}
