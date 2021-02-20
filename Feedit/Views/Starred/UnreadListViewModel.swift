////
////  UnreadListViewModel.swift
////  Feedit
////
////  Created by Tyler D Lawrence on 2/17/21.
////
//
//import Foundation
//
//class UnreadListViewModel: NSObject, ObservableObject {
//
//    @Published var unread: [RSSItem] = []
//    
//    let dataSource: RSSItemDataSource
//    var start = 0
//    
//    init(dataSource: RSSItemDataSource) {
//        self.dataSource = dataSource
//        super.init()
//    }
//    
//    func loadMore() {
//        start = unread.count
//        fecthResults(start: start)
//    }
//    
//    func fecthResults(start: Int = 0) {
//        if start == 0 {
//            unread.removeAll()
//        }
//        dataSource.performFetch(RSSItem.requestUnreadObjects(start: start))
//        if let objects = dataSource.fetchedResult.fetchedObjects {
//            unread.append(contentsOf: objects)
//        }
//    }
//    
//    func markAsRead(_ unreadItem: RSSItem) {
//        let updatedItem = dataSource.readObject(unreadItem)
//        updatedItem.isRead = false
//        updatedItem.updateTime = Date()
//        dataSource.setUpdateObject(updatedItem)
//        
//        let rs = dataSource.saveUpdateObject()
//        switch rs {
//        case .failed:
//            print("----> \(#function) failed")
//        case .saved:
//            unread.removeAll { unreadItem == $0 }
//        case .unchanged:
//            print("----> \(#function) unchanged")
//        }
//    }
//    
//    func unreadOrCancel(_ unread: RSSItem) {
//        let updatedItem = dataSource.readObject(unread)
//        updatedItem.isRead = !unread.isRead
//        updatedItem.updateTime = Date()
//        updatedItem.objectWillChange.send()
//        dataSource.setUpdateObject(updatedItem)
//        
//        _ = dataSource.saveUpdateObject()
//    }
//}
