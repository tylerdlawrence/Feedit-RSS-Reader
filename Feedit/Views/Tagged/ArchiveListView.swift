//
//  ArchiveListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//  BOOKMARKS Screen
//

import SwiftUI
import UIKit
import SwiftUIX
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
            Image(systemName: "arrow.counterclockwise")
                .imageScale(.small)
                .frame(width: 44, height: 44)
        }
    }
    
    private var trailingView: some View {
        HStack(alignment: .top, spacing: 24) {
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
//                    NavigationLink(destination: WebView(rssViewModel: rssFeedViewModel, wrapper: item, rss: rssSource, rssItem: item, url: URL(string: item.url)!)) {
                        
                        RSSItemRow(rssViewModel: rssFeedViewModel, wrapper: item)
                            .onTapGesture {
                                self.selectedItem = item
                    }
                //}
            }
                
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        let item = self.archiveListViewModel.items[index]
                        self.archiveListViewModel.unarchive(item)
                    }
                }

            }
            .onAppear {
                self.archiveListViewModel.fecthResults()
            }
//            .pullToRefresh(isShowing: $isShowing) {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    self.isShowing = false
//                }
//            }
            .padding(.bottom)
        //}
            .listStyle(PlainListStyle())
            .navigationBarItems(trailing: loadMore)

        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack{
                    HStack{
                        Image(systemName: "star.fill")
                            .imageScale(.small)
                            .foregroundColor(Color("bg"))
                        Text("Starred")
                            .font(.system(.body))
                            .fontWeight(.bold)
                        Text("\(archiveListViewModel.items.count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 1)
                            .background(Color("darkShadow"))
                            .foregroundColor(Color("text"))
                            .cornerRadius(8)
                    }
                    Text("Today at ")
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .font(.system(.footnote)) +
                        Text(Date(), style: .time)
                        .font(.system(.footnote))
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                }
            }
        }
//        .toolbar {
//            ToolbarItem(placement: .bottomBar) {
//                Spacer()
//            }
//            ToolbarItem(placement: .bottomBar) {
//                Spacer()
//            }
//            ToolbarItem(placement: .bottomBar) {
//                markAllRead
//                    .frame(width: 44, height: 44)
//            }
//        }
        .add(self.searchBar)
        .sheet(item: $selectedItem, content: { item in
            SafariView(url: URL(string: item.url)!)

//                if AppEnvironment.current.useSafari {
//                SafariView(url: URL(string: item.url)!)
//                } else {
//                WebView(url: URL(string: item.url)!)
//                        onArchiveAction: {
//                            self.archiveListViewModel.archiveOrCancel(item)
//                WebView(rssViewModel: rssFeedViewModel, wrapper: item, rss: rssSource, rssItem: item);)
                    })
//                }
//            })
            
//        .onAppear {
//            self.archiveListViewModel.fecthResults()
//            }
        }
    }
}

extension ArchiveListView {
    
}


