//
//  RecentArticleWidget.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 4/13/21.
//

import SwiftUI
import WidgetKit
import CoreData
import Intents
import KingfisherSwiftUI
import Foundation
import Combine

struct RecentArticleWidgetEntryView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var size
    var body: some View {
        VStack(alignment: .leading) {
            switch size {
            case .systemSmall:
                SmallRecentArticleWidgetView(entry: entry)
            case .systemMedium:
                MediumRecentArticleWidgetView(entry: entry)
            case .systemLarge:
                LargeRecentArticleWidgetView(entry: entry)
            @unknown default:
                SmallRecentArticleWidgetView(entry: entry)
            }
        }.padding()
    }
}

struct SmallRecentArticleWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    var entry: Provider.Entry
    
    @FetchRequest(entity: RSSItem.entity(), sortDescriptors: []) private var items: FetchedResults<RSSItem>
    
    @State private var feeds = RSSItem.requestUnreadObjects()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 2) {
                SmallArticleItemView(article: entry.widgetData.todayArticles[0],
                                deepLink: WidgetDeepLink.todayArticle(id: entry.widgetData.todayArticles[0].id).url)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                    
            .background(Color(UIColor.systemBackground).blur(radius: 10.0).opacity(0.3))
        }
    }
}

struct MediumRecentArticleWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    var entry: Provider.Entry
    
    @FetchRequest(entity: RSSItem.entity(), sortDescriptors: []) private var items: FetchedResults<RSSItem>
    
    @State private var feeds = RSSItem.requestUnreadObjects()
    
    var body: some View {
        HStack(alignment: .bottom) {
            Image("launch")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 30, height: 30)
                .padding([.top], 5)
        }
        Divider()
        if entry.widgetData.todayArticles.count == 0 {
            inboxZero
                .widgetURL(WidgetDeepLink.today.url)
        } else {
            ZStack(alignment: .topLeading) {
                VStack(alignment:.leading, spacing: 0) {
                    ForEach(0..<2, content: { i in
                        if i != 0 {
                            Divider()
                            ArticleItemView(article: entry.widgetData.todayArticles[i],
                                            deepLink: WidgetDeepLink.todayArticle(id: entry.widgetData.todayArticles[i].id).url)
                                .padding(.top, 8)
                                .padding(.bottom, 4)
                        } else {
                            ArticleItemView(article: entry.widgetData.todayArticles[i],
                                            deepLink: WidgetDeepLink.todayArticle(id: entry.widgetData.todayArticles[i].id).url)
                        }
                    })
                }
                .padding()
                .overlay(
                     VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            if entry.widgetData.currentTodayCount - maxCount() > 0 {
                                Text(L10n.todayCount(entry.widgetData.currentTodayCount - maxCount()))
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 6)
            )
        }.background(Color(UIColor.systemBackground).blur(radius: 10.0).opacity(0.5))
            .widgetURL(WidgetDeepLink.today.url)
        }
    }
    
    func maxCount() -> Int {
        var reduceAccessibilityCount: Int = 0
        if SizeCategories().isSizeCategoryLarge(category: sizeCategory) {
            reduceAccessibilityCount = 1
        }
        
        if family == .systemLarge {
            return entry.widgetData.todayArticles.count >= 7 ? (7 - reduceAccessibilityCount) : entry.widgetData.todayArticles.count
        }
        return entry.widgetData.todayArticles.count >= 3 ? (3 - reduceAccessibilityCount) : entry.widgetData.todayArticles.count
    }
    var inboxZero: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment:.leading, spacing: 0) {
                Text("The first redacted title").font(.subheadline).redacted(reason: .placeholder)
                HStack(alignment: .center, spacing: 4.0) {
                    Text("by").font(.caption).redacted(reason: .placeholder)
                    Text("author").font(.caption).redacted(reason: .placeholder)
                    Text("some time ago").font(.caption).redacted(reason: .placeholder)
                    Spacer(minLength: 0)
                }
                Spacer()
                Text("A second redacted title goes here").font(.subheadline).redacted(reason: .placeholder)
                HStack(alignment: .center, spacing: 4.0) {
                    Text("by").font(.caption).redacted(reason: .placeholder)
                    Text("author").font(.caption).redacted(reason: .placeholder)
                    Text("some time ago").font(.caption).redacted(reason: .placeholder)
                }
            }
        }
    }
}

