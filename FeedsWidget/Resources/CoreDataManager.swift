//
//  CoreDataManager.swift
//  FeedsWidgetExtension
//
//  Created by Tyler D Lawrence on 4/13/21.
//

import Foundation
import WidgetKit
import SwiftUI
import Combine
import Intents
import CoreData
import OSLog

class CoreDataManager {
    var items = [RSSItem]()
    let dataController: DataController

    private var observers = [NSObjectProtocol]()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        for _ in 0..<3 {
            let newItem = RSSItem(context: viewContext)
            newItem.title = "Article Title"
            newItem.desc = "Article description"
            newItem.author = "Tyler Lawrence"
            newItem.createTime = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    init(_ dataController: DataController) {
        self.dataController = dataController
        fetchArticles()

        /// Add Observer to observe CoreData changes and reload data
        observers.append(
            NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: .main) { _ in //swiftlint:disable:this line_length discarded_notification_center_observer
                self.fetchArticles()
            }
        )
    }

    deinit {
        /// Remove Observer when CoreDataManager is de-initialized
        observers.forEach(NotificationCenter.default.removeObserver)
    }

    /// Fetches all  from CoreData
    func fetchArticles() {
        defer {
            WidgetCenter.shared.reloadAllTimelines()
        }

        dataController.persistentContainer.viewContext.refreshAllObjects()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RSSItem")

        do {
            guard let items = try dataController.persistentContainer.viewContext.fetch(fetchRequest) as? [RSSItem] else {
                return
            }
            self.items = items
        } catch {
            print("Failed to fetch: \(error)")
        }
    }
}

class DataController: ObservableObject {
    public static let shared = DataController()
    
    var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    var workingContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = managedObjectContext
        return context
    }

    var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "RSS")

        let storeURL = URL.storeURL(for: "group.com.tylerdlawrence.feedit.shared", databaseName: "RSS")
        let description = NSPersistentStoreDescription(url: storeURL)

        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                print(error)
            }
        })

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

        return container
    }()
}

struct WidgetDataDecoder {
    
    static func decodeWidgetData() throws -> WidgetData {
        let appGroup = Bundle.main.object(forInfoDictionaryKey: "AppGroup") as! String
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)
        let dataURL = containerURL?.appendingPathComponent("widget-data.json")
        if FileManager.default.fileExists(atPath: dataURL!.path) {
            let decodedWidgetData = try JSONDecoder().decode(WidgetData.self, from: Data(contentsOf: dataURL!))
            return decodedWidgetData
        } else {
            return WidgetData(currentUnreadCount: 0, currentTodayCount: 0, currentStarredCount: 0, unreadArticles: [], starredArticles: [], todayArticles: [], lastUpdateTime: Date())
        }
    }
    
    static func sampleData() -> WidgetData {
        let pathToSample = Bundle.main.url(forResource: "widget-sample", withExtension: "json")
        do {
            let data = try Data(contentsOf: pathToSample!)
            let decoded = try JSONDecoder().decode(WidgetData.self, from: data)
            return decoded
        } catch {
            return WidgetData(currentUnreadCount: 0, currentTodayCount: 0, currentStarredCount: 0, unreadArticles: [], starredArticles: [], todayArticles: [], lastUpdateTime: Date())
        }
    }
}
