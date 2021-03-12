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
//    enum FilterType {
//        case all, starred, unread
//    }
//
//    let filter: FilterType
//
//    var filterTitle: String {
//        switch filter {
//        case .all:
//            return "All"
//        case .starred:
//            return "Starred"
//        case .unread:
//            return "Unread"
//        }
//    }
//    var filteredArticleList: [RSSItem] {
//        switch filter {
//        case .all:
//            return rssFeedViewModel.items
//        case .starred:
//            return rssFeedViewModel.items.filter { item in
//                (!rssFeedViewModel.isOn || item.isArchive)}
//        case .unread:
//            return rssFeedViewModel.items.filter { item in
//                (!rssFeedViewModel.unreadIsOn || item.isRead)
//            }
//        }
//    }
    
    var filteredArticles: [RSSItem] {
        return rssFeedViewModel.items.filter({ (item) -> Bool in
            return !((self.rssFeedViewModel.isOn && !item.isArchive) || (self.rssFeedViewModel.unreadIsOn && item.isRead))
        })
    }
        
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    @ObservedObject var itemWrapper: RSSItem
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    @State private var selectedItem: RSSItem?
    @State private var start: Int = 0
    @State private var footer: String = "Refresh"
    @State var cancellables = Set<AnyCancellable>()
    
    init(viewModel: RSSFeedViewModel, wrapper: RSSItem) {
        self.rssFeedViewModel = viewModel
        itemWrapper = wrapper
    }
    
    private var refreshButton: some View {
        Button(action: self.rssFeedViewModel.loadMore) {
            Image(systemName: "arrow.clockwise").font(.system(size: 16, weight: .bold)).foregroundColor(Color("tab")).padding()
        }.buttonStyle(BorderlessButtonStyle())
    }
    
    var body: some View {
        
        ZStack {
            Color("accent")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            List {
                ForEach(filteredArticles) { item in
                    ZStack {
//                        NavigationLink(destination: WebView(rssItem: item, onCloseClosure: {})) {
//                            EmptyView()
//                        }
                        NavigationLink(destination: RSSFeedDetailView(rssItem: item, rssFeedViewModel: self.rssFeedViewModel)) {
                            EmptyView()
                        }
                        .opacity(0.0)
                        .buttonStyle(PlainButtonStyle())
                        HStack {
                            RSSItemRow(wrapper: item, menu: self.contextmenuAction(_:))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    self.selectedItem = item
                                }
                            }
                        }
                    }


            }
            .animation(.default)
            .add(self.searchBar)
            .accentColor(Color("tab"))
            .listRowBackground(Color("accent"))
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: refreshButton)
            .onAppear {
                
            }
            .toolbar{
                ToolbarItem(placement: .principal) {
                    HStack{
                        KFImage(URL(string: rssSource.image))
                            .placeholder({
                                Image("getInfo")
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20,alignment: .center)
                                    .cornerRadius(2)
                                    .border(Color("text"), width: 1)
                            })
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20,alignment: .center)
                            .cornerRadius(2)
                            .border(Color("text"), width: 1)
                        
                        Text(rssSource.title)
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                        
                        Text("\(rssFeedViewModel.items.count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 1)
                            .background(Color.gray.opacity(0.5))
                            .opacity(0.4)
                            .foregroundColor(Color("text"))
                            .cornerRadius(8)
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
                    )
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

struct RSSFeedListView_Previews: PreviewProvider {
    static let rss = RSS()
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

    static var previews: some View {
        Group{
            HomeView(viewModel: self.viewModel, rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), archiveListViewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
            .environment(\.colorScheme, .dark)
        }.environmentObject(DataSourceService.current.rss)
    }
}


//struct StarArticleButton: View {
//    @Binding var isArchive: Bool
//
//    var body: some View {
//        Button(action: {
//            isArchive.toggle()
//        }) {
//            Image(systemName: isArchive ? "star.fill" : "star")
//                .foregroundColor(isArchive ? Color.yellow : Color.gray)
//        }
//    }
//}
//
//struct StarArticleButtonButton_Previews: PreviewProvider {
//    static var previews: some View {
//        StarArticleButton(isArchive: .constant(true))
//    }
//}