struct LargeRecentArticleWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    var entry: Provider.Entry

    @FetchRequest(entity: RSSItem.entity(), sortDescriptors: []) private var items: FetchedResults<RSSItem>
    
    @State private var feeds = RSSItem.requestUnreadObjects()

    var body: some View {
        HStack {
            Image("launch")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 30, height: 30)
            Spacer()
        }
        Divider()
        Spacer()
        if entry.widgetData.todayArticles.count == 0 {
            inboxZero
                .widgetURL(WidgetDeepLink.today.url)
        }
        else {
            ZStack(alignment: .topLeading) {
                Spacer()
                
                VStack(alignment:.leading, spacing: 0) {
                    ForEach(0..<maxCount(), content: { i in
                        if i != 0 {
                            Divider()
                            ArticleItemView(article: entry.widgetData.todayArticles[i],
                                            deepLink: WidgetDeepLink.todayArticle(id: entry.widgetData.todayArticles[i].id).url)
                                .padding(.top, 8)
                                .padding(.bottom, 4)
                        } else {
                            ArticleItemView(article: entry.widgetData.todayArticles[i],
                                            deepLink: WidgetDeepLink.todayArticle(id: entry.widgetData.todayArticles[i].id).url)
                                .padding(.bottom, 4)
                        }
                    })
                    Spacer()
                }
                .padding([.bottom, .trailing])
                .padding(.top, 12)
                .overlay(
                     VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            if entry.widgetData.currentTodayCount - maxCount() > 0 {
                                Text(L10n.todayCount(entry.widgetData.currentTodayCount - maxCount()))
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 6)
                )
            
            }.background(Color(UIColor.systemBackground).blur(radius: 10.0).opacity(0.5))
            .widgetURL(WidgetDeepLink.today.url)
        }
    }

    func maxCount() -> Int {
        var reduceAccessibilityCount: Int = 0
        if SizeCategories().isSizeCategoryLarge(category: sizeCategory) {
            reduceAccessibilityCount = 1
        }
        
        if family == .systemLarge {
            return entry.widgetData.todayArticles.count >= 7 ? (7 - reduceAccessibilityCount) : entry.widgetData.todayArticles.count
        }
        return entry.widgetData.todayArticles.count >= 3 ? (3 - reduceAccessibilityCount) : entry.widgetData.todayArticles.count
    }
    
    var inboxZero: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment:.leading, spacing: 0) {
                Text("The first redacted title").font(.subheadline).redacted(reason: .placeholder)
                HStack(alignment: .center, spacing: 4.0) {
                    Text("by").font(.caption).redacted(reason: .placeholder)
                    Text("author").font(.caption).redacted(reason: .placeholder)
                    Text("some time ago").font(.caption).redacted(reason: .placeholder)
                    Spacer(minLength: 0)
                }
                Spacer()
                Text("A second redacted title goes here").font(.subheadline).redacted(reason: .placeholder)
                HStack(alignment: .center, spacing: 4.0) {
                    Text("by").font(.caption).redacted(reason: .placeholder)
                    Text("author").font(.caption).redacted(reason: .placeholder)
                    Text("some time ago").font(.caption).redacted(reason: .placeholder)
                }
                Spacer()
                Text("A second redacted title goes here").font(.subheadline).redacted(reason: .placeholder)
                HStack(alignment: .center, spacing: 4.0) {
                    Text("by").font(.caption).redacted(reason: .placeholder)
                    Text("author").font(.caption).redacted(reason: .placeholder)
                    Text("some time ago").font(.caption).redacted(reason: .placeholder)
                }
            }
        }
    }
}

struct CountWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RecentArticleWidgetEntryView(entry: Provider.Entry.init(date: Date(), widgetData: WidgetDataDecoder.sampleData()))
                .background(Color(UIColor.systemBackground)).environment(\.colorScheme, .dark)
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            RecentArticleWidgetEntryView(entry: Provider.Entry.init(date: Date(), widgetData: WidgetDataDecoder.sampleData()))
                .background(Color(UIColor.systemBackground)).environment(\.colorScheme, .dark)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            RecentArticleWidgetEntryView(entry: Provider.Entry.init(date: Date(), widgetData: WidgetDataDecoder.sampleData()))
                .background(Color(UIColor.systemBackground)).environment(\.colorScheme, .dark)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            
        }.previewLayout(.sizeThatFits)
    }
}
