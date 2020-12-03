//
//  ArchiveListViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation


class ArchiveListViewModel: NSObject, ObservableObject {

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
    
    func fecthResults(start: Int = 0) {
        if start == 0 {
            items.removeAll()

        }
        dataSource.performFetch(RSSItem.requestArchiveObjects(start: start))
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

//class Source: Identifiable, Codable {
//    var id = UUID()
//    var title = "Anonymous"
//    var desc = ""
//    fileprivate(set) var isStarred = false
//}
//
//class Sources: ObservableObject {
//    @Published private(set) var sources: [Source]
//    static let saveKey = "SavedData"
//
//    init() {
//        if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
//            if let decoded = try? JSONDecoder().decode([Source].self, from: data) {
//                self.sources = decoded
//                return
//            }
//        }
//
//        self.sources = []
//    }
//
//    private func save() {
//        if let encoded = try? JSONEncoder().encode(sources) {
//            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
//        }
//    }
//
//    func add(_ source: Source) {
//        sources.append(source)
//        save()
//    }
//
//    func toggle(_ source: Source) {
//        objectWillChange.send()
//        source.isStarred.toggle()
//        save()
//    }
//}
//
//
