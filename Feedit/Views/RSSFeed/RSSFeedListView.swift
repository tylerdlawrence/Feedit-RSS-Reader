//
//  RSSItemListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import UIKit
import NavigationStack
import SwipeCell
import SwiftUIGestures
import FeedKit
import Combine
import KingfisherSwiftUI
import SwiftUIRefresh
import SwipeCellKit

struct RSSFeedListView: View {
    
    enum DragState {
        case inactive
        case pressing
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
        
        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .pressing, .dragging:
                return true
            }
        }
        
        var isDragging: Bool {
            switch self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
            }
        }
    }
    
    @GestureState var dragState = DragState.inactive
    @State var viewState = CGSize.zero
    
    var feed = [""]
    @State var searchText: String = ""
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    @ObservedObject var searchBar: SearchBar = SearchBar()
//    @State private var offset = CGSize.zero

    let refreshControl: RefreshControl = RefreshControl()
    @State var scrollView: UIScrollView?

    @EnvironmentObject var rssDataSource: RSSDataSource
    
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel

    @State var isRefreshing: Bool = false
    @State private var isShowing = false

    @State private var selectedItem: RSSItem?
    @State private var isSafariViewPresented = false
    @State private var start: Int = 0
    @State var cancellables = Set<AnyCancellable>()
    
    init(rssViewModel: RSSFeedViewModel) {
        self.rssFeedViewModel = rssViewModel
    }
    
    private var infoListView: some View {
        Button(action: {
            print ("feed info")
        }) {
            Image(systemName: "info.circle")
        }
    }
    
    private var markAllRead: some View {
        Button(action: {
            print ("Mark all as Read")
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
    
    func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.isRefreshing = false
        }
    }
    
    @State var isDragging = false
    var drag: some Gesture {
        DragGesture()
            .onChanged { _ in self.isDragging = true }
            .onEnded { _ in self.isDragging = false }
    }
    
//    let text : String
//    let index : Int
    let width : CGFloat = 60
//    @Binding var indices : [Int]
    @State var offset = CGSize.zero
    @State var offsetY : CGFloat = 0
    @State var scale : CGFloat = 0.5
    
    var body: some View {
//        ZStack{
        NavigationStackView(transitionType: .custom(.scale), easing: .spring(response: 0.5, dampingFraction: 0.25, blendDuration: 0.5)) {
            List(rssFeedViewModel.items, id: \.id) { item in
                NavigationLink(destination: WebView(rssViewModel: rssFeedViewModel, wrapper: item, rss: rssSource, rssItem: item, url: URL(string: item.url)!)) {
                        RSSItemRow(rssViewModel: rssFeedViewModel, wrapper: item, menu: self.contextmenuAction(_:))
                            //.frame(width : geo.size.width, alignment: .leading)
                }
            }
                        
            .listStyle(PlainListStyle())
            .navigationBarTitle(rssSource.title, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack{
                        Text(rssSource.title)
                            .font(.system(.footnote))
                            .fontWeight(.bold)

                        Text("Today at ")
                            .fontWeight(.bold)
                            .font(.system(.footnote)) +
                            Text(Date(), style: .time)
                            .font(.system(.footnote))
                            .fontWeight(.bold)
                    }
                    .padding(.vertical)
                }
            }
            .add(self.searchBar)
            .pullToRefresh(isShowing: $isShowing) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isShowing = false
                }
            }
            .navigationBarItems(trailing:
                Button(action: self.rssFeedViewModel.loadMore) {
                    Image(systemName: "arrow.counterclockwise")
                })
            }
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
                        self.isRefreshing = true
                        self.refresh()
                }
            }
            func contextmenuAction(_ item: RSSItem) {
                rssFeedViewModel.archiveOrCancel(item)
                //rssFeedViewModel.isDone(item)
        
    }
}
