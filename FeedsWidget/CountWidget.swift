//
//  CountWidget.swift
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


struct CountProvider: TimelineProvider {
    @ObservedObject var unreads = Unread(dataSource: DataSourceService.current.rssItem)
    
    static var widgetPlaceholder: NewestStory {
        return NewestStory(short_id: "Author Name", short_id_url: "https://", created_at: "2020-09-17T08:35:19.000-05:00", title: "Story title", url: "https://")
    }
    
    let dataController = DataController()
    let coreDataManager: CoreDataManager
    var moc = managedObjectContext
    
    init(context : NSManagedObjectContext) {
        self.moc = context
        coreDataManager = CoreDataManager(dataController)
    }
    
    func placeholder(in context: Context) -> CountEntry {
        CountEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CountEntry) -> ()) {
        let entry = CountEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountEntry>) -> ()) {
        var entries: [CountEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = CountEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct CountEntry: TimelineEntry {
    let date: Date
    var items: [RSSItem]?
    
}

struct CountWidgetEntryView: View {
    var entry: CountProvider.Entry
    
    @FetchRequest(entity: RSSItem.entity(), sortDescriptors: []) private var items: FetchedResults<RSSItem>
    
    @State private var feeds = RSSItem.requestUnreadObjects()
    
    @ObservedObject var unreads = Unread(dataSource: DataSourceService.current.rssItem)
    @Environment(\.widgetFamily) var size
    var body: some View {
        VStack(alignment: .leading) {
            switch size {
            case .systemSmall:
                SmallestHottestWidgetView(entry: entry)
            case .systemMedium:
                MediumHottestWidgetView(entry: entry)
            case .systemLarge:
                LargeHottestWidgetView(entry: entry)
            @unknown default:
                SmallestHottestWidgetView(entry: entry)
            }
        }.padding()
        
//        VStack(alignment: .leading) {
//            Text("\(unreads.items.count) Unread")
//                .font(.title3)
//                .bold()
//                .padding(.leading, 50)
//                .foregroundColor(Color("text"))
//
//            ForEach(unreads.items, id: \.self) { (memoryItem: RSSItem) in
//                HStack {
//                    KFImage(URL(string: memoryItem.image))
//                        .placeholder({
//                            Image("unread-action")
//                                .renderingMode(.original)
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 20, height: 20,alignment: .center)
//                                .cornerRadius(3)
//                                .opacity(0.9)
//                        })
//                        .renderingMode(.original)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 20, height: 20,alignment: .center)
//                        .cornerRadius(3)
//                    VStack(alignment: .leading) {
//                        Text("\(memoryItem.createTime?.string() ?? "")")
//                            .textCase(.uppercase)
//                            .font(.system(size: 11, weight: .medium, design: .rounded))
//                            .foregroundColor(.gray)
//                            .opacity(0.8)
//                        Text(memoryItem.title)
//                    }
//                }
//            }
////            Image("unread-action")
////                .resizable()
////                .aspectRatio(contentMode: .fit)
////                .frame(width: 60, height: 60)
//
//            Text("\(unread.items.count) Unread")
//                .font(.title2)
//                .bold()
//                .padding(.bottom)
//                .foregroundColor(Color("text"))
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color("WidgetBackground"))
//        .onAppear {
//            self.unreads.fecthResults()
//        }
    }
}

