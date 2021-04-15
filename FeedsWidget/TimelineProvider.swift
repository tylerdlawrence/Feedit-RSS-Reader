//
//  TimelineProvider.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/23/21.
//

import SwiftUI
import WidgetKit
import CoreData
import Foundation
import os.log
import UIKit
import Combine

struct WidgetData: Codable {
    let currentUnreadCount: Int
    let currentTodayCount: Int
    let currentStarredCount: Int
    
    let unreadArticles: [LatestArticle]
    let starredArticles: [LatestArticle]
    let todayArticles: [LatestArticle]
    let lastUpdateTime: Date
}

struct LatestArticle: Codable, Identifiable {
    
    var id: String
    let feedTitle: String
    let articleTitle: String?
    let articleSummary: String?
    let feedIcon: Data? // Base64 encoded image data
    let pubDate: String
    
}

var managedObjectContext: NSManagedObjectContext {
    return persistentContainer.viewContext
}

var workingContext: NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.parent = managedObjectContext
    return context
}

var persistentContainer: NSPersistentCloudKitContainer = {
    let container = NSPersistentCloudKitContainer(name: "feeditrssreader")

    let storeURL = URL.storeURL(for: "group.com.tylerdlawrence.feedit.shared", databaseName: "feeditrssreader")
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

struct Provider: TimelineProvider {
    
//    var moc = managedObjectContext
//
//    init(context : NSManagedObjectContext) {
//        self.moc = context
//    }

    func placeholder(in context: Context) -> WidgetTimelineEntry {
        let currentDate = Date()
        let entryDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        return WidgetTimelineEntry(date: entryDate, widgetData: WidgetData(currentUnreadCount: 50, currentTodayCount: 125, currentStarredCount: 10, unreadArticles: [], starredArticles: [], todayArticles: [], lastUpdateTime: Date()))
            
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WidgetTimelineEntry) -> Void) {
        if context.isPreview {
            var entries: [WidgetTimelineEntry] = []
            let currentDate = Date()
            let entryDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
            let entry = WidgetTimelineEntry(date: entryDate, widgetData: WidgetData(currentUnreadCount: 50, currentTodayCount: 125, currentStarredCount: 10, unreadArticles: [], starredArticles: [], todayArticles: [], lastUpdateTime: Date()))
                    entries.append(entry)

            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetTimelineEntry>) -> Void) {
        let date = Date()
        var entry: WidgetTimelineEntry

        entry = WidgetTimelineEntry(date: date, widgetData: WidgetData(currentUnreadCount: 50, currentTodayCount: 125, currentStarredCount: 10, unreadArticles: [], starredArticles: [], todayArticles: [], lastUpdateTime: Date()))

        // Configure next update in 1 hour.
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: date)!

        let timeline = Timeline(
            entries:[entry],
            policy: .after(nextUpdateDate))
        completion(timeline)
    }
    
    public typealias Entry = WidgetTimelineEntry
    
}

struct WidgetTimelineEntry: TimelineEntry {
    public let date: Date
    public let widgetData: WidgetData
}

