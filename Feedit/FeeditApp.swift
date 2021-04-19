//
//  FeeditApp.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/15/21.
//

import SwiftUI
import CoreData
import Introspect
import WidgetKit

@main
struct FeeditApp: App {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.scenePhase) private var scenePhase
    
    let persistence = Persistence.current
    
    @StateObject private var articles = AllArticles(dataSource: DataSourceService.current.rssItem)
    @StateObject private var unread = Unread(dataSource: DataSourceService.current.rssItem)
    @StateObject private var viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    @StateObject private var rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    @StateObject private var rss = RSS()
    @StateObject private var rssItem = RSSItem()
    
    
    var body: some Scene {
        WindowGroup {
            
            HomeView(articles: articles, unread: unread, rssItem: rssItem, viewModel: viewModel, selectedFilter: FilterType.all)
                .environmentObject(viewModel)
                .environmentObject(articles)
                .environmentObject(unread)
                .environmentObject(rss)
                .environmentObject(rssItem)
                .environment(\.managedObjectContext, Persistence.current.context)
                .onOpenURL { url in
                    print("Received deep link: \(url)")
            }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
            persistence.saveChanges()
            default:
                break
            }
        }
    }
}
