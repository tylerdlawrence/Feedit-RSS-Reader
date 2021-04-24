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
    
    @ObservedObject var feed = RSSStore.instance
    @Environment(\.injected) private var injected: DIContainer
    
    func filterFeeds(url: String?) -> RSS? {
        guard let url = url else { return nil }
        return viewModel.items.first(where: { $0.url == url })
    }
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $revealFeedsDisclosureGroup,
            content: {
                
                ForEach(viewModel.items.indices, id: \.self) { index in
                    ZStack {
                        NavigationLink(destination:
                                        RSSFeedListView(viewModel: RSSFeedViewModel(rss: self.viewModel.items[index], dataSource: DataSourceService.current.rssItem), selectedFilter: .all).environmentObject(self.viewModel.store)) {
                            EmptyView()
                        }.opacity(0.0)
                        .buttonStyle(PlainButtonStyle())
                        
                        HStack {
                            RSSRow(rss: self.viewModel.items[index]).equatable()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            
                        }.id(index)
                    }
                }.onDelete(perform: delete)
                //                .onDelete { index in
                //                    guard let index = index.first else { return }
                //                    self.viewModel.removeFeed(index: index)
                //            }
                .listRowBackground(Color("accent"))
                .environmentObject(DataSourceService.current.rss)
                .environmentObject(DataSourceService.current.rssItem)
                .environment(\.managedObjectContext, Persistence.current.context)
            }, label: {
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
    
    func insert(url: String, title: String, desc: String?, image: String?) {
        injected.interactors.rssSourcesInteractor
            .store(url: url, title: title, desc: desc ?? "", image: image ?? "")
    }
    
    func insert(rss: RSS) {
        injected.interactors.rssSourcesInteractor
            .store(source: rss)
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
        return RSSFeedListView(viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), selectedFilter: .all)
            .environmentObject(DataSourceService.current.rss)
    }
}

struct RSSListView_Previews: PreviewProvider {
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
    static var previews: some View {
        
        NavigationView {
            List() {
                RSSListView()
                    .inject(DIContainer.defaultValue)
                    .environmentObject(self.viewModel.store)
                    .environmentObject(DataSourceService.current.rss)
                    .environmentObject(DataSourceService.current.rssItem)
                    .environment(\.managedObjectContext, Persistence.current.context)
                
            }
        }.preferredColorScheme(.dark)
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
