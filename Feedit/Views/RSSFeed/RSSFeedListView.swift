//
//  RSSItemListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import FeedKit
import Combine
import KingfisherSwiftUI
import SwiftUIRefresh

struct RSSFeedListView: View {
    
    var feed = ""
    @State var searchText: String = ""
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    let refreshControl: RefreshControl = RefreshControl()
    @State var scrollView: UIScrollView?

    @EnvironmentObject var rssDataSource: RSSDataSource
    
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    
    @State var isRefreshing: Bool = false
    @State private var isShowing = false

    @State private var selectedItem: RSSItem?
    @State private var isSafariViewPresented = false
    @State private var start: Int = 0
    @State var cancellables = Set<AnyCancellable>()

    init(rssViewModel: RSSFeedViewModel) {
        self.rssFeedViewModel = rssViewModel
    }
    
    private var infoListView: some View {
        Button(action: {
            print ("feed info")
        }) {
            Image(systemName: "info.circle")
        }
    }
    
    private var markAllRead: some View {
        Button(action: {
            print ("Mark all as Read")
        }) {
            Image("MarkAllAsRead")
        }
    }
    
    private var trailingButtons: some View {
        HStack(alignment: .top, spacing: 24) {
            infoListView
            markAllRead
        }
    }
    
    func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.isRefreshing = false
        }
    }
    
    var body: some View {
        ZStack{
//            List(rssFeedViewModel.items, id: \.id) { item in  //{
//                ScrollViewResolver(for: refreshControl)
//                ForEach(1...100, id: \.self) { eachRowIndex in
//                    //Text("Row \(eachRowIndex)")
//                    NavigationLink(destination: WebView(rssViewModel: rssFeedViewModel, wrapper: item, rss: rssSource, rssItem: item, url: URL(string: item.url)!)) {
//                    RSSItemRow(rssViewModel: rssFeedViewModel, wrapper: item, menu: self.contextmenuAction(_:))
//                    }
//                }
//            }
//                .onAppear {
//                    self.refreshControl.onValueChanged = {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                            self.refreshControl.refreshControl?.endRefreshing()
//                        }
//                    }
//                }

            List(rssFeedViewModel.items, id: \.id) { item in

                NavigationLink(destination: WebView(rssViewModel: rssFeedViewModel, wrapper: item, rss: rssSource, rssItem: item, url: URL(string: item.url)!)) {
                                
                    RSSItemRow(rssViewModel: rssFeedViewModel, wrapper: item, menu: self.contextmenuAction(_:))

                }
//                .opacity(isRefreshing ? 0.2 : 1.0)
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle(rssSource.title, displayMode: .automatic)
            .add(self.searchBar)
            .pullToRefresh(isShowing: $isShowing) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isShowing = false
                }
            }
            .navigationBarItems(trailing:
                Button(action: self.rssFeedViewModel.loadMore) {
                    Image("MarkAllAsRead")
                })
            
//            .sheet(item: $selectedItem, content: { item in
//                if AppEnvironment.current.useSafari {
//                    SafariView(url: URL(string: item.url)!)
//                } else {
//                    WebView(
//                        rssItem: item,
//                        onArchiveAction: {
//                            self.rssFeedViewModel.archiveOrCancel(item)
//                    })
//                }
//            })
            
           }
        
            .onAppear {
                self.rssFeedViewModel.fecthResults()
                self.rssFeedViewModel.fetchRemoteRSSItems()
                self.isRefreshing = true
                self.refresh()
//                self.refreshControl.onValueChanged = {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                        self.refreshControl.refreshControl?.endRefreshing()
//                    }
//                }
        }
    }
    
    func contextmenuAction(_ item: RSSItem) {
        rssFeedViewModel.archiveOrCancel(item)
    }
}
