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
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    
    @ObservedObject var searchBar = SearchBar();
    @ObservedObject var searchResult = SearchResult()
    @State var isSearchClicked = false
    @State var isShowing: Bool = false
    @State var selectedItem: RSSItem?
    @State private var start: Int = 0
    @State private var footer: String = "Refresh"
    @State var cancellables = Set<AnyCancellable>()
    
    var rss = RSS()
    @ObservedObject var rssItem: RSSItem
            
    init(rssItem: RSSItem, viewModel: RSSFeedViewModel, selectedFilter: FilterType) {
        self.rssItem = rssItem
        self.rssFeedViewModel = viewModel
        self.selectedFilter = selectedFilter
        
    }
    
    private func articleImage(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipped()
            .cornerRadius(3)
            .frame(width: 22, height: 22)
            //.frame(width: 60, height: 60)
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
    
//    let options = URLImageOptions(identifier: "imageUrl")
//    @State private var sample: SampleURLs = .midRes50
//    let urls = [URL]()
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ZStack {
                List {
                    ForEach(self.filteredArticles, id: \.self) { item in
                        ZStack {
                            NavigationLink(destination: RSSFeedDetailView(withURL: item.url, rssItem: item, rssFeedViewModel: self.rssFeedViewModel)) {
                            
                                EmptyView()
                            }
                            .opacity(0.0)
                            .buttonStyle(PlainButtonStyle())

                            HStack {
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
                            KFImage(URL(string: rssSource.image ?? ""))
                                .placeholder({
                                    Image("getInfo")
                                        .renderingMode(.original).resizable().aspectRatio(contentMode: .fit).frame(width: 20, height: 20,alignment: .center).cornerRadius(2).clipped()
                                })
                                .renderingMode(.original).resizable().aspectRatio(contentMode: .fit).frame(width: 20, height: 20,alignment: .center).cornerRadius(2).clipped()
                            
                            Text(rssSource.title)
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
            List {
                ForEach(0..<10) { item in
                    RSSItemRow(rssItem: RSSItem.create(uuid: UUID(), title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor", desc: "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", author: "", url: "https://github.blog/feed/", in: Persistence.previews.context), rssFeedViewModel: RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem))
                }
            }.navigationBarTitle("Articles", displayMode: .inline)
        }.preferredColorScheme(.dark)
    }
}

//struct NavigationLazyView<Content: View>: View {
//   let build: () -> Content
//
//   init(_ build: @autoclosure @escaping () -> Content) {
//       self.build = build
//   }
//
//   var body: Content {
//       build()
//   }
//}
