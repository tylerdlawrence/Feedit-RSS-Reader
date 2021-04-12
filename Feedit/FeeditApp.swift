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

    let persistenceController = PersistenceController.shared
    let persistence = Persistence.current
    let rss = RSS()

    @StateObject var articles = AllArticles(dataSource: DataSourceService.current.rssItem)
    
    @StateObject var unread = Unread(dataSource: DataSourceService.current.rssItem)
    
    @StateObject var rssItem = RSSItem()
    
    @StateObject private var viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
    @StateObject private var rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    
    @State private var selectedCells: Set<RSS> = []
    
  var body: some Scene {
    WindowGroup {
        HomeView(articles: articles, unread: unread, rssItem: rssItem, viewModel: viewModel, selectedFilter: FilterType.all)
            .onOpenURL { url in
                print("Received deep link: \(url)")
            }
            .environment(\.managedObjectContext, Persistence.current.context)
            .environmentObject(rssFeedViewModel).environmentObject(viewModel)
            .environmentObject(persistence)
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

extension String: Identifiable {
    public var id: String {
        return self
    }
}
