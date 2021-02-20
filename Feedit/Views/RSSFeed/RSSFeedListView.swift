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

final class UserData: ObservableObject {
    @Published var starOnly = false
    @Published var unreadOnly = false
}

struct RSSFeedListView: View {
    enum FilterType {
        case all, unread, starred
    }
    //    enum FilterType {
    //        case all, unread, starred
    //    }
    //    let filter: FilterType
    //    var filteredPosts: [RSS] {
    //        switch filter {
    //        case .all:
    //            return viewModel.items
    //        case .unread:
    //            return viewModel.items.filter { $0.isRead }
    //        case .starred:
    //            return viewModel.items.filter { !$0.isArchive }
    //        }
    //    }
    @EnvironmentObject private var userData: UserData
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rss: RSS
    @ObservedObject var searchBar: SearchBar = SearchBar()
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    @State private var items: [RSSItem] = []
    let store = RSSItemStore()
    var markAllPostsRead: (() -> Void)?
    var markPostRead: (() -> Void)?
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    
    @State private var selectedItem: RSSItem?
    @State private var presentingSafariView = false
    @State private var isSafariViewPresented = false
    @State private var start: Int = 0
    @State private var footer: String = "load more"
    @State var cancellables = Set<AnyCancellable>()
    @State private var isRead = false
    @State var starOnly = false
    @State var unreadOnly = false
    
    init(viewModel: RSSFeedViewModel, rss: RSS) {
        self.rssFeedViewModel = viewModel
        self.rss = rss
    }

    func footerView() -> some View {
        VStack(alignment: .center){
            HStack(alignment: .center){
                KFImage(URL(string: rssSource.image))
                    .placeholder({
                        Image("Thumbnail")
                            .renderingMode(.original)
                           .resizable()
                           .aspectRatio(contentMode: .fit)
                           .frame(width: 20, height: 20,alignment: .center)
                           .cornerRadius(5)
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20,alignment: .center)
                    .cornerRadius(5)
                    .border(Color.clear, width: 0)
                Text(rssSource.title)
                    .font(.system(.body))
                    .fontWeight(.bold)
                Spacer()
                Text("\(rssFeedViewModel.items.count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 1)
                    .background(Color("darkShadow"))
                    .opacity(0.4)
                    .foregroundColor(Color("text"))
                    .cornerRadius(8)
                Spacer()
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color("accent")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            List {
//                Toggle(isOn: $userData.starOnly) {
//                    Text("Starred Only")
//                }.toggleStyle(CheckboxStyle())
                
                ForEach(self.rssFeedViewModel.items, id: \.self) { item in
//                    if !self.unreadOnly || item.isRead {
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
            .background(Color.clear)
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
                                        Image("Thumbnail")
                                            .renderingMode(.original)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 25, height: 25,alignment: .center)
                                            .cornerRadius(2)
                                            .border(Color.clear, width: 1)
                                    })
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25,alignment: .center)
                                    .cornerRadius(2)
                                    .border(Color.clear, width: 1)
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
                                
                        Toggle("", isOn: $starOnly)
                            .toggleStyle(StarStyle())
                                        
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
//                item in
//                if AppEnvironment.current.useSafari {
//                    SafariView(url: URL(string: item.url)!)
//                } else {
                    WebView(
                        rssItem: item,
                        onCloseClosure: {
                            self.selectedItem = nil
                        },
                        onArchiveAction: {
                            self.rssFeedViewModel.archiveOrCancel(item)
                        }
//                        , onReadAction:
//                            self.rssFeedViewModel.readOrCancel(item)
                    )
                }
            )
//            })
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
}
//    var body: some View {
//        ZStack {
//            Color("accent")
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .edgesIgnoringSafeArea(.all)
//            List {
//                ForEach(self.rssFeedViewModel.items, id: \.self) { item in
//                    ZStack {
//                        NavigationLink(destination: WebView(rssItem: item, onCloseClosure: {})) {
//
//                            EmptyView()
//                        }
//                        .opacity(0.0)
//                        .buttonStyle(PlainButtonStyle())
//
//                        HStack {
//                            RSSItemRow(rssFeedViewModel: rssFeedViewModel, wrapper: item, menu: self.contextmenuAction(_:))
//                                .contentShape(Rectangle())
//                                .onTapGesture {
//                                    self.selectedItem = item
//                                }
//                            }
//                        }
//                    }
//                }
//                .listStyle(PlainListStyle())
//                .add(self.searchBar)
//                .accentColor(Color("tab"))
//                .listRowBackground(Color("accent"))
//                .navigationBarTitle("", displayMode: .inline)
//
//                .toolbar{
//                    ToolbarItem(placement: .principal) {
//                            HStack{
//                                KFImage(URL(string: rssSource.imageURL))
//                                    .placeholder({
//                                        Image("Thumbnail")
//                                            .renderingMode(.original)
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                            .frame(width: 20, height: 20,alignment: .center)
//                                            .cornerRadius(2)
//                                            .border(Color.clear, width: 1)
//                                    })
//                                    .renderingMode(.original)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 20, height: 20,alignment: .center)
//                                    .cornerRadius(2)
//                                    .border(Color.clear, width: 1)
//                                Text(rssSource.title)
//                                    .font(.system(size: 20, weight: .medium, design: .rounded))
//
//                                Text("\(rssFeedViewModel.items.count)")
//                                    .font(.caption)
//                                    .fontWeight(.bold)
//                                    .padding(.horizontal, 7)
//                                    .padding(.vertical, 1)
//                                    .background(Color.gray.opacity(0.5))
//                                    .opacity(0.4)
//                                    .foregroundColor(Color("text"))
//                                    .cornerRadius(8)
//                        }
//                    }
//                    ToolbarItem(placement: .bottomBar) {
//                            HStack(spacing: 24){
//                                Button(action: {
////                                    self.viewModel.markAllPostsRead()
//                                }) {
//                                    Image("Symbol")
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                        .foregroundColor(Color("tab"))
//                                }
//                                FilterBar(selectedFilter: .constant(.all),
//                                           showFilter: .constant(true), markedAllPostsRead: nil)
//                                Toggle("", isOn: $unreadOnly)
//                                    .toggleStyle(CheckboxStyle())
//                            }
//                        }
//                    }
//
//                    .sheet(item: $selectedItem, content: { item in
//                        if AppEnvironment.current.useSafari {
//                            SafariView(url: URL(string: item.url)!)
//                        }
//                        else {
//                            WebView(
//                                rssItem: item,
//                                onCloseClosure: {
//                                    self.selectedItem = nil
//                                },
//                                onArchiveAction: {
//                                    self.rssFeedViewModel.archiveOrCancel(item)
//                            })
//                        }
//                    })
//                }
//                .onAppear {
//                    self.rssFeedViewModel.fecthResults()
//            }
//        }
//        func contextmenuAction(_ item: RSSItem) {
//            rssFeedViewModel.archiveOrCancel(item)
//    }
//}

//#if DEBUG
//struct RSSFeedListView_Previews: PreviewProvider {
//    static let rssFeedViewModel = RSSFeedViewModel(rss: RSS(context: Persistence.current.context), dataSource: DataSourceService.current.rssItem)
//    static var previews: some View {
//        Group {
//            NavigationView {
//                RSSFeedListView(viewModel: rssFeedViewModel)
//            }
//            NavigationView {
//                RSSFeedListView(viewModel: rssFeedViewModel)
//            }.environment(\.colorScheme, .dark)
//        }
//    }
//}
//#endif
