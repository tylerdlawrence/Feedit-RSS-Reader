//
//  WidgetBundle.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/24/21.
//

import SwiftUI
import WidgetKit
import CoreData
import Foundation
import Intents

// MARK: - Supported Widgets

//struct UnreadWidget: Widget {
//    let kind: String = "UnreadWidget"
//
//    var body: some WidgetConfiguration {
//
//        return StaticConfiguration(kind: kind, provider: Provider(), content: { entry in
//            UnreadWidgetView(entry: entry)
//
//        })
//        .configurationDisplayName(L10n.unreadWidgetTitle)
//        .description(L10n.unreadWidgetDescription)
//        .supportedFamilies([.systemMedium, .systemLarge])
//    }
//}
//
//struct AllArticlesWidget: Widget {
//    let kind: String = "AllArticlesWidget"
//
//    var body: some WidgetConfiguration {
//
//        return StaticConfiguration(kind: kind, provider: Provider(), content: { entry in
//            AllArticlesWidgetView(entry: entry)
//
//
//        })
//        .configurationDisplayName(L10n.todayWidgetTitle)
//        .description(L10n.todayWidgetDescription)
//        .supportedFamilies([.systemMedium, .systemLarge])
//    }
//}
//
//struct StarredWidget: Widget {
//    let kind: String = "StarredWidget"
//
//    var body: some WidgetConfiguration {
//        return StaticConfiguration(kind: kind, provider: Provider(), content: { entry in
//            StarredWidgetView(entry: entry)
//        })
//        .configurationDisplayName(L10n.starredWidgetTitle)
//        .description(L10n.starredWidgetDescription)
//        .supportedFamilies([.systemMedium, .systemLarge])
//    }
//}

struct RecentArticleWidget: Widget {
    @Environment(\.widgetFamily) var family
    let kind: String = "RecentArticleWidget"
        
    var body: some WidgetConfiguration {
        return StaticConfiguration(kind: kind, provider: Provider(), content: { entry in
            RecentArticleWidgetEntryView(entry: Provider.Entry.init(date: Date(), widgetData: WidgetDataDecoder.sampleData()))
//            RecentArticleWidgetEntryView(entry: entry)
        })
        .configurationDisplayName("Recent Articles")
        .description("View your recent articles")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct SmartFeedSummaryWidget: Widget {
    let kind: String = "SmartFeedSummaryWidget"
    
    var body: some WidgetConfiguration {
        
        return StaticConfiguration(kind: kind, provider: Provider(), content: { entry in
            SmartFeedSummaryWidgetView(entry: entry)
        })
        .configurationDisplayName(L10n.smartFeedSummaryWidgetTitle)
        .description(L10n.smartFeedSummaryWidgetDescription)
        .supportedFamilies([.systemSmall])
        
    }
}

// MARK: - WidgetBundle
@main
struct FeeditWidgets: WidgetBundle {

    @WidgetBundleBuilder
    var body: some Widget {
        SmartFeedSummaryWidget()
        RecentArticleWidget()
        //TestWidget()
    }
}
