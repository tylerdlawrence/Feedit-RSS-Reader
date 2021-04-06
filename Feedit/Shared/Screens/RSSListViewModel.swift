//
//  RSSListViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import Foundation
import Combine
import UIKit

class RSSListViewModel: NSObject, ObservableObject{
    @ObservedObject var store = RSSStore.instance

    @Published var isOn = false
    @Published var unreadIsOn = false
    @Published private(set) var items: [RSS] = []
//    @Published var count = Int()
    
    @Published var feeds: [FeedObject] = []
    @Published var shouldSelectFeedObject: FeedObject?
    @Published var shouldSelectFeed = false
    @Published var shouldPresentDetail = false
    @Published var shouldSelectFeedURL: String?
    @Published var shouldOpenSettings: Bool = false
    @Published var notificationsEnabled: Bool = false
    @Published var fetchContentTime: String = ContentTimeType.minute60.rawValue
    @Published var fetchContentType: ContentTimeType = .minute60
    @Published var totalUnreadPosts: Int = 0
    @Published var totalReadPostsToday: Int = 0
//    private var subscriptions: Set<AnyCancellable> = []
    var cancellables = Set<AnyCancellable>()
    
    let dataSource: RSSDataSource
    var start = 0
    
    var children: [RSS] = [RSS]()

    init(dataSource: RSSDataSource) {
        self.dataSource = dataSource
        super.init()
    }
    
    func fetchInfo() {
        self.feeds = store.feeds
            
            store.$feeds
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { (newValue) in
                    self.feeds = newValue
                })
                .store(in: &cancellables)
            
            Publishers.CombineLatest(store.$shouldSelectFeedURL, store.$shouldOpenSettings)
                .receive(on: DispatchQueue.main)
                .map { (newValue) -> (FeedObject?, Bool) in
                    guard let url = newValue.0 else {
                        return (nil, newValue.1)
                    }
                    return (self.feeds.first(where: {$0.url.absoluteString == url }), newValue.1)
                }
                .removeDuplicates(by: { (lhs, rhs) -> Bool in
                    return lhs.0?.url.absoluteURL != rhs.0?.url.absoluteURL && lhs.1 != rhs.1
                })
                .sink(receiveValue: { (newValue) in
                    self.shouldSelectFeedObject = newValue.0
                    self.shouldSelectFeed = newValue.0 != nil
                    self.shouldOpenSettings = newValue.1
                    self.shouldPresentDetail = self.shouldSelectFeed || self.shouldOpenSettings
                    print("present∂etail: \(self.shouldPresentDetail)")
                    self.objectWillChange.send()
                })
                .store(in: &cancellables)
        }

    func loadMore() {
        start = items.count
        fecthResults(start: start)
    }

    func fecthResults(start: Int = 0) {
        if start == 0 {
            items.removeAll()
        }
        dataSource.performFetch(RSS.requestObjects())
        if let objects = dataSource.fetchedResult.fetchedObjects {
            items.append(contentsOf: objects)
        }
    }
    
    func fetchUnreadCount(start: Int = 0) {
        self.start = items.count
        fecthResults(start: start)
        
        dataSource.performFetch(RSS.requestUnreadObjects(start: start))
        if let objects = dataSource.fetchedResult.fetchedObjects {
            items.append(contentsOf: objects)
        }
    }
    

    //MARK: context menu action for delete
    func delete(rss: RSS) {
        if let index = self.items.firstIndex(where: { $0.id == rss.id }) {
            items.remove(at: index)
        }
    }

    //MARK: swipe action for delete
//    func delete(at index: Int) {
//        let object = items[index]
//        dataSource.delete(object, saveContext: true)
//        items.remove(at: index)
//    }
    
    func delete(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(Persistence.current.context.delete)
            saveContext()
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        withAnimation {
            items.move(fromOffsets: source, toOffset: destination)
            saveContext()
        }
    }
    
    func saveContext() {
        do {
            try Persistence.current.context.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved Error: \(error)")
        }
    }

    var isRead: Bool {
        return readDate != nil
    }
    var readDate: Date? {
        didSet {
            objectWillChange.send()
        }
    }
}
