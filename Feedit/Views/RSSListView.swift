//
//  RSSListView.swift
//  Feedit
//
//  Created by Tyler Lawrence on 10/22/20
//
//
//

import SwiftUI
import FeedKit
import UIKit
import CoreData
import Combine
import Foundation
import os.log

struct RSSListView: View {
    @EnvironmentObject var rssDataSource: RSSDataSource
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    @State private var revealFeedsDisclosureGroup = false
    @ObservedObject var unread = Unread(dataSource: DataSourceService.current.rssItem)
    
    var rssFeed: RSSFeed?
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $revealFeedsDisclosureGroup,
            content: {
            ForEach(viewModel.items, id: \.objectID) { rss in
                ZStack {
                    NavigationLink(destination: NavigationLazyView(self.destinationView(rss: rss)).environmentObject(DataSourceService.current.rss)) {
                        EmptyView()
                    }
                    .opacity(0.0)
                    .buttonStyle(PlainButtonStyle())
                    
                    HStack {
                        RSSRow(rss: rss).equatable()
                            .environmentObject(DataSourceService.current.rss)
//                        Spacer()
//                        UnreadCountView(count: unread.items.count)
                    }.id(rss.objectID)
                }
            }//.onDelete(perform: delete)
            .listRowBackground(Color("accent"))
            .environmentObject(DataSourceService.current.rss)
            .environmentObject(DataSourceService.current.rssItem)
            .environment(\.managedObjectContext, Persistence.current.context)
                },
                label: {
                    HStack {
                        Text("Feeds")
                            .font(.system(size: 18, weight: .regular, design: .rounded)).textCase(nil)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    self.revealFeedsDisclosureGroup.toggle()
                                }
                            }
                        }
                }).listRowBackground(Color("darkerAccent"))
                .accentColor(Color("tab"))
            .onAppear(perform: {
                self.viewModel.fecthResults()
        })
    }
    private func delete(offsets: IndexSet) {
        withAnimation {
            offsets.map { viewModel.items[$0] }.forEach(Persistence.current.context.delete)
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
        let item = RSSItem()
        return RSSFeedListView(viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), rssItem: item, selectedFilter: .all)
            .environmentObject(DataSourceService.current.rss)
    }
}

struct RSSListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                RSSListView().environmentObject(DataSourceService.current.rss)
                    .environmentObject(DataSourceService.current.rssItem)
                    .environment(\.managedObjectContext, Persistence.current.context)
            }
        }
    }
}

struct NavigationLazyView<Content: View>: View {
   let build: () -> Content

   init(_ build: @autoclosure @escaping () -> Content) {
       self.build = build
   }

   var body: Content {
       build()
   }
}
