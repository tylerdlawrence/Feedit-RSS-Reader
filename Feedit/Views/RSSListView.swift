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
    @State private var isShowingDeleteConfirmation: Bool = false
    @State private var deletionOffsets: IndexSet = []
    
    @ObservedObject var feed = RSSStore.instance
    @Environment(\.injected) private var injected: DIContainer
    
    func filterFeeds(url: String?) -> RSS? {
        guard let url = url else { return nil }
        return viewModel.items.first(where: { $0.url == url })
    }
    
//    @FetchRequest(
//            sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//            animation: .default)
//        private var items: FetchedResults<Item>
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $revealFeedsDisclosureGroup,
            content: {
                
                ForEach(viewModel.items.indices, id: \.self) { index in
                    ZStack {
                        NavigationLink(destination:
                                        RSSFeedListView(rssItem: RSSItem(), viewModel: RSSFeedViewModel(rss: self.viewModel.items[index], dataSource: DataSourceService.current.rssItem), selectedFilter: .all).environmentObject(self.viewModel.store)) {
                            EmptyView()
                        }.opacity(0.0)
                        .buttonStyle(PlainButtonStyle())
                        
                        HStack {
                            RSSRow(rss: self.viewModel.items[index]).equatable()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            
                        }.id(index)
                    }
                }.onDelete { offsets in
                    self.delete(offsets: offsets)
                    self.isShowingDeleteConfirmation = true
                }//.onDelete(perform: delete)
                .listRowBackground(Color("accent"))
                .environmentObject(DataSourceService.current.rss)
                .environmentObject(DataSourceService.current.rssItem)
                .environment(\.managedObjectContext, Persistence.current.context)
                .actionSheet(isPresented: $isShowingDeleteConfirmation) {
                            ActionSheet(title: Text("Unsubscribe?"), message: Text("The action is not reversible"), buttons: [
                                .destructive(Text("Unsubscribe"), action: { self.viewModel.items.remove(atOffsets: self.deletionOffsets) }),
                                .cancel()
                            ])
                        }
                
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
        return RSSFeedListView(rssItem: RSSItem(), viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), selectedFilter: .all)
            .environmentObject(DataSourceService.current.rss).environmentObject(DataSourceService.current.rssItem)
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
