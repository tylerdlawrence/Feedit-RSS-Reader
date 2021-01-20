//
//  RSSItemStore.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation
import Combine
import CoreData
import FeedKit
import SwiftUI

class RSSItemStore: NSObject, ObservableObject {
//    var id = UUID()
//    var title: String
//    var desc: String
//    var url: URL
//    var date: Date
//    var lastUpdateDate: Date
   
    private let persistence = Persistence.current
    
    static let instance = RSSItemStore()
    
    var isRead: Bool {
        return readDate != nil
    }
    
    var readDate: Date? {
        didSet {
            objectWillChange.send()
        }
    }

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
    
    var context: NSManagedObjectContext {
        return persistence.context
    }
    
    let didChange = PassthroughSubject<RSSItemStore, Never>()
    
    override init() {
        super.init()
        fetchRSS()
    }
    
    public func createAndSave(rss uuid: UUID, isDone: Bool, isRead: Bool, imageURL: String, title: String, desc: String, author: String, url: String, createTime: Date) -> RSSItem {
        let item = RSSItem.create(uuid: uuid, isDone: isDone, isRead: isRead, imageURL: imageURL, title: title, desc: desc, author: author, url: url, createTime: createTime,
                                  in: persistence.context)
        saveChanges()
        return item
    }
    
    public func batchInsert(items: [RSSItem]) {
        items.forEach { item in
            item.didSave()
        }
    }
    
    public func fetchRSSItem(RSS item: RSS, start: Int, limit: Int = 20) throws -> [RSSItem] {
        guard let uuid = item.uuid else {
            throw RSSError.invalidParameter
        }
        let fetchRequest: NSFetchRequest<RSSItem> = RSSItem.fetchRequest()
        let predicate = NSPredicate(format: "rssUUID = %@", argumentArray: [uuid])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createTime", ascending: false)]
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = limit
        fetchRequest.fetchOffset = start
        
        do {
            let rs = try fetchedResultsController.managedObjectContext.fetch(fetchRequest)
            rs.forEach { item in
                print("item created time = \(String(describing: item.createTime))")
            }
            return rs
        } catch let error {
            throw error
        }
    }
    
    private func fetchRSS() {
        do {
            try fetchedResultsController.performFetch()
            dump(fetchedResultsController.sections)
        } catch {
            fatalError()
        }
    }
    
    private func saveChanges() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch { fatalError() }
    }
}

extension RSSItemStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        didChange.send(self)
    }
}

class AllArticlesStorage: NSObject, ObservableObject {
    
  @Published var articles: [RSSItem] = []
  private let articlesFetchedResultsController: NSFetchedResultsController<RSSItem>

  init(managedObjectContext: NSManagedObjectContext) {
    articlesFetchedResultsController = NSFetchedResultsController(fetchRequest: RSSItem.fetchRequest(),
    managedObjectContext: managedObjectContext,
    sectionNameKeyPath: nil, cacheName: nil)

    super.init()

    articlesFetchedResultsController.delegate = self
    
    
    
    func fetchAllArticles(RSS item: RSS, start: Int, limit: Int = 100) throws -> [RSSItem] {
        guard let uuid = item.uuid else {
            throw RSSError.invalidParameter
        }
        let fetchRequest: NSFetchRequest<RSSItem> = RSSItem.fetchRequest()
        let predicate = NSPredicate(format: "rssUUID = %@", argumentArray: [uuid])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = limit
        fetchRequest.fetchOffset = start
        do {
            let rs = try articlesFetchedResultsController.managedObjectContext.fetch(fetchRequest)
            rs.forEach { item in
                print("title = \(String(describing: item.title))")
            }
            return rs
        } catch let error {
            throw error
        }
    }
    
    


    do {
      try articlesFetchedResultsController.performFetch()
      articles = articlesFetchedResultsController.fetchedObjects ?? []
    } catch {
      print("failed to fetch items!")
    }
  }
}

extension AllArticlesStorage: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    guard let rssItem = controller.fetchedObjects as? [RSSItem]
      else { return }

    articles = rssItem
  }
}
