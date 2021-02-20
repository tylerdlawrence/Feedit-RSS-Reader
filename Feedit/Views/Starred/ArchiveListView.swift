//
//  ArchiveListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//
//

import SwiftUI
import UIKit
import KingfisherSwiftUI
import Intents
import SwipeCell

struct ArchiveListView: View {
    enum FilterType {
        case all, unread, starred
    }
//    var rssSource: RSS {
//        return self.rssFeedViewModel.rss
//    }
//    @ObservedObject var rss: RSS
    @EnvironmentObject var rssDataSource: RSSDataSource
//    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var archiveListViewModel: ArchiveListViewModel
    @ObservedObject var searchBar: SearchBar = SearchBar()
    var markAllPostsRead: (() -> Void)?
    var markPostRead: (() -> Void)?
    @State var showStarOnly = true
    @State private var selectedItem: RSSItem?
    @State var footer = "Load More Articles"
    
    init(viewModel: ArchiveListViewModel) {
        self.archiveListViewModel = viewModel
//        self.rssFeedViewModel = rssFeedViewModel
    }
    
    var body: some View {
        ZStack {
            Color("accent")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            List {
                ForEach(self.archiveListViewModel.items, id: \.self) { item in
                    ZStack{
                        NavigationLink(destination: WebView(rssItem: item, onCloseClosure: {})) {
                            EmptyView()
                        }
                        .opacity(0.0)
                        .buttonStyle(PlainButtonStyle())
                        
                        HStack{
                            RSSItemRow(wrapper: item)
                                .onTapGesture {
                                    self.selectedItem = item
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            let item = self.archiveListViewModel.items[index]
                            self.archiveListViewModel.unarchive(item)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
        .navigationBarTitle("", displayMode: .inline)

            .add(self.searchBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack{
                        HStack{
                            Text("Starred")
                                .font(.system(.body))
                                .fontWeight(.bold)
                            Text("\(archiveListViewModel.items.count)")
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
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    FilterBar(selectedFilter: .constant(.starredOnly),
                               showFilter: .constant(true), markedAllPostsRead: nil)
                }
            }
//            .sheet(item: $selectedItem, content: { item in
//                if AppEnvironment.current.useSafari {
//                    SafariView(url: URL(string: item.url)!)
//                } else {
//                    WebView(
//                        rssItem: item,
//                        onCloseClosure: {
//
//                        },
//                        onArchiveClosure: {
//                            self.viewModel.archiveOrCancel(item)
//                    })
//                }
//            })
            .onAppear {
                self.archiveListViewModel.fecthResults()
        }
    }
}

extension ArchiveListView {

}

struct ArchiveListView_Previews: PreviewProvider {
//    static let db = DataSourceService.current
//
//    static var viewModel = DataNStorageViewModel(rss: db.rss, rssItem: db.rssItem)
//
//    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
//
//    static let rssFeedViewModel = RSSFeedViewModel(rss: RSS(context: Persistence.current.context), dataSource: DataSourceService.current.rssItem)
//
//    static let rssViewModel = RSSListViewModel(dataSource: DataSourceService.current.rss, rss: db.rss, rssItem: db.rssItem)
//    static let rss = RSS()
//    static let rss = DataSourceService.current
    static var previews: some View {
        ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
    }
}

