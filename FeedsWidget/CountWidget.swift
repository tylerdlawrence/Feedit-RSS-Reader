//
//  CountWidget.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 4/13/21.
//

import SwiftUI
import WidgetKit
import CoreData
import KingfisherSwiftUI

class DataController: ObservableObject {
    var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    var workingContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = managedObjectContext
        return context
    }

    var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "RSS")

        let storeURL = URL.storeURL(for: "group.com.tylerdlawrence.feedit.shared", databaseName: "RSS")
        let description = NSPersistentStoreDescription(url: storeURL)

        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                print(error)
            }
        })

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

        return container
    }()
}

struct CountProvider: TimelineProvider {
    var moc = managedObjectContext
    
    init(context : NSManagedObjectContext) {
        self.moc = context
    }
    
    func placeholder(in context: Context) -> CountEntry {
        CountEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (CountEntry) -> Void) {
        let entry = CountEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let midnight = Calendar.current.startOfDay(for: Date())
        let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
        let entries = [CountEntry(date: midnight)]
        let timeline = Timeline(entries: entries, policy: .after(nextMidnight))
        completion(timeline)
    }
}

struct CountEntry: TimelineEntry {
    let date: Date
    
}

struct CountWidgetEntryView: View {
    var entry: CountProvider.Entry
//    let moc = PersistenceController.shared.container.viewContext
//    let predicate = NSPredicate(format: "isRead = false")
//    let request = NSFetchRequest<RSSItem>(entityName: "RSSItem")
//    @FetchRequest(entity: RSSItem.entity(), sortDescriptors: []) var unreads: FetchedResults<RSSItem>
    
    @StateObject private var unread = Unread(dataSource: DataSourceService.current.rssItem)

    var body: some View {
//         let result = try moc.fetch(request)
        
        VStack(alignment: .leading) {
            
            Text("\(unread.items.count) Unread")
                .font(.title3)
                .bold()
                .padding(.leading, 50)
                .foregroundColor(Color("text"))
            
            ForEach(unread.items, id: \.self) { (memoryItem: RSSItem) in
                HStack {
                    KFImage(URL(string: memoryItem.image))
                        .placeholder({
                            Image("unread-action")
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20,alignment: .center)
                                .cornerRadius(3)
                                .opacity(0.9)
                        })
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20,alignment: .center)
                        .cornerRadius(3)
                    VStack(alignment: .leading) {
                        Text("\(memoryItem.createTime?.string() ?? "")")
                            .textCase(.uppercase)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                            .opacity(0.8)
                        Text(memoryItem.title)
                    }
                }
            }
//            Image("unread-action")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 60, height: 60)
            
//            Text("\(unread.items.count) Unread")
//                .font(.title2)
//                .bold()
//                .padding(.bottom)
//                .foregroundColor(Color("text"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("WidgetBackground"))
        .onAppear {
            self.unread.fecthResults()
        }
    }
}
//@main
struct CountWidget: Widget {
    let kind: String = "CountWidget"
        
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountProvider(context: managedObjectContext)) { entry in
            CountWidgetEntryView(entry: entry)
                .environment(\.managedObjectContext, managedObjectContext)
        }
        .configurationDisplayName("Starred Articles")
        .description("View your starred articles")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct CountWidget_Previews: PreviewProvider {
    static var previews: some View {
        CountWidgetEntryView(entry: CountEntry(date: Date()))
            .preferredColorScheme(.dark)
//            .previewContext(WidgetPreviewContext(family: .systemMedium))
            
    }
}
