//
//  AllArticles.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/17/21.
//

import Foundation
import CoreData
import SwiftUI
import Combine
import UIKit

class AllArticles: NSObject, ObservableObject {
    
    @Published var items: [RSSItem] = [RSSItem]()
    @Published var isOn: Bool = false
    @Published var unreadIsOn: Bool = false
    
    let dataSource: RSSItemDataSource
    var start = 0
    
    let rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    init(dataSource: RSSItemDataSource) {
        self.dataSource = dataSource
        super.init()
    }
    
    func loadMore() {
        start = items.count
        fecthResults()
    }
    
    func fecthResults() {
        if start == 0 {
            items.removeAll()
        }
        dataSource.performFetch(RSSItem.requestAllObjects(start: start))
        if let objects = dataSource.fetchedResult.fetchedObjects {
            items.append(contentsOf: objects)
        }
    }
    
    func fetchCount() {
        if start == 0 {
            //
        }
        dataSource.performFetch(RSSItem.requestCountAllObjects(start: start))
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
}
