//
//  FeedsWidget.swift
//  FeedsWidget
//
//  Created by Tyler D Lawrence on 3/23/21.
//

//import WidgetKit
//import SwiftUI
//import CoreData

//struct Provider: TimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        let string: String = ""
////        let uri = char?.objectID.uriRepresentation().absoluteString;
//        return SimpleEntry(date: Date(), title: string, desc: string, uri: nil)
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let string: String = ""
////        let uri = char?.objectID.uriRepresentation().absoluteString;
//        let entry = SimpleEntry(date: Date(), title: string, desc: string, uri: nil)
//        completion(entry)
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let string: String = ""
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
////            let midnight = Calendar.current.startOfDay(for: Date())
////            let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, title: string, desc: string, uri: nil)
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let title: String
//    let desc: String
//    let uri: String?
//
//    var url: URL? {
//        get {
//            if let linkID = self.uri {
//                return URL(string: "feeditrssreader://" + linkID)
//            }
//            return nil
//        }
//    }
//}
//
//private struct CoreDataWidgetEntryView: View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        return Text("Items count: \(itemsCount)")
//    }
//
//    var itemsCount: Int {
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RSSItem")
//        do {
//            return try Persistence.shared.context.count(for: request)
//        } catch {
//            print(error.localizedDescription)
//            return 0
//        }
//    }
//}
//
//struct FeedsWidgetEntryView : View {
//    var entry: Provider.Entry
//
//    var body: some View {
////        CoreDataWidgetEntryView(entry: entry)
////        Text(entry.date, style: .time)
//        HStack(alignment: .top) {
//            VStack(alignment: .leading) {
//                Text("Untitled").font(.system(size: 18, weight: .medium, design: .rounded)).lineLimit(3).fixedSize(horizontal: true, vertical: true).opacity(0.9)
//
//            }
//            .padding()
//            .cornerRadius(6)
//        }
//        //.widgetURL(entry.url)
//        //.frame(width: 500, height: 500, alignment: .center)
//    }
//}
//
//@main
//struct FeedsWidget: Widget {
//
//    let kind: String = "FeedsWidget"
//    let snapshotEntry = SimpleEntry(date: Date(), title: "Article Title", desc: "Article Description", uri: nil)
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: Provider()) { entry in
//            FeedsWidgetEntryView(entry: Provider.Entry.init(date: Date(), widgetData: WidgetDataDecoder.sampleData()))
////            FeedsWidgetEntryView(entry: entry, article: article)
//        }
//        .configurationDisplayName("Articles")
//        .description("Most Recent Articles")
//        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
//    }
//}

//struct FeedsWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        FeedsWidgetEntryView(entry: SimpleEntry(date: Date(), title: "Article Title", desc: "Article Description", uri: nil))
//            .previewContext(WidgetPreviewContext(family: .systemMedium))
//    }
//}
