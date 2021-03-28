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

    @Published private(set) var items: [RSS] = []
    
    @Published var isLoading: Bool = false
    private var subscriptions: Set<AnyCancellable> = []
    
    let dataSource: RSSDataSource
//    let itemDataSource: RSSItemDataSource
    var start = 0
    
    var children: [RSS] = [RSS]()
    var unreadCount: Int

    init(dataSource: RSSDataSource, unreadCount: Int) {
//        self.itemDataSource = itemDataSource
        self.dataSource = dataSource
        self.unreadCount = unreadCount
        super.init()
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
    private func delete(rss: RSS) {
        if let index = self.items.firstIndex(where: { $0.id == rss.id }) {
            items.remove(at: index)
        }
    }

    //MARK: swipe action for delete
    func delete(at index: Int) {
        let object = items[index]
        dataSource.delete(object, saveContext: true)
        items.remove(at: index)
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
