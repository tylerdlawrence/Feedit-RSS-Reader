//
//  RSSStore.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import FeedKit
import Combine
import BackgroundTasks
import CoreData
import Foundation
import FaviconFinder

//class RSSStore: NSObject {
class RSSStore: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    //NSFetchedResultsControllerDelegate {
    
    static let instance = RSSStore()
    
    @Published var rss: [RSS] = []
    @Published var shouldSelectFeedURL: String?
    @Published var shouldOpenSettings: Bool = false
    @Published var notificationsEnabled: Bool = false
    @Published var fetchContentTime: String = ContentTimeType.minute60.rawValue
    @Published var fetchContentType: ContentTimeType = .minute60
    @Published var totalUnreadPosts: Int = 0
    @Published var totalReadPostsToday: Int = 0
    @Published var shouldReload = false

    var cancellables = Set<AnyCancellable>()
    
    public func createAndSave(url: String, title: String = "", desc: String = "") -> RSS {
        let rss = RSS.create(
            url: url,
            title: title,
            desc: desc,
            in: context
        )
        saveChanges()
        return rss
    }

    public func delete(_ object: RSS) {
        context.delete(object)
        saveChanges()
    }

    public func update(_ item: RSS) {
        do {
            try update(RSS: item)
        } catch let error {
            print("\(#function) error = \(error)")
        }
    }

    private func update(RSS item: RSS) throws {
        guard let uuid = item.uuid else {
            return
        }
        let fetchRequest: NSFetchRequest<RSS> = RSS.fetchRequest()
        let predicate = NSPredicate(format: "uuid = %@", argumentArray: [uuid])
        fetchRequest.predicate = predicate
        do {
            let rs = try fetchedResultsController.managedObjectContext.fetch(fetchRequest)
            if let rss = rs.first {
                rss.title = item.title
                rss.desc = item.desc
                rss.url = item.url
                rss.lastFetchTime = item.lastFetchTime
                rss.createTime = item.createTime
                rss.updateTime = Date()
                saveChanges()
            } else {
                // TODO: throw Error
            }
        } catch let error {
            throw error
        }
    }
    
    private let persistence = Persistence.current

    private lazy var fetchedResultsController: NSFetchedResultsController<RSS> = {
        let fetchRequest: NSFetchRequest<RSS> = RSS.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createTime", ascending: false)]
        
        let fetechedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: persistence.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetechedResultsController.delegate = self
        return fetechedResultsController
    }()
    
    var context: NSManagedObjectContext {
        return persistence.context
    }

    let didChange = PassthroughSubject<RSSStore, Never>()

    public var items: [RSS] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    public var rssSources: [RSS] = []
    
    private func fetchRSS() {
        do {
            try fetchedResultsController.performFetch()
            dump(fetchedResultsController.sections)
        } catch {
            fatalError()
        }
    }
    
    func saveChanges() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func addFeedFromExtension(url: URL) {
        UserDefaults.newFeedsToAdd = UserDefaults.newFeedsToAdd + [url]
    }
    func reloadAllPosts(handler: (() -> Void)? = nil) {
        var updatedCount = 0
        for _ in self.rssSources {
            print("RELOADING POST")

            reloadAllPosts()
                print("GOT POST")

                updatedCount += 1
                if updatedCount >= self.items.count {
                    handler?()
                }
            }
        }
//}
}

//extension RSSStore: ObservableObject {
//
//}
//
//extension RSSStore: NSFetchedResultsControllerDelegate {
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        didChange.send(self)
//    }
//}

class ItemObject: Identifiable, ObservableObject {
    var id = UUID()
    var name: String
    var url: URL
    var items: [RSS] {
        didSet {
            objectWillChange.send()
        }
    }
    
    var imageURL: URL?
    
    var lastUpdateDate: Date
    
    init(name: String, url: URL, items: [RSS]) {
        self.name = name
        self.url = url
        self.items = items
        lastUpdateDate = Date()
    }
}

enum ContentTimeType: String, CaseIterable {
    case minute60 = "1 hour"
    case minute120 = "2 hours"
    case hour12 = "12 hours"
    case hour24 = "1 day"

    var seconds: Int {
        switch self {
            
        case .minute60:
            return 60 * 60
        case .minute120:
            return 120 * 60
        case .hour12:
            return 12 * 60 * 60
        case .hour24:
            return 24 * 60 * 60
        }
    }
}



//// MARK: - Public Methods
//extension RSSStore {
//
//    func reloadAllPosts(handler: (() -> Void)? = nil) {
//        var updatedCount = 0
//        for _ in self.rssSources {
//            print("RELOADING POST")
//
//            reloadAllPosts()
//                print("GOT POST")
//
//                updatedCount += 1
//                if updatedCount >= self.items.count {
//                    handler?()
//                }
//            }
//        }
//    }

//private let persistence = Persistence.current
//
//private lazy var fetchedResultsController: NSFetchedResultsController<RSS> = {
//    let fetchRequest: NSFetchRequest<RSS> = RSS.fetchRequest()
//    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createTime", ascending: false)]
//
//    let fetechedResultsController = NSFetchedResultsController(
//        fetchRequest: fetchRequest,
//        managedObjectContext: persistence.context,
//        sectionNameKeyPath: nil,
//        cacheName: nil)
//    fetechedResultsController.delegate = self
//    return fetechedResultsController
//}()

//var context: NSManagedObjectContext {
//    return persistence.context
//}
//
//let didChange = PassthroughSubject<RSSStore, Never>()
//
//public var items: [RSS] {
//    return fetchedResultsController.fetchedObjects ?? []
//}

// rssSrouces
//public var rssSources: [RSS] = []

//    override init() {
//        super.init()
//        fetchRSS()
//        self.rssSources = items;
//    }

//public func createAndSave(url: String, title: String = "", desc: String = "") -> RSS {
//    let rss = RSS.create(
//        url: url,
//        title: title,
//        desc: desc,
//        in: context
//    )
//    saveChanges()
//    return rss
//}
//
//public func delete(_ object: RSS) {
//    context.delete(object)
//    saveChanges()
//}
//
//public func update(_ item: RSS) {
//    do {
//        try update(RSS: item)
//    } catch let error {
//        print("\(#function) error = \(error)")
//    }
//}
//
//private func update(RSS item: RSS) throws {
//    guard let uuid = item.uuid else {
//        return
//    }
//    let fetchRequest: NSFetchRequest<RSS> = RSS.fetchRequest()
//    let predicate = NSPredicate(format: "uuid = %@", argumentArray: [uuid])
//    fetchRequest.predicate = predicate
//    do {
//        let rs = try fetchedResultsController.managedObjectContext.fetch(fetchRequest)
//        if let rss = rs.first {
//            rss.title = item.title
//            rss.desc = item.desc
//            rss.url = item.url
//            rss.lastFetchTime = item.lastFetchTime
//            rss.createTime = item.createTime
//            rss.updateTime = Date()
//            saveChanges()
//        } else {
//            // TODO: throw Error
//        }
//    } catch let error {
//        throw error
//    }
//}

//private func fetchRSS() {
//    do {
//        try fetchedResultsController.performFetch()
//        dump(fetchedResultsController.sections)
//    } catch {
//        fatalError()
//    }
//}

//func saveChanges() {
//    guard context.hasChanges else { return }
//    do {
//        try context.save()
//    } catch {
//        print(error)
//    }
//}
