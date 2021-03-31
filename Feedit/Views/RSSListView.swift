//
//  RSSListView.swift
//  Feedit
//
//  Created by Tyler Lawrence on 10/22/20
//
//
//

import SwiftUI
import CoreData
import Combine
import Foundation
import os.log

struct RSSListView: View {
    @EnvironmentObject var rssDataSource: RSSDataSource
    @Environment(\.managedObjectContext) private var viewContext
    var viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    @State private var revealFeedsDisclosureGroup = false

    var body: some View {
        VStack {
            DisclosureGroup(
                    isExpanded: $revealFeedsDisclosureGroup,
                    content: {
                    ForEach(viewModel.items, id: \.self) { rss in
                        ZStack {
                            NavigationLink(destination: self.destinationView(rss: rss)
                                            //.onReceive(rss.objectWillChange) { _ in
                                              //  self.viewModel.objectWillChange.send()
                                                         // }
                            ) {
                                EmptyView()
                            }
                            .opacity(0.0)
                            .buttonStyle(PlainButtonStyle())
                            HStack {
                                RSSRow(rss: rss, viewModel: viewModel)
                            }
                        }
                    }.onDelete(perform: delete)
//                    .onDelete { indexSet in
//                        if let index = indexSet.first {
//                            self.viewModel.delete(at: index)
//                        }
//                    }
                    .onAppear {
                        self.viewModel.fecthResults()
                    }
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
                .listRowBackground(Color("darkerAccent"))
                .accentColor(Color("tab"))
        }
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
        return RSSFeedListView(rss: rss, viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), rssItem: item, filter: .all)
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
