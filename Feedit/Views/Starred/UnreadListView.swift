////
////  UnreadListView.swift
////  Feedit
////
////  Created by Tyler D Lawrence on 2/17/21.
////
//
//import SwiftUI
//import UIKit
//import KingfisherSwiftUI
//import Intents
//import SwipeCell
//
//struct UnreadListView: View {
//    enum FilterType {
//        case all, unread, starred
//    }
//    var rssSource: RSS {
//        return self.rssFeedViewModel.rss
//    }
//    @EnvironmentObject var rssDataSource: RSSDataSource
//    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
//    @ObservedObject var unreadListViewModel: UnreadListViewModel
//    @ObservedObject var searchBar: SearchBar = SearchBar()
//    var markAllPostsRead: (() -> Void)?
//    var markPostRead: (() -> Void)?
//    @State private var selectedItem: RSSItem?
//    
//    init(unreadListViewModel: UnreadListViewModel, rssFeedViewModel: RSSFeedViewModel) {
//        self.unreadListViewModel = unreadListViewModel
//        self.rssFeedViewModel = rssFeedViewModel
//    }
//    
//    var body: some View {
//        ZStack {
//            Color("accent")
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .edgesIgnoringSafeArea(.all)
//            List {
//                ForEach(self.unreadListViewModel.unread, id: \.self) { unreadItem in
//                    ZStack{
//                        NavigationLink(destination: WebView(rssItem: unreadItem, onCloseClosure: {})) {
//                            EmptyView()
//                        }
//                        .opacity(0.0)
//                        .buttonStyle(PlainButtonStyle())
//                        
//                        HStack{
//                            RSSItemRow(rssFeedViewModel: rssFeedViewModel, wrapper: unreadItem)
//                                .onTapGesture {
//                                    self.selectedItem = unreadItem
//                                }
//                            }
//                        }
//                    }
//                }
//            .listStyle(PlainListStyle())
//            .navigationBarTitle("", displayMode: .inline)
//            .add(self.searchBar)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    VStack{
//                        HStack{
//                            Text("Unread")
//                                .font(.system(.body))
//                                .fontWeight(.bold)
//                            Text("\(unreadListViewModel.unread.count)")
//                                .font(.caption)
//                                .fontWeight(.bold)
//                                .padding(.horizontal, 7)
//                                .padding(.vertical, 1)
//                                .background(Color.gray.opacity(0.5))
//                                .opacity(0.4)
//                                .foregroundColor(Color("text"))
//                                .cornerRadius(8)
//                        }
//                    }
//                }
//            }
//            }
//            .onAppear {
//                self.unreadListViewModel.fecthResults()
//        }
//    }
//}
//
//extension UnreadListView {
//    
//}
//
//struct UnreadListView_Previews: PreviewProvider {
//    static let db = DataSourceService.current
//    static var viewModel = DataNStorageViewModel(rss: db.rss, rssItem: db.rssItem)
//    static let unreadListViewModel = UnreadListView(unreadListViewModel: UnreadListViewModel(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: rssFeedViewModel)
//    static let rssFeedViewModel = RSSFeedViewModel(rss: RSS(context: Persistence.current.context), dataSource: DataSourceService.current.rssItem)
//    static let rssViewModel = RSSListViewModel(dataSource: DataSourceService.current.rss, rss: db.rss, rssItem: db.rssItem)
//    
//    static var previews: some View {
//        UnreadListView(unreadListViewModel: UnreadListViewModel(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: self.rssFeedViewModel)
//    }
//}
