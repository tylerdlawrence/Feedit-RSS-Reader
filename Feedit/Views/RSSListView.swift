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
    
    var rssFeed: RSSFeed?
    
    var body: some View {
//        ForEach(viewModel.items,id:\.self) { rss in
        
            DisclosureGroup(
                isExpanded: $revealFeedsDisclosureGroup,
                content: {
                ForEach(viewModel.items, id: \.self) { rss in
                    ZStack {
                        NavigationLink(destination: NavigationLazyView(self.destinationView(rss: rss)).environmentObject(DataSourceService.current.rss)
                                  
                        ) {
                            EmptyView()
                        }
                        .opacity(0.0)
                        .buttonStyle(PlainButtonStyle())
                        
                        HStack {
                            RSSRow(viewModel: viewModel, rss: rss).environmentObject(DataSourceService.current.rss)
//                            Spacer()
//                                .environmentObject(DataSourceService.current.rss)
//                                .environmentObject(DataSourceService.current.rssItem)
                        }
                    }
                }.onDelete(perform: delete)
                
                .listRowBackground(Color("accent"))
                .environmentObject(DataSourceService.current.rss)
                .environmentObject(DataSourceService.current.rssItem)
                .environment(\.managedObjectContext, Persistence.current.context)
                    },
                    label: {
                        HStack {
                            Text("Feeds")
                                .font(.system(size: 14, weight: .regular, design: .rounded)).textCase(.uppercase)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        self.revealFeedsDisclosureGroup.toggle()
                                    }
                                }
                        }.frame(maxWidth: .infinity)
                    })
//                .listRowBackground(Color("darkerAccent"))
            .accentColor(Color("tab"))
            .onAppear {
                self.viewModel.fecthResults()
            }
//        }
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
        RSSListView().environmentObject(DataSourceService.current.rss)
            .environmentObject(DataSourceService.current.rssItem)
            .environment(\.managedObjectContext, Persistence.current.context)
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
