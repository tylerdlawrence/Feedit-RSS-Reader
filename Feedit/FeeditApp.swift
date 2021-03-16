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
    
    let persistence = Persistence.current
    let rss = RSS()
    let rssItem = RSSItem()
    
    @StateObject private var viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

  var body: some Scene {
    WindowGroup {
        HomeView(rssItem: rssItem, viewModel: self.viewModel, rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), archiveListViewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
        .environment(\.managedObjectContext, persistence.context)
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
