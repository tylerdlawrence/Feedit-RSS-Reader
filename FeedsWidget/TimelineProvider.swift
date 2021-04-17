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

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> WidgetTimelineEntry {
        do {
            let data = try WidgetDataDecoder.decodeWidgetData()
            return WidgetTimelineEntry(date: Date(), widgetData: data)
        } catch {
            return WidgetTimelineEntry(date: Date(), widgetData: WidgetDataDecoder.sampleData())
        }
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WidgetTimelineEntry) -> Void) {
        if context.isPreview {
            do {
                let data = try WidgetDataDecoder.decodeWidgetData()
                completion(WidgetTimelineEntry(date: Date(), widgetData: data))
            } catch {
                completion(WidgetTimelineEntry(date: Date(),
                                               widgetData: WidgetDataDecoder.sampleData()))
            }
        } else {
            do {
                let widgetData = try WidgetDataDecoder.decodeWidgetData()
                let entry = WidgetTimelineEntry(date: Date(), widgetData: widgetData)
                completion(entry)
            } catch {
                let entry = WidgetTimelineEntry(date: Date(),
                                                widgetData: WidgetDataDecoder.sampleData())
                completion(entry)
            }
        }
    }
   
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetTimelineEntry>) -> Void) {
        let date = Date()
        var entry: WidgetTimelineEntry

        entry = WidgetTimelineEntry(date: date, widgetData: WidgetData(currentUnreadCount: 0, currentTodayCount: 0, currentStarredCount: 0, unreadArticles: [], starredArticles: [], todayArticles: [], lastUpdateTime: Date()))
        
//        do {
//            let widgetData = try WidgetDataDecoder.decodeWidgetData()
//            entry = WidgetTimelineEntry(date: date, widgetData: widgetData)
//        } catch {
//            entry = WidgetTimelineEntry(date: date, widgetData: WidgetData(currentUnreadCount: 0, currentTodayCount: 0, currentStarredCount: 0, unreadArticles: [], starredArticles: [], todayArticles: [], lastUpdateTime: Date()))
//        }

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

