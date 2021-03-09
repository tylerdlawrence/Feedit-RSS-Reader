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
    
    @State private var isRead = false
    @State private var hideView = false
        
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
        
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    @State private var selectedItem: RSSItem?
    @State private var start: Int = 0
    @State private var footer: String = "Load More Articles"
    @State var cancellables = Set<AnyCancellable>()
    
    @State var sortType = "az"
    @State private var sort: Int = 0
    
    init(viewModel: RSSFeedViewModel, isRead: Bool) {
        self.rssFeedViewModel = viewModel
        self.isRead = isRead
    }
    
    var body: some View {
        ZStack {
            Color("accent")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            List {
                ForEach(self.rssFeedViewModel.items.filter { rssFeedViewModel.isOn ? $0.isArchive : true }, id: \.self) { item in
                //&& rssFeedViewModel.unreadIsOn ? $0.isRead : true
                    if !self.rssFeedViewModel.unreadIsOn || item.isRead {
                                        
                    ZStack {
                        NavigationLink(destination: WebView(rssItem: item, onCloseClosure: {})) {
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
                VStack(alignment: .center) {
                    Button(action: self.rssFeedViewModel.loadMore) {
                        HStack {
                            Text(self.footer).font(.system(size: 18, weight: .medium, design: .rounded))
                            Spacer()
//                            Image(systemName: "arrow.down.circle").font(.system(size: 18, weight: .medium, design: .rounded))
                        }.foregroundColor(Color("bg"))
                    }
                }
            }.animation(.default)
            .listStyle(PlainListStyle())
            .add(self.searchBar)
            .accentColor(Color("tab"))
            .listRowBackground(Color("accent"))
            .navigationBarTitle("", displayMode: .inline)
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: sortStarred) {
                            if sortType == "star" {
                                Text("Starred")
                                Image(systemName: "star.fill")
                            } else {
                                Text("Starred")
                                Image(systemName: "star")
                            }
                        }
                        
                        Button(action: sortUnread) {
                            if sortType == "unread" {
                                Text("Unread")
                                Image(systemName: "line.horizontal.3.decrease.circle.fill")
                            } else {
                                Text("Unread")
                                Image(systemName: "line.horizontal.3.decrease.circle")
                            }
                        }
                        Picker(selection: $sort, label: Text("Sort Articles By")) {
                                Text("Newest").tag(0)
                                Text("Oldest").tag(1)
                        }
                    }
                    label: {
                        Image(systemName: "ellipsis.circle").font(.system(size: 20, weight: .regular, design: .rounded))
                    }.accentColor(Color("tab"))
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
//        rssFeedViewModel.readOrCancel(item)
    }
    func sortStarred() { sortType = "star" }
    func sortUnread() { sortType = "unread" }
}
