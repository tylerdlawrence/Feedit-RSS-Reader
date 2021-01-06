//
//  ArchiveListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//  BOOKMARKS Screen
//

import SwiftUI
import UIKit
import KingfisherSwiftUI
import Intents
import SwipeCell
import SwipeCellKit

struct ArchiveListView: View {
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var archiveListViewModel: ArchiveListViewModel
    @ObservedObject var searchBar: SearchBar = SearchBar()
    @State private var isShowing = false

    @State private var selectedItem: RSSItem?
    @State var footer = "Refresh more articles"
    
    init(viewModel: ArchiveListViewModel, rssFeedViewModel: RSSFeedViewModel) {
        self.archiveListViewModel = viewModel
        self.rssFeedViewModel = rssFeedViewModel
    }
    
    private var loadMore: some View {
        Button(action: self.archiveListViewModel.loadMore) {
//                Image("MarkAllAsRead")
            Image(systemName: "arrow.counterclockwise")
            
        }
    }
    
    private var trailingView: some View {
        HStack(alignment: .top, spacing: 24) {
            //EditButton()
            loadMore
        }
    }
    
    private var markAllRead: some View {
        Button(action: {
            print ("Mark all as Read")
        }) {
            Image("MarkAllAsRead")
        }
    }
    
    var body: some View {
        ZStack{
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
            .pullToRefresh(isShowing: $isShowing) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isShowing = false
                }
            }
            .padding(.bottom)
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle("Starred", displayMode: .automatic)
        //.navigationBarItems(trailing: trailingView)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                markAllRead
                    .frame(width: 44, height: 44)
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(placement: .bottomBar) {
                Button(action: self.archiveListViewModel.loadMore) {
                    Image(systemName: "arrow.counterclockwise")
                        .frame(width: 44, height: 44)
                }
            }
        }
        .add(self.searchBar)
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
            self.archiveListViewModel.fecthResults()
        }
    }
}

extension ArchiveListView {
    
}


