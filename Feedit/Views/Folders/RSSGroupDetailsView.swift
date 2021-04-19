//
//  RSSGroupDetailsView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/14/21.
//

import SwiftUI
import CoreData
import Combine
import Foundation

struct RSSGroupDetailsView: View {
//    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var viewModel: RSSListViewModel
    @EnvironmentObject private var persistence: Persistence
    let rssGroup: RSSGroup
    let rss = RSS()
    let item = RSSItem()
    
    static var fetchRequest: NSFetchRequest<RSSGroup> {
      let request: NSFetchRequest<RSSGroup> = RSSGroup.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RSSGroup.items, ascending: true)].compactMap { $0 }
        let predicate = NSPredicate(format: "rssUUID = %@")
        request.predicate = predicate
      return request
    }
    var groups: FetchedResults<RSSGroup>
    
    @State var revealFoldersDisclosureGroup = true
//    @Binding var count: Int
    
    var body: some View {
//      VStack(alignment: .leading, spacing: 8) {
//        Text("Feeds: \(rssGroup.itemCount)")
//          .padding()
//      }
        List {
            ForEach(groups) { rss in
                HStack {
                    Text("\(rssGroup.name ?? "Untitled")")
                    Spacer()
                    Text("\(rssGroup.itemCount)")
                }
            }
            ForEach(viewModel.items) { rss in
                HStack {
                    RSSRow(rss: rss)

                }
            }.environment(\.managedObjectContext, Persistence.current.context)
            .environmentObject(Persistence.current)
        }
        .navigationBarTitle(Text(rssGroup.name ?? "Folders"))
    }
    private func destinationView(rss: RSS) -> some View {
        let item = RSSItem()
        return RSSFeedListView(viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), rssItem: item, selectedFilter: .all).environmentObject(DataSourceService.current.rss)
    }
}

#if DEBUG
struct RSSGroupDetailsView_Previews: PreviewProvider {
    static let rss = RSS()
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static var previews: some View {
        NavigationView {
            RSSGroupListView(persistence: Persistence.current, viewModel: self.viewModel)
                .environment(\.managedObjectContext, Persistence.current.context)
                .environmentObject(Persistence.current)
                .preferredColorScheme(.dark)
        }
    }
}
#endif
