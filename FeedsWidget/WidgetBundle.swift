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

struct UnreadWidget: Widget {
    let kind: String = "UnreadWidget"

    var body: some WidgetConfiguration {

        return StaticConfiguration(kind: kind, provider: Provider(), content: { entry in
            UnreadWidgetView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("WidgetBackground"))

        })
        .configurationDisplayName(L10n.unreadWidgetTitle)
        .description(L10n.unreadWidgetDescription)
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct AllArticlesWidget: Widget {
    let kind: String = "AllArticlesWidget"

    var body: some WidgetConfiguration {

        return StaticConfiguration(kind: kind, provider: Provider(), content: { entry in
            AllArticlesWidgetView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("WidgetBackground"))

        })
        .configurationDisplayName(L10n.todayWidgetTitle)
        .description(L10n.todayWidgetDescription)
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct StarredWidget: Widget {
    let kind: String = "StarredWidget"

    var body: some WidgetConfiguration {
        return StaticConfiguration(kind: kind, provider: Provider(), content: { entry in
            StarredWidgetView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("WidgetBackground"))
        })
        .configurationDisplayName(L10n.starredWidgetTitle)
        .description(L10n.starredWidgetDescription)
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct CountWidget: Widget {
    @Environment(\.widgetFamily) var family
    let kind: String = "CountWidget"
        
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountProvider(context: managedObjectContext)) { entry in
            CountWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Unread")
        .description("View your recent unread articles")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - WidgetBundle
@main
struct FeeditWidgets: WidgetBundle {

    @WidgetBundleBuilder
    var body: some Widget {
        TestWidget()
        CountWidget()
        SmartFeedSummaryWidget()
//        FeedWidget()
        
        
        
//        AllArticlesWidget()
//        UnreadWidget()
//        StarredWidget()
    }
}
