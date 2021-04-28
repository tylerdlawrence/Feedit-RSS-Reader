//
//  RSSListViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import Foundation
import Combine
import CoreData
import UIKit

class RSSListViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    
    @ObservedObject var store = RSSStore.instance

    @Published var isOn = false
    @Published var unreadIsOn = false
    @Published var items: [RSS] = []
    
    //@Published var feeds: [FeedObject] = []
    @Published var shouldSelectFeedObject: RSS?
    @Published var shouldSelectFeed = false
    @Published var shouldPresentDetail = false
    @Published var shouldSelectFeedURL: String?
    @Published var shouldOpenSettings: Bool = false
    @Published var notificationsEnabled: Bool = false
    @Published var fetchContentTime: String = ContentTimeType.minute60.rawValue
    @Published var fetchContentType: ContentTimeType = .minute60
    @Published var totalUnreadPosts: Int = 0
    @Published var totalReadPostsToday: Int = 0
    @Published var isSheetPresented = false
    var cancellables = Set<AnyCancellable>()
    
    @Published var loading: Bool = true
    @Published var error: RSSError?
    

    
    var articles = RSSItem() { didSet { didChange.send() } }
    var feed: RSS? { didSet { didChange.send() } }
    let didChange = PassthroughSubject<Void, Never>()
    
    
    
    var subscriptions: Set<AnyCancellable> = []
    let dataSource: RSSDataSource
    var start = 0
    
    init(dataSource: RSSDataSource) {
        self.dataSource = dataSource
        super.init()
        
        //fetchInfo()
        //fecthResults(start: start)
    }
    
    private let persistence = Persistence.current
    
    private lazy var fetchedResultsController: NSFetchedResultsController<RSSItem> = {
        let fetchRequest: NSFetchRequest<RSSItem> = RSSItem.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createTime", ascending: false)]
        
        let fetechedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: persistence.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetechedResultsController.delegate = self
        return fetechedResultsController
    }()
    
    public func fetchRSSItem(RSS item: RSS, start: Int) throws -> [RSSItem] {
        guard let uuid = item.uuid else {
            throw RSSError.invalidParameter
        }
        let fetchRequest: NSFetchRequest<RSSItem> = RSSItem.fetchRequest()
        let predicate = NSPredicate(format: "rssUUID = %@", argumentArray: [uuid])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createTime", ascending: false)]
        fetchRequest.predicate = predicate
        fetchRequest.fetchOffset = start
        do {
            let rs = try fetchedResultsController.managedObjectContext.fetch(fetchRequest)
            rs.forEach { item in
                print("item created time = \(String(describing: item))")
            }
            return rs
        } catch let error {
            throw error
        }
    }
    
    func fetchInfo() {
        self.items = store.items
        
        store.$feeds
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (newValue) in
                self.items = newValue
            })
            .store(in: &cancellables)
        
        Publishers.CombineLatest(store.$shouldSelectFeedURL, store.$shouldOpenSettings)
            .receive(on: DispatchQueue.main)
            .map { (newValue) -> (RSS?, Bool) in
                guard let url = newValue.0 else {
                    return (nil, newValue.1)
                }
                return (self.items.first(where: {$0.url == url }), newValue.1)
            }
            .removeDuplicates(by: { (lhs, rhs) -> Bool in
                return lhs.0?.url != rhs.0?.url && lhs.1 != rhs.1
            })
            .sink(receiveValue: { (newValue) in
                self.shouldSelectFeedObject = newValue.0
                self.shouldSelectFeed = newValue.0 != nil
                self.shouldOpenSettings = newValue.1
                self.isSheetPresented = self.shouldSelectFeed || self.shouldOpenSettings
                print("present∂etail: \(self.isSheetPresented)")
                self.objectWillChange.send()
            })
            .store(in: &cancellables)
    }

    func loadMore() {
        start = items.count
        fecthResults(start: start)
    }
    
    var rss = RSS()

    func fecthResults(start: Int = 0) {
        if start == 0 {
            items.removeAll()
        }
        dataSource.performFetch(RSS.requestObjects())
        if let objects = dataSource.fetchedResult.fetchedObjects {
            items.append(contentsOf: objects)
        }
    }

    //MARK: context menu action for delete
    func delete(rss: RSS) {
        if let index = self.items.firstIndex(where: { $0.uuid == rss.uuid }) {
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
    
    func removeFeed(index: Int) {
        self.store.removeFeed(at: index)
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
