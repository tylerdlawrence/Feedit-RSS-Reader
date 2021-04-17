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
import Foundation
import FeedKit

struct ParserProvider: TimelineProvider {
    var rssItems:[RSSItem]?
    let feedParser = RSSParser()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title:"News", description: "News article here", url: "Https://link", createTime: Date())
        
//        SimpleEntry(date: Date(), title: "A Message on the Upcoming Shows", description: "We are happy to announce that the Band and Fans WILL be seeing each other, in concert setting – SOON! A long awaited moment.", url: "https://www.apple.com", createTime: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry =
            SimpleEntry(date: Date(), title: "A Message on the Upcoming Shows", description: "We are happy to announce that the Band and Fans WILL be seeing each other, in concert setting – SOON! A long awaited moment.", url: "https://www.apple.com", createTime: Date())
            //SimpleEntry(date: Date(), title:"News", description: "News Article Here", url: "https://link", createTime: Date())
        completion(entry)
    }
    
//    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        guard !feedParser.rssItems.isEmpty else { return }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        
        guard !feedParser.rssItems.isEmpty else { return }
        var entries: [SimpleEntry] = []
        feedParser.parse(url: "https://widespreadpanic.com/feed") {(rssItems) in
//            self.rssItems = rssItems
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
            let currentDate = Date()
            let entry = SimpleEntry(date: currentDate, title:rssItems[0].title, description: rssItems[0].description, url: rssItems[0].url, createTime: rssItems[0].createTime!)
            entries.append(entry)
        
            let timeline = Timeline(entries: entries, policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let description: String
    let url: String
    let createTime: Date
    let rssItems = RSSItem()
}

struct FritchNewsEntryView : View {
    var entry: SimpleEntry
    var body: some View {
        ZStack {
            Image("launch")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(0.4).padding([.top, .leading], -45)
                .frame(width: 125, height: 125)
                
        Spacer()
            
        VStack(alignment: .leading, spacing: 2) {
            Text("\(entry.createTime.string())")
                .textCase(.uppercase)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
            
            Text(entry.title)
                .lineLimit(3)
                .font(.system(.subheadline).bold())
                .foregroundColor(Color("text"))
            
            Text(entry.description)
                .lineLimit(1)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                .padding()
        .background(Color(UIColor.systemBackground).blur(radius: 10.0).opacity(0.3))
        }
    }
}

struct TestWidget: Widget {
    let kind: String = "TestWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ParserProvider()) { entry in
            FritchNewsEntryView(entry: entry)
        }
        .configurationDisplayName("Random Article")
        .description("One of your most recent articles")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TestWidget_Previews: PreviewProvider {
    static var previews: some View {
        FritchNewsEntryView(entry: SimpleEntry(date: Date(), title: "A Message on the Upcoming Shows", description: "We are happy to announce that the Band and Fans WILL be seeing each other, in concert setting – SOON! A long awaited moment.", url: "https://www.apple.com", createTime: Date()))
            .background(Color(UIColor.systemBackground)).environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
