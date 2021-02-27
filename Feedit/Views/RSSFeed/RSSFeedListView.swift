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

    
    @StateObject private var dataSource = CoreDataDataSource<RSSItem>()
    @State private var sortAscending: Bool = true
    @State private var editMode: EditMode = .inactive
    @State var offset : CGFloat = UIScreen.main.bounds.height
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    @State private var selectedItem: RSSItem?
    @State private var start: Int = 0
    @State private var footer: String = "Load More Articles"
    @State var cancellables = Set<AnyCancellable>()
    
    init(viewModel: RSSFeedViewModel) {
        self.rssFeedViewModel = viewModel
    }
    
//    var filteredArticles: [RSSItem] {
//        return rssFeedViewModel.filteredArticles.filter({ (item) -> Bool in
//            return !((rssFeedViewModel.isOn && item.isArchive) || (rssFeedViewModel.unreadIsOn && item.isRead))
//        })
//    }
    
    var body: some View {
        ZStack {
            Color("accent")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            List {
//                ForEach(self.rssFeedViewModel.items, id: \.self) { item in
                ForEach(self.rssFeedViewModel.items.filter {rssFeedViewModel.isOn ? $0.isArchive : true && rssFeedViewModel.unreadIsOn ? $0.isRead : true}) { item in
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
                        HStack {
                            Text(self.footer).font(.system(size: 18, weight: .medium, design: .rounded))
                            Spacer()
                            Image(systemName: "arrow.down.circle").font(.system(size: 18, weight: .medium, design: .rounded))
                        }.foregroundColor(Color("bg"))
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
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName: (sortAscending ? "arrow.down" : "arrow.up")).font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(Color("tab"))
                            .onTapGesture(perform: self.onToggleSort )
                    }
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
                        Toggle(isOn: $rssFeedViewModel.unreadIsOn) { Text("") }
                            .toggleStyle(CheckboxStyle())
//                        FilterBar(selectedFilter: $rssFeedViewModel.filterType, isOn: $rssFeedViewModel.showFilter, markedAllPostsRead: {})
                                    
                                    //self.$rssFeedViewModel.markAllPostsRead()})
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Toggle(isOn: $rssFeedViewModel.isOn) { Text("") }
                            .toggleStyle(StarStyle())
                    }
                }
            
//            VStack{
//                Spacer()
//                RSSActionSheet()
//                .offset(y: self.offset)
//                .gesture(DragGesture()
//                    .onChanged({ (value) in
//                        if value.translation.height > 0{
//                            self.offset = value.location.y
//                        }
//                    })
//                    .onEnded({ (value) in
//                        if self.offset > 100{
//                            self.offset = UIScreen.main.bounds.height
//                        }
//                        else{
//                            self.offset = 0
//                        }
//                    })
//                )
//            }.background((self.offset <= 100 ? Color(UIColor.label).opacity(0.3) : Color.clear).edgesIgnoringSafeArea(.all)
//            .onTapGesture {
//                self.offset = 0
//            })
            
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
        }.animation(.default)
//        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            self.rssFeedViewModel.fecthResults()
            self.rssFeedViewModel.fetchRemoteRSSItems()
        }
    }
    func contextmenuAction(_ item: RSSItem) {
        rssFeedViewModel.archiveOrCancel(item)
//        rssFeedViewModel.unreadOrCancel(item)
        rssFeedViewModel.setPostRead(item)
    }
    public func onToggleSort() {
        self.sortAscending.toggle()
    }
}

struct RSSFeedList_Previews: PreviewProvider {
    static let rss = RSS()
    
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
        
    static var previews: some View {
            HomeView(viewModel: self.viewModel, rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), archiveListViewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
                .environment(\.colorScheme, .dark)
                .environmentObject(DataSourceService.current.rss)
    }
}
