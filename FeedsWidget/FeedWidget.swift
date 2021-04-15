//
//  FeedWidget.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 4/14/21.
//

import SwiftUI
import WidgetKit
import CoreData
import Combine
import KingfisherSwiftUI

final class FeedProvider: TimelineProvider {
    public typealias Entry = RSSFeedViewModel

    let dataSource: RSSItemDataSource
    let rss: RSS
    
    var snapshotCancellable: AnyCancellable?
    var timelineCancellable: AnyCancellable?

    private var entryPublisher: AnyPublisher<Entry, Never>
    
    init(rss: RSS, dataSource: RSSItemDataSource, entryPublisher: Any) {
        self.dataSource = dataSource
        self.rss = rss
        self.entryPublisher = entryPublisher as! AnyPublisher<FeedProvider.Entry, Never>
    }

    func placeholder(in with: Context) -> RSSFeedViewModel {
        RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem)
    }

    func getSnapshot(in context: Context, completion: @escaping (RSSFeedViewModel) -> Void) {
        snapshotCancellable = entryPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: completion)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RSSFeedViewModel>) -> Void) {
        timelineCancellable = entryPublisher
            .map { Timeline(entries: [$0], policy: .atEnd) }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: completion)
    }
}

extension RSSFeedViewModel: TimelineEntry {
    var date: Date {
        items.last?.createTime?.addingTimeInterval(1) ?? Date()
    }
}

struct FeedEntry: TimelineEntry {
    let date: Date
    var items: RSSItem
    
}

struct FeedsEntryView: View {
    let entry: RSSFeedViewModel

    var body: some View {
        SmallFeedWidgetView(entry: entry, viewModel: entry).padding()
    }
}

struct SmallFeedWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    
    var entry: FeedProvider.Entry
    
    @ObservedObject var viewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    
    @ObservedObject var unreads = Unread(dataSource: DataSourceService.current.rssItem)
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("launch")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(0.4).padding([.top, .leading], -25)
                .frame(width: 100, height: 100)
            
            VStack(alignment: .leading) {
                Spacer(minLength: 0)
                VStack(alignment: .leading) {


                    ForEach(unreads.items, id: \.self) { entry in
                        HStack {
                            unreadImage
                            VStack(alignment: .leading) {
                                Text("\(entry.createTime?.string() ?? "")")
                                    .textCase(.uppercase)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray)
                                    .opacity(0.8)
                                Text(entry.title)
                            }
                        }
                    }
                }
                .onAppear {
                    self.unreads.fecthResults()
                }
            }.background(Color(UIColor.systemBackground).blur(radius: 10.0).opacity(0.5))
        }
    }
    var unreadImage: some View {
        Image(systemName: "largecircle.fill.circle")
            .resizable()
            .frame(width: 15, height: 15, alignment: .top)
            .foregroundColor(.gray)
    }
    
    func maxCount() -> Int {
        var reduceAccessibilityCount: Int = 0
        if SizeCategories().isSizeCategoryLarge(category: sizeCategory) {
            reduceAccessibilityCount = 1
        }
        
        if family == .systemLarge {
            return entry.items.count >= 7 ? (7 - reduceAccessibilityCount) : entry.items.count
        }
        return entry.items.count >= 3 ? (3 - reduceAccessibilityCount) : entry.items.count
    }
    
    var inboxZero: some View {
        VStack(alignment: .center) {
            Spacer()
//            Image(systemName: "largecircle.fill.circle")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .foregroundColor(.gray)
//                .frame(width: 30)
            Text("\(unreads.items.count) Unread")
                .font(.title3)
                .bold()
                .padding(.leading, 50)
                .foregroundColor(Color("text"))
            Text(L10n.unreadWidgetNoItemsTitle)
                .font(.headline)
                .foregroundColor(.gray)

            Text(L10n.unreadWidgetNoItems)
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

struct FeedWidget: Widget {
    let kind: String = "group.com.tylerdlawrence.feedit.FeedWidget"
    
    let entry = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    
    var body: some WidgetConfiguration {
        return StaticConfiguration(kind: kind, provider: FeedProvider(rss: RSS(), dataSource: DataSourceService.current.rssItem, entryPublisher: entry), content: { entry in
            FeedsEntryView(entry: entry)
//                .environmentObject(entry)
//                .background(Color("WidgetBackground"))

        })
        .configurationDisplayName(L10n.unreadWidgetTitle)
        .description(L10n.unreadWidgetDescription)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])

    }
}

struct FeedWidget_Previews: PreviewProvider {
    static var previews: some View {
        FeedsEntryView(entry: RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
        FeedsEntryView(entry: RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        FeedsEntryView(entry: RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem))
            .previewContext(WidgetPreviewContext(family: .systemLarge))

    }
}
