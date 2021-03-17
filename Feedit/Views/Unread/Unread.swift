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

class Unread: NSObject, ObservableObject {
    
    @Published var items: [RSSItem] = []
    
    let dataSource: RSSItemDataSource
    var start = 0
    
    init(dataSource: RSSItemDataSource) {
        self.dataSource = dataSource
        super.init()
    }
    
    func loadMore() {
        start = items.count
        fecthResults(start: start)
    }
    
    func fecthResults(start: Int = 0, limit: Int = 1000) {
        if start == 0 {
            items.removeAll()
        }
        dataSource.performFetch(RSSItem.requestUnreadObjects(start: start))
        if let objects = dataSource.fetchedResult.fetchedObjects {
            items.append(contentsOf: objects)
        }
    }
    
    func fetchUnreadCount(start: Int = 0, limit: Int = 1000) {
        if start == 0 {
            //
        }
        dataSource.performFetch(RSSItem.requestCountUnreadObjects(start: start))
        if let objects = dataSource.fetchedResult.fetchedObjects {
            items.append(contentsOf: objects)
        }
    }
}
