//
//  ArchiveListViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation
import CoreData

class ArchiveListViewModel: NSObject, ObservableObject {
    
//    var context:NSManagedObjectContext!

    @Published var items: [RSSItem] = []
    @Published var filteredArticles: [RSSItem] = []
//    @Published var filterType = FilterType.isArchive
    @Published var selectedPost: RSSItem?
    @Published var isArchive: Bool = true
    @Published var disabled = true
    @Published var selectedFilterToggle = 0
    func markAllPostsRead(item: RSSItem) {}
    
    @Published var message = String()
    @Published var shouldShowAlert = false
    
    let dataSource: RSSItemDataSource
    var start = 0
    
//    var archiveViewModel:ArchiveListViewModel!
    
    init(dataSource: RSSItemDataSource) {
        self.dataSource = dataSource
//        self.archiveViewModel = archiveViewModel
//        self.context = context
        super.init()
    }
//    , context:NSManagedObjectContext = Persistence.shared.context
//    deinit {
//        context = nil
//    }
    
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
    
    private func handleExisitingArticle() {
        self.shouldShowAlert = true
        self.message = "You already starred this article"
    }
    
    private func showAlertForAddedStar(success:Bool){
        self.shouldShowAlert = true
        self.message = success ? "Added to Starred" : "Error while attempting to star article"
    }
    
    private func showAlertForDeletedStar(success:Bool){
        self.shouldShowAlert = true
        self.message = success ? "Removed from Starred" : "Error deleting this article from starred"
    }
    
//    func isArticleExists(with URL:String) -> Bool{
//        return archiveViewModel.isArticleExists(with: URL)
//    }
    
//    func star(for rssItem:RSSItem, showAlert: Bool = false){
//        if isArticleExists(with: rssItem.url) {
//            handleExisitingArticle()
//            return
//        }
//        archiveViewModel.insert(item: rssItem) { [weak self] (success) in
//            guard let self = self else { return }
//            self.showAlertForAddedStar(success: success)
//        }
//    }
    
//    func insert(item: RSSItem, completion:((Bool)->Void)? = nil) {
//        guard let context = self.context else {
//            completion?(false)
//            return
//        }
//
//        do {
//            if context.hasChanges {
//                try context.save()
//                completion?(true)
//                return
//            }
//        }catch let error {
//            debugPrint(error)
//        }
//
//        completion?(false)
//    }
    
}
