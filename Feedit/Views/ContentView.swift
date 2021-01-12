//
//  HomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    
//    @Environment(\.managedObjectContext) private var viewContext
//
//    @FetchRequest(entity: RSSItem.entity(), sortDescriptors: [], predicate: NSPredicate(format: "rssUUID = %@"))
//
//    var unread: FetchedResults<RSSItem>
    
    var body: some View {
        ContentView()
//            .environment(\.managedObjectContext, Persistence(version: 1).container.viewContext
//            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static var previews: some View {
        ContentView()
    }
}
