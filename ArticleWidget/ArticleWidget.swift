//
//  ArticleWidget.swift
//  ArticleWidget
//
//  Created by Tyler D Lawrence on 11/11/20.
//

import WidgetKit
import SwiftUI
import Intents

//struct Provider: TimelineProvider {
//  public typealias Entry = WidgetContent
//
//  func placeholder(in context: Context) -> WidgetContent {
//    snapshotEntry
//  }
//
//  public func getSnapshot(
//    in context: Context,
//    completion: @escaping (WidgetContent) -> Void
//  ) {
//    let entry = snapshotEntry
//    completion(entry)
//  }
//
//  func readContents() -> [Entry] {
//    var contents: [WidgetContent] = []
//    let archiveURL = FileManager.sharedContainerURL().appendingPathComponent("contents.json")
//    print(">>> \(archiveURL)")
//
//    let decoder = JSONDecoder()
//    if let codeData = try? Data(contentsOf: archiveURL) {
//      do {
//        contents = try decoder.decode([WidgetContent].self, from: codeData)
//      } catch {
//        print("Error: Can't decode contents")
//      }
//    }
//    return contents
//  }
//
//  public func getTimeline(
//    in context: Context,
//    completion: @escaping (Timeline<WidgetContent>) -> Void
//  ) {
//    var entries = readContents()
//
//    // Generate a timeline by setting entry dates interval seconds apart,
//    // starting from the current date.
//    let currentDate = Date()
//    let interval = 5
//    for index in 0 ..< entries.count {
//      entries[index].date = Calendar.current.date(byAdding: .second,
//        value: index * interval, to: currentDate)!
//    }
//
//    let timeline = Timeline(entries: entries, policy: .atEnd)
//    completion(timeline)
//  }
//}

//@main
//struct ArticleWidget: Widget {
//  private let kind: String = "ArticleWidget"
//
//  public var body: some WidgetConfiguration {
//    StaticConfiguration(
//      kind: kind,
//      provider: Provider()
//    ) { entry in
//      EntryView(model: entry)
//    }
//    .configurationDisplayName("Random Article")
//    .description("Random article from your feeds.")
//    .supportedFamilies([.systemSmall])
//  }
//}


//import WidgetKit
//import SwiftUI
//import Combine

//    let url = "https://raw.githubusercontent.com/tylerdlawrence/defaultfeeds/main/default.json?token=APGIAGCLXP7HH74CMBMB4AK7VSCI2"
//
//        //"https://daringfireball.net/feeds/json"
////        "https://canvasjs.com/data/gallery/javascript/daily-sales-data.json"
//


struct Provider: TimelineProvider {
    //this is a placeholder string
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), myString: "...")
    }

    //and this is a placeholder string
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), myString: "...")
        completion(entry)
    }

    //this is the main logic
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            //change time from one hour to 10 seconds
            let entryDate = Calendar.current.date(byAdding: .second, value: hourOffset * 10, to: currentDate)!
            //here we can get random string from our provider
            let entry = SimpleEntry(date: entryDate, myString: MyProvider.getRandomString())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let myString: String
}

//this is the widget look
struct ArticleWidgetModuleEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            //set background
            Color.black.edgesIgnoringSafeArea(.all)

            //display text
            Text(entry.myString)
                .foregroundColor(.blue)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
    }
}

@main
struct ArticleWidgetModule: Widget {
    let kind: String = "ArticleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ArticleWidgetModuleEntryView(entry: entry)
        }
        .configurationDisplayName("Random Article")
        .description("Show a random recent article from your feeds.")
//        .configurationDisplayName("Article Widget")
//        .description("Show the latest articles on your home screen.")
    }
}
struct ArticleWidgetModule_Previews: PreviewProvider {
    static var previews: some View {
        ArticleWidgetModuleEntryView(entry: SimpleEntry(date: Date(), myString: "Random String"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
