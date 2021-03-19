//
//  FeeditApp.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/15/21.
//

import SwiftUI
import CoreData
import Introspect

@main
struct FeeditApp: App {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var networkReachability = NetworkReachabilty.shared
    @State var isLoaded = false
    
    @AppStorage("darkMode") var darkMode = false

    let persistence = Persistence.current
    let rss = RSS()
    let rssItem = RSSItem()
    let unread = Unread(dataSource: DataSourceService.current.rssItem)
    let articles = AllArticles(dataSource: DataSourceService.current.rssItem)
    
    @StateObject private var viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

  var body: some Scene {
    WindowGroup {
        if networkReachability.isNetworkConnected {
            
            HomeView(articles: articles, unread: unread, rssItem: rssItem, viewModel: self.viewModel, rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), archiveListViewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
                .environment(\.managedObjectContext, persistence.context)
                .environmentObject(persistence)
            
        } else {
            VStack {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 50))
                    .frame(width: 50, height: 50, alignment: .center)
                    .padding(.bottom, 24)
                Text("Network not available")
                    .alert(isPresented: .constant(true)) {
                        Alert(title: Text("Network not available"), message: Text("Turn on mobile data or use Wi-Fi to access data"), dismissButton: .default(Text("OK")))
                    }.navigationBarTitle(Text("Home"))
                }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(650)) {
                    isLoaded = true
                }
            }
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
