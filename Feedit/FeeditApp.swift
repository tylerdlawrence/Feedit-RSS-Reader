//
//  FeeditApp.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/15/21.
//

import SwiftUI
import FeedKit
import CoreData
import Introspect
import WidgetKit

@main
struct FeeditApp: App {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.scenePhase) private var scenePhase
    
    let persistence = Persistence.current
    
    var viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
    var articlesViewModel = ArticleItemViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView(container: DIContainer.defaultValue)
                .environmentObject(viewModel)
                .environmentObject(self.viewModel.store)
                .environmentObject(DataSourceService.current.rss)
                .environmentObject(DataSourceService.current.rssItem)
                .environmentObject(persistence)
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