struct SmallestHottestWidgetView: View {
    var entry: CountProvider.Entry
    @ObservedObject var unreads = Unread(dataSource: DataSourceService.current.rssItem)
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            Image("launch")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(0.4).padding([.top, .leading], -25)
                .frame(width: 100, height: 100)
            Spacer()
            if unreads.items.count == 0 {
                Text("\(unreads.items.count) Unread").font(.caption).foregroundColor(.gray)
            }
            VStack(alignment: .leading) {
                Spacer(minLength: 0)
                
                Text("A redacted title goes here").font(.subheadline).redacted(reason: .placeholder)
                Spacer(minLength: 0)
                HStack(alignment: .center, spacing: 4.0) {
                    VStack(alignment: .leading) {
                        Text("author").font(.caption).redacted(reason: .placeholder)
                        Text("some time ago").font(.caption2).redacted(reason: .placeholder)
                    }.lineLimit(1).minimumScaleFactor(0.5)
                    Spacer(minLength: 0)
                    Text("\(Image(systemName: "largecircle.fill.circle"))").font(.footnote)
                }.foregroundColor(.gray)
                
//                ForEach(unreads.items, id: \.self) { entry in
//                    HStack {
//                        KFImage(URL(string: entry.image))
//                            .placeholder({
//                                Image("unread-action")
//                                    .renderingMode(.original)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 20, height: 20,alignment: .center)
//                                    .cornerRadius(3)
//                                    .opacity(0.9)
//                            })
//                            .renderingMode(.original)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 20, height: 20,alignment: .center)
//                            .cornerRadius(3)
//                        VStack(alignment: .leading) {
//                            Text("\(entry.createTime?.string() ?? "")")
//                                .textCase(.uppercase)
//                                .font(.system(size: 11, weight: .medium, design: .rounded))
//                                .foregroundColor(.gray)
//                                .opacity(0.8)
//                            Text(entry.title)
//                        }
//                    }
//                }
                
//                if let items = entry.items, let item = items.first {
//                    Text(item.title).font(.subheadline)
//                    Spacer(minLength: 0)
//                    HStack(alignment: .center, spacing: 4.0) {
//                        VStack(alignment: .leading) {
//                            Text("\(item.title)").font(.caption)
//                            Text("\(item.desc)").font(.caption2)
//                        }.lineLimit(1).minimumScaleFactor(0.5)
//                        Spacer(minLength: 0)
//                        Text("\(Image(systemName: "arrow.up")) \(item.progress)").font(.footnote)
//                    }.foregroundColor(.gray)
//                } else {
//                    Spacer(minLength: 0)
//                    Text("A redacted title goes here").font(.subheadline).redacted(reason: .placeholder)
//                    Spacer(minLength: 0)
//                    HStack(alignment: .center, spacing: 4.0) {
//                        VStack(alignment: .leading) {
//                            Text("author").font(.caption).redacted(reason: .placeholder)
//                            Text("some time ago").font(.caption2).redacted(reason: .placeholder)
//                        }.lineLimit(1).minimumScaleFactor(0.5)
//                        Spacer(minLength: 0)
//                        Text("\(Image(systemName: "circle.fill"))").font(.footnote)
//                    }.foregroundColor(.gray)
                }
        }.background(Color(UIColor.systemBackground).blur(radius: 10.0).opacity(0.5)).padding([.vertical])
        .onAppear {
            self.unreads.fecthResults()
        }
    }
}

struct MediumHottestWidgetView: View {
    var entry: CountProvider.Entry
    @ObservedObject var unreads = Unread(dataSource: DataSourceService.current.rssItem)
    
    var body: some View {
        HStack {
            Image("launch")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            Spacer()
            Text("\(unreads.items.count) Unread").font(.caption).foregroundColor(.gray)
        }
        Divider()
        Spacer()
        
        if let items = entry.items, let item = items.first {
            let story2 = items[1]
            Text(item.title).font(.subheadline)
            HStack(alignment: .center, spacing: 4.0) {
                Text("via").font(.caption)
                Text("\(item.desc)").font(.caption)
                Text("\(item.createTime?.string() ?? "")").font(.caption)
                Spacer(minLength: 0)
                Text("\(Image(systemName: "arrow.up")) \(item.progress)").font(.footnote)
            }.foregroundColor(.gray)
            .onAppear {
                self.unreads.fecthResults()
            }
            Spacer()
            
            Text(story2.title).font(.subheadline)
            HStack(alignment: .center, spacing: 4.0) {
                Text("via").font(.caption)
                Text("\(story2.desc)").font(.caption)
                Text("\(story2.createTime?.string() ?? "")").font(.caption)
                Spacer(minLength: 0)
                Text("\(Image(systemName: "arrow.up")) \(story2.progress)").font(.footnote)
            }.foregroundColor(.gray)
            .onAppear {
                self.unreads.fecthResults()
            }
        } else {
            Text("The first redacted title").font(.subheadline).redacted(reason: .placeholder)
            HStack(alignment: .center, spacing: 4.0) {
                Text("by").font(.caption).redacted(reason: .placeholder)
                Text("author").font(.caption).redacted(reason: .placeholder)
                Text("some time ago").font(.caption).redacted(reason: .placeholder)
                Spacer(minLength: 0)
                Text("\(Image(systemName: "largecircle.fill.circle"))").font(.footnote)
            }.foregroundColor(.gray)
            
            Spacer()
            
            Text("A second redacted title goes here").font(.subheadline).redacted(reason: .placeholder)
            HStack(alignment: .center, spacing: 4.0) {
                Text("by").font(.caption).redacted(reason: .placeholder)
                Text("author").font(.caption).redacted(reason: .placeholder)
                Text("some time ago").font(.caption).redacted(reason: .placeholder)
                Spacer(minLength: 0)
                Text("\(Image(systemName: "largecircle.fill.circle"))").font(.footnote)
            }.foregroundColor(.gray)
        }
    }
}

