//
//  RSSFoldersDisclosureGroup.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/14/21.
//

import SwiftUI
import CoreData
import Combine
import FeedKit
import Foundation
import os.log
import KingfisherSwiftUI

struct RSSFoldersDisclosureGroup: View {
    static var fetchRequest: NSFetchRequest<RSSGroup> {
      let request: NSFetchRequest<RSSGroup> = RSSGroup.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RSSGroup.items, ascending: true)]
      return request
    }
    @FetchRequest(
      fetchRequest: RSSGroupListView.fetchRequest,
      animation: .default)
    var groups: FetchedResults<RSSGroup>
    
    static var fetchRequestCount: NSFetchRequest<RSS> {
      let request: NSFetchRequest<RSS> = RSS.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RSS.itemCount, ascending: true)]
      return request
    }
    
    @ObservedObject var persistence: Persistence
    @ObservedObject var unread: Unread
    @EnvironmentObject var rssDataSource: RSSDataSource
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @StateObject var viewModel: RSSListViewModel
    
    @State var isExpanded = false
    @State private var expandFolders = true
    var filteredArticles: [RSSItem] {
        return rssFeedViewModel.items.filter({ (item) -> Bool in
            return !((self.rssFeedViewModel.isOn && !item.isArchive) || (self.rssFeedViewModel.unreadIsOn && item.isRead))
        })
    }
    
    @StateObject var rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }

    var rss = RSS()
    var start = 0
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $expandFolders,
            content: {
                ForEach(groups, id: \.id) { group in
                DisclosureGroup {
                    ForEach(viewModel.items, id: \.uuid) { rss in
                        ZStack {
                            NavigationLink(destination: NavigationLazyView(self.destinationView(rss: rss)).environmentObject(DataSourceService.current.rss)) {
                                EmptyView()
                            }
                            .opacity(0.0)
                            .buttonStyle(PlainButtonStyle())
                            
                            HStack {
                                RSSRow(rss: rss)
                                    .environmentObject(DataSourceService.current.rss)
                                    .environmentObject(DataSourceService.current.rssItem)
                                    .environment(\.managedObjectContext, Persistence.current.context)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }.listRowBackground(Color("accent"))
                    }.onDelete(perform: delete)
                    .onMove(perform: move)
                } label: {
                    HStack {
                        if group.itemCount > 0 {
                            UnreadCountView(count: Int(group.itemCount))
                                .contentShape(Rectangle())
                        }
                        Text("\(group.name ?? "Untitled")")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    self.isExpanded.toggle()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }.accentColor(Color.gray.opacity(0.7))
                .listRowBackground(Color("accent"))
            }.onDelete(perform: deleteObjects)
        },
        label: {
            HStack {
                Text("Folders")
                    .font(.system(size: 18, weight: .regular, design: .rounded)).textCase(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            self.expandFolders.toggle()
                        }
                    }
            }
        })
        .listRowBackground(Color("darkerAccent"))
        .accentColor(Color("tab"))
        .onAppear {
            self.viewModel.fecthResults()
        }
    }
    
    private func deleteObjects(offsets: IndexSet) {
        withAnimation {
            persistence.deleteManagedObjects(offsets.map { groups[$0] })
        }
    }
    private func delete(offsets: IndexSet) {
        withAnimation {
            offsets.map { viewModel.items[$0] }.forEach(Persistence.current.context.delete)
            saveContext()
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        withAnimation {
            viewModel.move(from: source, to: destination)
            saveContext()
        }
    }
    
    private func updateRSS(_ rss: FetchedResults<RSS>.Element) {
        withAnimation {
            rss.itemCount = Int64(rssFeedViewModel.items.count)
            saveContext()
        }
    }
    private func saveContext() {
        do {
            try Persistence.current.context.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved Error: \(error)")
        }
    }
    private func destinationView(rss: RSS) -> some View {
        return RSSFeedListView(viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), selectedFilter: .all)
            .environmentObject(DataSourceService.current.rss)
    }
}

#if DEBUG
struct RSSFoldersDisclosureGroup_Previews: PreviewProvider {
    static let rss = RSS()
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static let unread = Unread(dataSource: DataSourceService.current.rssItem)

    static var previews: some View {
        NavigationView {
            List {
                RSSFoldersDisclosureGroup(persistence: Persistence.current, unread: unread, viewModel: self.viewModel, isExpanded: false)
                    
                    .environment(\.managedObjectContext, Persistence.current.context)
                    .environmentObject(Persistence.current)
                    .preferredColorScheme(.dark)
            }.listStyle(SidebarListStyle())
        }
    }
}
#endif
