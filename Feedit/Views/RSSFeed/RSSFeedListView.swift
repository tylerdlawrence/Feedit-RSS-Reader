//
//  RSSItemListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import Foundation
import Combine
import UIKit
import SwipeCell
import FeedKit
import KingfisherSwiftUI

struct RSSFeedListView: View {
    
    enum FilterType {
        case all, unreadIsOn, isArchive
    }

    let filter: FilterType

    var filterTitle: String {
        switch filter {
        case .all:
            return "All"
        case .isArchive:
            return "Starred"
        case .unreadIsOn:
            return "Unread"
        }
    }
    
//    @State var selectedFilter: FilterType
    var filteredArticles: [RSSItem] {
        return rssFeedViewModel.items.filter({ (item) -> Bool in
            return !((self.rssFeedViewModel.isOn && !item.isArchive) || (self.rssFeedViewModel.unreadIsOn && item.isRead))
        })
    }
            
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @ObservedObject var rssItem: RSSItem
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    @State private var selectedItem: RSSItem?
    @State private var start: Int = 0
    @State private var footer: String = "Refresh"
    @State var cancellables = Set<AnyCancellable>()
    
    let rss:RSS
    init(rss: RSS, viewModel: RSSFeedViewModel, rssItem: RSSItem, filter: FilterType) {
        self.rss = rss
        self.rssFeedViewModel = viewModel
        self.rssItem = rssItem
        self.filter = filter
    }
//    var markAllPostsRead: (() -> Void)?
    
    private var refreshButton: some View {
        Button(action: self.rssFeedViewModel.loadMore) {
            Image(systemName: "arrow.clockwise").font(.system(size: 16, weight: .bold)).foregroundColor(Color("tab")).padding()
        }.buttonStyle(BorderlessButtonStyle())
    }
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            List {
                
                ForEach(filteredArticles) { item in
                    ZStack {
                        NavigationLink(destination: RSSFeedDetailView(rssItem: item, rssFeedViewModel: self.rssFeedViewModel)) {
                            EmptyView()
                        }
                        .opacity(0.0)
                        .buttonStyle(PlainButtonStyle())
                        
                        HStack {
                            RSSItemRow(rssItem: item, menu: self.contextmenuAction(_:), rssFeedViewModel: rssFeedViewModel)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    self.selectedItem = item
                            }
                        }
                    }
                }
                .environmentObject(DataSourceService.current.rss)
                .environmentObject(DataSourceService.current.rssItem)
                .environment(\.managedObjectContext, Persistence.current.context)

            }
            .animation(.easeInOut)
            .add(self.searchBar)
            .accentColor(Color("tab"))
            .listRowBackground(Color("accent"))
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: refreshButton)
            .onAppear { }
            .toolbar{
                ToolbarItem(placement: .principal) {
                    HStack{
                        KFImage(URL(string: rssSource.image))
                            .placeholder({
                                Image("getInfo")
                                    .renderingMode(.original).resizable().aspectRatio(contentMode: .fit).frame(width: 20, height: 20,alignment: .center).cornerRadius(2)
                            })
                            .renderingMode(.original).resizable().aspectRatio(contentMode: .fit).frame(width: 20, height: 20,alignment: .center).cornerRadius(2)

                        Text(rssSource.title)
                            .font(.system(size: 20, weight: .medium, design: .rounded))

                        UnreadCountView(count: filteredArticles.count)

                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    Toggle(isOn: $rssFeedViewModel.unreadIsOn) { Text("") }
                        .toggleStyle(CheckboxStyle())
                }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    Toggle(isOn: $rssFeedViewModel.isOn) { Text("") }
                        .toggleStyle(StarStyle())
                }
            }
//            .modifier(ToolbarModifier(rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem)))
            .sheet(item: $selectedItem, content: { item in
                if UserEnvironment.current.useSafari {
                    SafariView(url: URL(string: item.url)!)
                } else {
                    WebView(
                        rssItem: item,
                        onCloseClosure: {
                            self.selectedItem = nil
                        },
                        onArchiveClosure: {
                            self.rssFeedViewModel.archiveOrCancel(item)
                        }
                    ).environmentObject(DataSourceService.current.rss)
                }
            })
        }
        .onAppear {
            self.rssFeedViewModel.fecthResults()
            self.rssFeedViewModel.fetchRemoteRSSItems()
        }
    }
    func contextmenuAction(_ item: RSSItem) {
        rssFeedViewModel.archiveOrCancel(item)
    }
}
