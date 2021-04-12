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

// MARK: - Supported Widgets

struct UnreadWidget: Widget {
    let kind: String = "group.com.tylerdlawrence.feedit.UnreadWidget"

    var body: some WidgetConfiguration {

        return StaticConfiguration(kind: kind, provider: Provider(context: managedObjectContext), content: { entry in
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
    let kind: String = "group.com.tylerdlawrence.feedit.AllArticlesWidget"

    var body: some WidgetConfiguration {

        return StaticConfiguration(kind: kind, provider: Provider(context: managedObjectContext), content: { entry in
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
    let kind: String = "group.com.tylerdlawrence.feedit.StarredWidget"

    var body: some WidgetConfiguration {

        return StaticConfiguration(kind: kind, provider: Provider(context: managedObjectContext), content: { entry in
            StarredWidgetView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("WidgetBackground"))

        })
        .configurationDisplayName(L10n.starredWidgetTitle)
        .description(L10n.starredWidgetDescription)
        .supportedFamilies([.systemMedium, .systemLarge])

    }
}

struct SmartFeedSummaryWidget: Widget {
    let kind: String =  "group.com.tylerdlawrence.feedit.FeedsWidget"
    
    @State var selectedFilter: FilterType = .all
    @ObservedObject var rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    @ObservedObject var archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    @ObservedObject var articles = AllArticles(dataSource: DataSourceService.current.rssItem)
    @ObservedObject var unread = Unread(dataSource: DataSourceService.current.rssItem)
    
    var body: some WidgetConfiguration {
        return StaticConfiguration(kind: kind, provider: Provider(context: Persistence.current.context), content: { entry in
            SmartFeedsView(entry: WidgetTimelineEntry(date: Date(), widgetData: WidgetData(currentUnreadCount: unread.items.count, currentTodayCount: articles.items.count, currentStarredCount: archiveListViewModel.items.count, unreadArticles: [], starredArticles: [], todayArticles: [], lastUpdateTime: Date())))
                
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("WidgetBackground"))
                .environment(\.managedObjectContext, Persistence.current.context)
                .environmentObject(DataSourceService.current.rss)
                .environmentObject(DataSourceService.current.rssItem)
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
        AllArticlesWidget()
        UnreadWidget()
        StarredWidget()
    }
}
