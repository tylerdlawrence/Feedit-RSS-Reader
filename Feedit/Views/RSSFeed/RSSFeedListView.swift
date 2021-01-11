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
import SwiftUIX
import ASCollectionView
import NavigationStack
import SwipeCell
import SwiftUIGestures
import FeedKit
import KingfisherSwiftUI
import SwiftUIRefresh
import SwipeCellKit

struct RSSFeedListView: View {
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @State private var selectedItem: RSSItem?
    @State private var isSafariViewPresented = false
    @State private var start: Int = 0
    @State var cancellables = Set<AnyCancellable>()
    
    @ObservedObject var searchBar: SearchBar = SearchBar()
    @State var searchText: String = ""
    @State var isRefreshing: Bool = false
    @State private var isShowing = false
    let refreshControl: RefreshControl = RefreshControl()

    @State var viewState = CGSize.zero
    @State var scrollView: UIScrollView?
    @State private var sort: Int = 0


    var feed = [""]
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }

    init(rssViewModel: RSSFeedViewModel) {
//        self.dataSource = dataSource
//        self.rss = rss
        self.rssFeedViewModel = rssViewModel
        self.model = GroupModel(icon: "text.justifyleft", title: "")
    }
    
    enum FeatureItem {
        case goBack
        case goForward
        case archive(Bool)
        case read(Bool)
        
        var icon: String {
            switch self {
            case .goBack: return "chevron.backward"
            case .goForward: return "chevron.forward"
            case .archive(let isArchived):
                return "star\(isArchived ? ".fill" : "")"
            case .read(let isRead):
                return "circle\(isRead ? ".fill" : "")"
            }
        }
    }
    
    @State private var showingInfo = false
    private var infoListView: some View {
        Button(action: {
            self.showingInfo = true
            }) {
            Image(systemName: "info.circle")
            }.sheet(isPresented: $showingInfo) {
                InfoView(rssViewModel: rssFeedViewModel)
        }
    }
    
    @State private var fontColor = Color.gray
    private var markAllRead: some View {
        Button(action: {
            self.fontColor = Color.gray
              .opacity(0.8)
        }) {
            Image("MarkAllAsRead")
        }
    }
    
    private var trailingButtons: some View {
        HStack(alignment: .top, spacing: 24) {
            infoListView
            markAllRead
        }
    }
    
    private var reloadButton: some View {
        Button(action: self.rssFeedViewModel.loadMore) {
            Image(systemName: "arrow.counterclockwise")
                .imageScale(.small)
                .frame(width: 44, height: 44)
        }
    }
    
    @State var isDragging = false
    var drag: some Gesture {
        DragGesture()
            .onChanged { _ in self.isDragging = true }
            .onEnded { _ in self.isDragging = false }
    }
    
    var model: GroupModel
//    let dataSource: RSSItemDataSource
//    let rss: RSS

//    let width : CGFloat = 60
//    @State var offset = CGSize.zero
//    @State var offsetY : CGFloat = 0
//    @State var scale : CGFloat = 0.5
    
    func footerView() -> some View {
        VStack(alignment: .leading) {
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
    
    
    var body: some View {
        ZStack{
//        NavigationStackView(transitionType: .custom(.scale), easing: .spring(response: 0.5, dampingFraction: 0.25, blendDuration: 0.5)) {
        ScrollView {
            //List(rssFeedViewModel.items, id: \.id) { item in
            LazyVStack(alignment: .leading) {
                ForEach(rssFeedViewModel.items, id: \.self) { item in
                    NavigationLink(destination: WebView(rssViewModel: rssFeedViewModel, wrapper: item, rss: rssSource, rssItem: item, url: URL(string: item.url)!)) {
                        RSSItemRow(rssViewModel: rssFeedViewModel, wrapper: item, menu: self.contextmenuAction(_:))
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            self.selectedItem = item
//                        }
                        .multilineTextAlignment(.leading)
//                    KFImage(URL(string: rssSource.image))
//                        .placeholder({
//                            ProgressView()
//                        })
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 90, height: 90)
//                        .clipped()
//                        .cornerRadius(12)
                        }
                    }
                    .padding([.top, .bottom, .trailing])
                }
                .frame(width: 350)
                .border(Color.clear, width: 1)
        //        .cornerRadius(10)
        //        .padding(10)
            }
            .id(UUID())
            .listStyle(PlainListStyle())
            .navigationBarTitle(rssSource.title, displayMode: .inline)
            //.navigationBarItems(trailing: reloadButton)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(alignment: .center){
                        HStack(alignment: .center){
                            KFImage(URL(string: rssSource.imageURL))
                                .placeholder({
                            Image(systemName: model.icon)
                                .imageScale(.medium)
                                .font(.system(size: 16, weight: .heavy))
                                .layoutPriority(10)
                                .foregroundColor(.white)
                                .background(
                                    Rectangle().fill(model.color)
                                        .opacity(0.6)
                                        .frame(width: 25, height: 25,alignment: .center)
                                        .cornerRadius(5)
                                )})
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25,alignment: .center)
                                .cornerRadius(2)
                                .border(Color.clear, width: 1)
                            Text(rssSource.title)
                                .font(.system(.body))
                                .fontWeight(.bold)
                            footerView()
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Menu {
                        Picker(selection: $sort, label: Text("Smart Filters")) {
                            HStack{
                                Text("All").tag(0)
                                Image(systemName: "text.justifyleft")
                            }
                            HStack{
                                Text("Starred").tag(1)
                                Image(systemName: "star.fill")
                            }
                            HStack{
                                Text("Unread").tag(2)
                                Image(systemName: "circle")
                            }
                        }
                        Button(action: self.rssFeedViewModel.loadMore) {
                            Text("Refresh Articles")
                            Image(systemName: "arrow.counterclockwise")
                                .imageScale(.small)
                                .frame(width: 44, height: 44)
                        }
                    }
                    label: {
                        Label("Sort", systemImage: "line.horizontal.3.decrease.circle").font(.system(size: 20, weight: .light))
                        }
                    }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    markAllRead
                        .frame(width: 44, height: 44)
                }
                ToolbarItem(placement: .bottomBar) {
                    //infoListView
                }
            }
        }
        //.add(self.searchBar)

//            .sheet(item: $selectedItem, content: { item in
//                if AppEnvironment.current.useSafari {
//                    SafariView(url: URL(string: item.url)!)
//                } else {
//                    WebView(
//                        rssItem: item,
//                        onArchiveAction: {
//                            self.rssFeedViewModel.archiveOrCancel(item)
//                    })
//                }
//            })
                .onAppear {
                    self.rssFeedViewModel.fecthResults()
                    self.rssFeedViewModel.fetchRemoteRSSItems()
            }
        }
        func contextmenuAction(_ item: RSSItem) {
            rssFeedViewModel.archiveOrCancel(item)
    }
}

