//
//  FeeditApp.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/15/21.
//

import SwiftUI

@main
struct FeeditApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("darkMode") var darkMode = false
    
    let persistence = Persistence.current
    let rss = RSS()
    let rssItem = RSSItem()
    
    let unread = Unread(dataSource: DataSourceService.current.rssItem)
    let articles = AllArticles(dataSource: DataSourceService.current.rssItem)
    
    @StateObject private var viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

  var body: some Scene {
    WindowGroup {
        HomeView(articles: articles, unread: unread, rssItem: rssItem, viewModel: self.viewModel, rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), archiveListViewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
            .environment(\.managedObjectContext, persistence.context)
            .environmentObject(persistence)
            .preferredColorScheme(darkMode ? .dark : .light)
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
