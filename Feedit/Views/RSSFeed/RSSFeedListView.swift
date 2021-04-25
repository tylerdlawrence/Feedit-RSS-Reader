//
//  RSSItemListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import URLImage
import Introspect
import Foundation
import Combine
import UIKit
import SwipeCell
import FeedKit
import KingfisherSwiftUI
import SDWebImageSwiftUI

struct RSSFeedListView: View {
    
    var filterTitle: String {
        switch selectedFilter {
        case .all:
            return "All"
        case .isArchive:
            return "Starred"
        case .unreadIsOn:
            return "Unread"
        }
    }
    
    @State var selectedFilter: FilterType = .unreadIsOn
    var filteredArticles: [RSSItem] {
        return rssFeedViewModel.items.filter({ (item) -> Bool in
            return !((self.rssFeedViewModel.isOn && !item.isArchive) || (self.rssFeedViewModel.unreadIsOn && item.isRead))
        })
    }
    
    var rssSource: RSS? {
        return self.rssFeedViewModel.rss
    }
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var searchBar: SearchBar = SearchBar()
    @State var isShowing: Bool = false
    @State var selectedItem: RSSItem?
    @State private var start: Int = 0
    @State private var footer: String = "Refresh"
    @State var cancellables = Set<AnyCancellable>()
    
    var rss = RSS()
        
    init(viewModel: RSSFeedViewModel, selectedFilter: FilterType) {
        self.rssFeedViewModel = viewModel
        self.selectedFilter = selectedFilter
    }
    
    private var refreshButton: some View {
        Button(action: self.rssFeedViewModel.loadMore) {
            Image(systemName: "arrow.clockwise").font(.system(size: 16, weight: .bold)).foregroundColor(Color("tab")).padding()
        }.buttonStyle(BorderlessButtonStyle())
    }
    
    private var navButtons: some View {
        HStack(alignment: .center, spacing: 30) {
            Toggle(isOn: $rssFeedViewModel.unreadIsOn) { Text("") }
                .toggleStyle(CheckboxStyle()).padding(.leading)
            Spacer(minLength: 1)
            Picker("", selection: $selectedFilter, content: {
                ForEach(FilterType.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }).pickerStyle(SegmentedPickerStyle()).frame(width: 180, height: 20).hidden()
            .listRowBackground(Color("accent"))
            
            Spacer(minLength: 0)
            
            Toggle(isOn: $rssFeedViewModel.isOn) { Text("") }
                .toggleStyle(StarStyle()).padding(.trailing)
        }
    }
        
    @State private var showMarkAllAsReadAlert = false
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ZStack {
                List {
                    ForEach(self.filteredArticles) { item in
                        ZStack {
                            NavigationLink(destination: NavigationLazyView(RSSFeedDetailView(rssItem: item, rssFeedViewModel: self.rssFeedViewModel))) {
                                EmptyView()
                            }
                            .opacity(0.0)
                            .buttonStyle(PlainButtonStyle())

                            HStack(spacing: nil) {
                                
                                RSSItemRow(rssItem: item, menu: self.contextmenuAction(_:), rssFeedViewModel: self.rssFeedViewModel)
                                    
                                
                                    
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
                .pullToRefresh(isShowing: $isShowing) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.isShowing = false
                        rssFeedViewModel.fecthResults()
                        rssFeedViewModel.fetchRemoteRSSItems()
                    }
                }
                .add(self.searchBar)
                .accentColor(Color("tab"))
                .listRowBackground(Color("accent"))
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarItems(trailing:
                                        Button(action: {
                                            showMarkAllAsReadAlert.toggle()
                                            rssFeedViewModel.items.forEach { (item) in
                                                item.isRead = true
                                                rssFeedViewModel.items.removeAll()
                                                saveContext()
                                            }
                                        }) {
                                            Image(systemName: "checkmark.circle").font(.system(size: 18)).foregroundColor(Color("tab"))
                                        }
                )
            }
            Spacer()
            navButtons
                .frame(width: UIScreen.main.bounds.width, height: 49)
                .toolbar{
                    ToolbarItem(placement: .principal) {
                        HStack {
                            KFImage(URL(string: rssSource?.image ?? ""))
                                .placeholder({
                                    Image("getInfo")
                                        .renderingMode(.original).resizable().aspectRatio(contentMode: .fit).frame(width: 20, height: 20,alignment: .center).cornerRadius(2).clipped()
                                })
                                .renderingMode(.original).resizable().aspectRatio(contentMode: .fit).frame(width: 20, height: 20,alignment: .center).cornerRadius(2).clipped()
                            
                            Text(rssSource?.title ?? "")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                            
                            UnreadCountView(count: filteredArticles.count)
                            
                        }
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
    private func saveContext() {
        do {
            try Persistence.current.context.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved Error: \(error)")
        }
    }
}

struct RSSFeedListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ForEach(0..<6) { index in
                RSSFeedListView(viewModel: RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem), selectedFilter: .all)
            }
        }.preferredColorScheme(.dark)
    }
}
