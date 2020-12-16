//
//  ArchiveListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//  BOOKMARKS Screen
//

import SwiftUI
import KingfisherSwiftUI
import Intents

struct ArchiveListView: View {
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var archiveListViewModel: ArchiveListViewModel
    
    @State private var selectedItem: RSSItem?
    @State var footer = "Refresh more articles"
    
    init(viewModel: ArchiveListViewModel, rssFeedViewModel: RSSFeedViewModel) {
        self.archiveListViewModel = viewModel
        self.rssFeedViewModel = rssFeedViewModel
    }
    
    private var loadMore: some View {
        Button(action: self.archiveListViewModel.loadMore) {
                Image("MarkAllAsRead")
        }
    }
    
    var body: some View {
            List {
                ForEach(self.archiveListViewModel.items, id: \.self) { item in
                    RSSItemRow(rssViewModel: rssFeedViewModel, wrapper: item)
                        .onTapGesture {
                            self.selectedItem = item
                    }
                    
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        let item = self.archiveListViewModel.items[index]
                        self.archiveListViewModel.unarchive(item)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Starred", displayMode: .inline)
            .navigationBarItems(leading: EditButton(), trailing: loadMore)

            .sheet(item: $selectedItem, content: { item in
//                if AppEnvironment.current.useSafari {
                    SafariView(url: URL(string: item.url)!)
//                } else {
//                WebView(url: URL(string: item.url)!)
//                        onArchiveAction: {
//                            self.archiveListViewModel.archiveOrCancel(item)
                
//                WebView(rssViewModel: rssFeedViewModel, wrapper: item, rss: rssSource, rssItem: item);)
                    })
//                }
//            })
            
            .onAppear {
                 UITableView.appearance().separatorStyle = .none
                
                self.archiveListViewModel.fecthResults()
        }
    }
}

extension ArchiveListView {
    
}
