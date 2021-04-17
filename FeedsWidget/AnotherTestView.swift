//
//  FeedsWidget.swift
//  FeedsWidget
//
//  Created by Tyler D Lawrence on 3/23/21.
//

import WidgetKit
import SwiftUI
import Intents
import CoreData
import KingfisherSwiftUI

struct AnotherTestView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    var entry: AnotherTestProvider.Entry
    
    @ObservedObject var unreads = Unread(dataSource: DataSourceService.current.rssItem)
    
    var body: some View {
        VStack(alignment:.leading, spacing: 0) {
            ForEach(0..<maxCount(), content: { i in
                ArticleTestItemView(article: entry.items[i].self,
                                deepLink: entry.items[i].thumbnailURL)
                
            })
        }
        .onAppear {
            self.unreads.fecthResults()
        }
    }
    func maxCount() -> Int {
        var reduceAccessibilityCount: Int = 0
        if SizeCategories().isSizeCategoryLarge(category: sizeCategory) {
            reduceAccessibilityCount = 1
        }
        
        if family == .systemLarge {
            return unreads.items.count >= 7 ? (7 - reduceAccessibilityCount) : unreads.items.count
        }
        return unreads.items.count >= 3 ? (3 - reduceAccessibilityCount) : unreads.items.count
    }
}

struct AnotherTestView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AnotherTestView(entry: AnotherTestEntry(date: Date(), items: []))
                .background(Color(UIColor.systemBackground)).environment(\.colorScheme, .dark)
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            AnotherTestView(entry: AnotherTestEntry(date: Date(), items: []))
                .background(Color(UIColor.systemBackground)).environment(\.colorScheme, .dark)
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            AnotherTestView(entry: AnotherTestEntry(date: Date(), items: []))
                .background(Color(UIColor.systemBackground)).environment(\.colorScheme, .dark)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            
        }.previewLayout(.sizeThatFits)
    }
}

struct ArticleTestItemView: View {
    
    var article: RSSItem
    var deepLink: URL
    
    var body: some View {
        Link(destination: deepLink, label: {
            HStack(alignment: .top, spacing: nil, content: {
                // Feed Icon
                Image("getInfo")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .cornerRadius(4)
                
                // Title and Feed Name
                VStack(alignment: .leading) {
                    Text(article.title)
                        .font(.footnote)
                        .bold()
                        .lineLimit(1)
                        .foregroundColor(.primary)
                        .padding(.top, -3)
                    
                    HStack {
                        Text(article.author)
                            .font(.caption)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(pubDate((article.createTime?.string())!))
                            .font(.caption)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                }
            })
        })
    }
    
    func thumbnail(_ data: Data?) -> UIImage {
        if data == nil {
            return UIImage(systemName: "getInfo")!
        } else {
            return UIImage(data: data!)!
        }
    }
    
    func pubDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        guard let date = dateFormatter.date(from: dateString) else {
            return ""
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none
        
        return displayFormatter.string(from: date)
    }
}

struct AnotherTestProvider: TimelineProvider {
    @ObservedObject var unreads = Unread(dataSource: DataSourceService.current.rssItem)

    let dataController = DataController()
    let coreDataManager: CoreDataManager
    var moc = managedObjectContext
    
    init(context : NSManagedObjectContext) {
        self.moc = context
        coreDataManager = CoreDataManager(dataController)
    }
    
    func placeholder(in context: Context) -> AnotherTestEntry {
        AnotherTestEntry(date: Date(), items: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AnotherTestEntry) -> ()) {
        let entry = AnotherTestEntry(date: Date(), items: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AnotherTestEntry>) -> ()) {
        var entries: [AnotherTestEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = AnotherTestEntry(date: entryDate, items: [])
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct AnotherTestEntry: TimelineEntry {
    let date: Date
    var items: [RSSItem]//?
    
}