struct LargeStoryView: View {
    var item: RSSItem?
    @ObservedObject var unreads = Unread(dataSource: DataSourceService.current.rssItem)
    
    var body: some View {
        if let item = item {
            Text(item.title).font(.subheadline)
            HStack(alignment: .center, spacing: 4.0) {
                Text("by").font(.caption).redacted(reason: .placeholder)
                Text("\(item.desc)").font(.caption)
                Text("\(item.createTime?.string() ?? "")").font(.caption)
                Spacer(minLength: 0)
                Text("\(Image(systemName: "largecircle.fill.circle")) \(item.progress)").font(.footnote)
            }.foregroundColor(.gray)
            .onAppear {
                self.unreads.fecthResults()
            }
        } else {
            Text("A title here but it is redacted...").font(.subheadline).redacted(reason: .placeholder)
            HStack(alignment: .center, spacing: 4.0) {
                Text("by").font(.caption).redacted(reason: .placeholder)
                Text("author").font(.caption).redacted(reason: .placeholder)
                Text("some tiem ago").font(.caption).redacted(reason: .placeholder)
                Spacer(minLength: 0)
                Text("\(Image(systemName: "largecircle.fill.circle"))").font(.footnote)
            }.foregroundColor(.gray)
            .onAppear {
                self.unreads.fecthResults()
            }
        }
    }
}

struct LargeHottestWidgetView: View {
    var entry: CountProvider.Entry
    
    @ObservedObject var unreads = Unread(dataSource: DataSourceService.current.rssItem)
    
    var body: some View {
        HStack {
            Image("launch")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            Spacer()
            Text("\(unreads.items.count) Unread").font(.caption).foregroundColor(.gray)
        }
        Divider()
        Spacer()
        if let items = entry.items, items.count > 3 {
            
            LargeStoryView(item: items[0])
            Spacer()
            LargeStoryView(item: items[1])
            Spacer()
            LargeStoryView(item: items[2])
            Spacer()
            LargeStoryView(item: items[3])
                .onAppear {
                    self.unreads.fecthResults()
                }
        } else {
            LargeStoryView(item: nil)
            Spacer()
            LargeStoryView(item: nil)
            Spacer()
            LargeStoryView(item: nil)
            Spacer()
            LargeStoryView(item: nil)
        }
    }
}



struct CountWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CountWidgetEntryView(entry: CountEntry(date: Date(), items: []))
                .background(Color(UIColor.systemBackground)).environment(\.colorScheme, .dark)
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            CountWidgetEntryView(entry: CountEntry(date: Date(), items: []))
                .background(Color(UIColor.systemBackground)).environment(\.colorScheme, .dark)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            CountWidgetEntryView(entry: CountEntry(date: Date(), items: []))
                .background(Color(UIColor.systemBackground)).environment(\.colorScheme, .dark)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            
        }.previewLayout(.sizeThatFits)
    }
}
