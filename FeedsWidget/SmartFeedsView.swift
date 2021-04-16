//
//  SmartFeedsView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/24/21.
//

import SwiftUI
import WidgetKit
import CoreData
import Foundation

struct SmartFeedsView: View {
    @State var selectedFilter: FilterType = .all
    @StateObject var rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    @StateObject var archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    
    @StateObject var articles = AllArticles(dataSource: DataSourceService.current.rssItem)
    @StateObject var unread = Unread(dataSource: DataSourceService.current.rssItem)
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var persistence: Persistence
    @Environment(\.managedObjectContext) private var context
    var filteredArticles: [RSSItem] {
        return rssFeedViewModel.items.filter({ (item) -> Bool in
            return !((self.rssFeedViewModel.isOn && !item.isArchive) || (self.rssFeedViewModel.unreadIsOn && item.isRead))
        })
    }
    
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var entry: Provider.Entry
    
    @FetchRequest(entity: RSSItem.entity(), sortDescriptors: []) var items: FetchedResults<RSSItem>
    
    var body: some View {
        smallWidget
            .widgetURL(WidgetDeepLink.icon.url)
    }
    
    @ViewBuilder
    var smallWidget: some View {
        ZStack(alignment: .topLeading) {
            Image("launch")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(0.4).padding([.top, .leading], -25)
                .frame(width: 135, height: 135)
            VStack(alignment: .leading) {
                Spacer()
                Link(destination: WidgetDeepLink.today.url, label: {
                    HStack {
                        todayImage
                        VStack(alignment: .leading, spacing: nil, content: {
                            Text(formattedCount(entry.widgetData.currentTodayCount))
//                          Text(formattedCount(articles.items.count))
    //                        Text("\(articles.items.count)")
                                .font(Font.system(.caption, design: .rounded)).bold()
                            Text(L10n.today)
                                .font(.caption).textCase(.uppercase)
                                .foregroundColor(Color("text"))
                        }).foregroundColor(Color("tab"))
                        Spacer()
                    }
                })
                
                Link(destination: WidgetDeepLink.unread.url, label: {
                    HStack {
                        unreadImage
                        VStack(alignment: .leading, spacing: nil, content: {
                            Text(formattedCount(entry.widgetData.currentUnreadCount))
//                            Text(formattedCount(unread.items.count))
    //                        Text("\(unread.items.count)")
                                .font(Font.system(.caption, design: .rounded)).bold()
                            Text(L10n.unread)
                                .font(.caption).textCase(.uppercase).foregroundColor(Color("text"))
                        }).foregroundColor(Color("tab"))
                        Spacer()
                    }
                })
                
                Link(destination: WidgetDeepLink.starred.url, label: {
                    HStack {
                        starredImage
                        VStack(alignment: .leading, spacing: nil, content: {
                            Text(formattedCount(entry.widgetData.currentStarredCount))
//                            Text(formattedCount(archiveListViewModel.items.count))
    //                        Text("\(archiveListViewModel.items.count)")
                                .font(Font.system(.caption, design: .rounded)).bold()
                                
                            Text(L10n.starred)
                                .font(.caption).textCase(.uppercase).foregroundColor(Color("text"))
                        }).foregroundColor(Color("tab"))
                        Spacer()
                    }
                })
                Spacer()
            }
            .background(Color(UIColor.systemBackground).blur(radius: 10.0).opacity(0.5))
            .onAppear {
                self.articles.fecthResults()
                self.unread.fecthResults()
                self.archiveListViewModel.fecthResults()
            }.padding()
        }
    }
    
    func formattedCount(_ count: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: count))!
    }
    
    var unreadImage: some View {
        Image(systemName: "largecircle.fill.circle")
            .resizable()
            .frame(width: 20, height: 20, alignment: .center)
            .foregroundColor(Color("tab"))
    }
    
    var feeditImage: some View {
        Image("CornerIcon")
            .resizable()
            .frame(width: 20, height: 20, alignment: .center)
            .cornerRadius(4)
    }
    
    var starredImage: some View {
        Image(systemName: "star.fill")
            .resizable()
            .frame(width: 20, height: 20, alignment: .center)
            .foregroundColor(Color("tab"))
    }
    
    var todayImage: some View {
        Image(systemName: "chart.bar.doc.horizontal")
            .resizable()
            .frame(width: 20, height: 20, alignment: .center)
            .foregroundColor(Color("tab"))
    }
    
}


struct SmartFeedsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SmartFeedsView(entry: Provider.Entry.init(date: Date(), widgetData: WidgetDataDecoder.sampleData()))
                .background(Color(UIColor.systemBackground)).environment(\.colorScheme, .dark)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
