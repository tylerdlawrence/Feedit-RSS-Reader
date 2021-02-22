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
import BetterSafariView
import SwipeCell
import FeedKit
import KingfisherSwiftUI

struct RSSFeedListView: View {
    @StateObject private var dataSource = CoreDataDataSource<RSSItem>()
    @State private var sortAscending: Bool = true
    @State private var editMode: EditMode = .inactive
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    @State private var selectedItem: RSSItem?
    @State private var start: Int = 0
    @State private var footer: String = "Refresh"
    @State var cancellables = Set<AnyCancellable>()
    @State var isRead = false
    @State var starOnly = false
    
    init(viewModel: RSSFeedViewModel) {
        self.rssFeedViewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color("accent")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            List {
                ForEach(self.rssFeedViewModel.items, id: \.self) { item in
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
                VStack(alignment: .center) {
                    Button(action: self.rssFeedViewModel.loadMore) {
                        Text(self.footer)
                    }
                }
            }
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
                                            .border(Color("text"), width: 2)
                                    })
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20,alignment: .center)
                                    .cornerRadius(2)
                                    .border(Color("text"), width: 2)
                                
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
//                        Toggle("", isOn: $starOnly)
//                            .toggleStyle(StarStyle())
                        Image(systemName: (sortAscending ? "arrow.down" : "arrow.up"))
                            .foregroundColor(Color("tab"))
                            .onTapGesture(perform: self.onToggleSort )
                                        
                        }
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                                        
                        }
                    ToolbarItem(placement: .bottomBar) {
                                
                        Toggle("", isOn: $isRead)
                            .toggleStyle(CheckboxStyle())
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
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            self.rssFeedViewModel.fecthResults()
            self.rssFeedViewModel.fetchRemoteRSSItems()
        }
    }
    func contextmenuAction(_ item: RSSItem) {
        rssFeedViewModel.archiveOrCancel(item)
    }
    public func onToggleSort() {
        self.sortAscending.toggle()
    }
}
