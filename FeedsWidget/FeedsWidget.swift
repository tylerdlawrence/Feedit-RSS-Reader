//
//  FeedsWidget.swift
//  FeedsWidget
//
//  Created by Tyler D Lawrence on 3/23/21.
//

//import WidgetKit
//import SwiftUI
//import Intents
//import CoreData

//struct ArticleProvider: TimelineProvider {
//    /// Access to CoreDataManger
//    let dataController = DataController()
//    let coreDataManager: CoreDataManager
//    let rssItem = RSSItem()
//
//    init() {
//        coreDataManager = CoreDataManager(dataController)
//    }
//
//    /// Placeholder for Widget
//    func placeholder(in context: Context) -> WidgetEntry {
//        WidgetEntry(date: Date(), article: rssItem)
//    }
//
//    /// Provides a timeline entry representing the current time and state of a widget.
//    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) { //swiftlint:disable:this line_length
//        articleForWidget() { selectedArticle in
//            let entry = WidgetEntry(
//                date: Date(),
//                article: selectedArticle
//            )
//            completion(entry)
//        }
//    }
//
//    /// Provides an array of timeline entries for the current time and, optionally, any future times to update a widget.
//    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) { //swiftlint:disable:this line_length
//        coreDataManager.fetchArticles()
//
////        let interval = configuration.interval as! Int
//
//        /// Fetches the vehicle selected in the configuration
//        articleForWidget() { selectedArticle in
//            let currentDate = Date()
//            var entries: [WidgetEntry] = []
//
//            // Create a date that's 60 minutes in the future.
//            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 60, to: currentDate)!
//
//            // Generate an Entry
//            let entry = WidgetEntry(date: currentDate, article: selectedArticle)
//            entries.append(entry)
//
//            let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
//            completion(timeline)
//        }
//    }
//
//    /// Fetches the Vehicle defined in the Configuration
//    /// - Parameters:
//    ///   - configuration: Intent Configuration
//    ///   - completion: completion handler returning the selected Vehicle
//    func articleForWidget(completion: @escaping (RSSItem?) -> Void) {
//        var selectedArticle: RSSItem?
//        defer {
//            completion(selectedArticle)
//        }
//
//        for article in coreDataManager.articleArray where article.uuid?.uuidString == rssItem.isRead.string { //swiftlint:disable:this line_length
//            selectedArticle = article
//        }
//    }
//}
//
//struct WidgetEntry: TimelineEntry {
//    let date: Date
////    let configuration: SelectedArticleIntent
//    var article: RSSItem?
//}
//
//struct RSSWidgetEntryView: View {
////    var entry: Provider.Entry
//    var entry: ArticleProvider.Entry
//
//    var body: some View {
//        VStack {
////            Text(entry.date, style: .time)
//            Text(entry.article?.author ?? "No author")
//            Text("CoreData: \(entry.article?.title.count ?? 25)")
//            Text("Name: \(entry.article?.desc ?? "No description")")
//            Divider()
//            Text("Refreshed: \(entry.date, style: .relative)")
//                .font(.caption)
//        }
//        .padding(.all)
//    }
//}
//
////@main
//struct RSSWidget: Widget {
//    let kind: String = "RSSWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: ArticleProvider()) { entry in
//            RSSWidgetEntryView(entry: entry)
//        }
//        .configurationDisplayName("My Widget")
//        .description("This is an example widget.")
//    }
//}
//
//struct RSSWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        RSSWidgetEntryView(entry: WidgetEntry(date: Date()))
//            .environment(\.managedObjectContext, Persistence.current.context)
////            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
