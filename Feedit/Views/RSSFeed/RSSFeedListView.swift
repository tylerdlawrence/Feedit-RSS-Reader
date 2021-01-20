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
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    @ObservedObject var imageLoader:ImageLoader
    @State var image:UIImage = UIImage()
    @State private var useReadText = false

    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @State private var selectedItem: RSSItem?
    @State private var isSafariViewPresented = false
    @State private var start: Int = 0
    @State var cancellables = Set<AnyCancellable>()
    
    @State var isRefreshing: Bool = false
    @State private var isShowing = false

    @State var viewState = CGSize.zero
    @State var scrollView: UIScrollView?
    @State private var sort: Int = 0
    
//    @Binding var selectedFilter: FilterType
//    @Binding var showFilter: Bool
    var markedAllPostsRead: (() -> Void)?

    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }

    init(withURL url:String, rssViewModel: RSSFeedViewModel) {
        imageLoader = ImageLoader(urlString:url)
        self.rssFeedViewModel = rssViewModel
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
    
//    @State private var showingInfo = false
//    private var infoListView: some View {
//        Button(action: {
//            self.showingInfo = true
//            }) {
//            Image(systemName: "info.circle")
//            }.sheet(isPresented: $showingInfo) {
//               InfoView(rssViewModel: rssFeedViewModel)
//        }
//    }
    
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
//            infoListView
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
    
    private var lastSync: some View {
        HStack {
            Text("Last Sync ")
                .fontWeight(.bold)
                .foregroundColor(Color("lightShadow"))
                .font(.system(.footnote)) +
                Text(Date(), style: .time)
                .font(.system(.footnote))
                .fontWeight(.bold)
                .foregroundColor(Color("lightShadow"))
        }
    }
    
    func footerView() -> some View {
        VStack(alignment: .center){
            HStack(alignment: .center){
                KFImage(URL(string: rssSource.imageURL))
                    .placeholder({
                        Image("default-icon")
                            .renderingMode(.original)
                           .resizable()
                           .aspectRatio(contentMode: .fit)
                           .frame(width: 25, height: 25,alignment: .center)
                           .cornerRadius(5)
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25,alignment: .center)
                    .cornerRadius(5)
                    .border(Color.clear, width: 0)
                Text(rssSource.title)
                    .font(.system(.body))
                    .fontWeight(.bold)
                Spacer()
////                Text("\(rss.posts.filter { !$0.isRead }.count) unread posts")
////                Text("\(rssFeedViewModel.items.filter { !$0.isRead }.count)")
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
    
    
    @State private var isRead = false
    
    var body: some View {
        


        
        ZStack{
//        NavigationStackView(transitionType: .custom(.scale), easing: .spring(response: 0.5, dampingFraction: 0.25, blendDuration: 0.5)) {
        ScrollViewReader { scrollProxy in
            ScrollView(.vertical, showsIndicators: true) {
//            List(rssFeedViewModel.items, id: \.id) { item in
                LazyVStack(alignment: .leading, spacing: 0) {
                    Divider().padding(0).padding([.leading])
                        ForEach(rssFeedViewModel.items, id: \.self) { item in
                                NavigationLink(destination: WebView(rssViewModel: rssFeedViewModel, wrapper: item, rss: rssSource, rssItem: item, url: URL(string: item.url)!)) {
                                        RSSItemRow(withURL: "", rssViewModel: rssFeedViewModel, wrapper: item, menu: self.contextmenuAction(_:))
                                            .onTapGesture {
                                                self.selectedItem = item
                                        }
                                            .multilineTextAlignment(.leading)
//                                    VStack{
//                                        Image(uiImage: image)
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                            .frame(width:70, height:70)
//                                            .onReceive(imageLoader.dataPublisher) { data in
//                                                self.image = UIImage(data: data) ?? UIImage()
//                                            }
//                                        }
                                    }
                                }
                        .padding(.all)
                    }
                    .frame(width: 360)
                    .border(Color.clear, width: 0)
            }
            .id(UUID())
            .navigationBarTitle("", displayMode: .inline)
            .add(self.searchBar)
//            .listStyle(PlainListStyle())
//            .navigationBarItems(trailing: reloadButton)
            .toolbar {
                ToolbarItem(placement: .principal) {
                footerView()
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
                        Button(action: {
                            self.useReadText.toggle()
                        }) {
                            Text("Mark All Articles As Read")
                            Image("MarkAllAsRead")
                                .frame(width: 40, height: 40)
                        }
                    }
                    label: {
                        Label("Sort", systemImage: "line.horizontal.3.decrease.circle").font(.system(size: 22, weight: .light))
                        }
                    }
//                ToolbarItem(placement: .bottomBar) {
//                    Spacer()
//                }
                ToolbarItem(placement: .status) {
                    lastSync
                }
//                ToolbarItem(placement: .bottomBar) {
//                    markAllRead
//                        .frame(width: 40, height: 40)
//                }
            }
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
        }
                .onAppear {
                    self.rssFeedViewModel.fecthResults()
                    self.rssFeedViewModel.fetchRemoteRSSItems()
            }
        }
        func contextmenuAction(_ item: RSSItem) {
            rssFeedViewModel.archiveOrCancel(item)
            rssFeedViewModel.readOrCancel(item)
            
            
    }
}

struct PostList: View {

    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    @ObservedObject var imageLoader:ImageLoader
    @State var image:UIImage = UIImage()
    @State private var useReadText = false

    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @State private var selectedItem: RSSItem?
    @State private var isSafariViewPresented = false
//    @State private var start: Int = 0
    @State var cancellables = Set<AnyCancellable>()
    
    @State var isRefreshing: Bool = false
    @State private var isShowing = false

    @State var viewState = CGSize.zero
    @State var scrollView: UIScrollView?
    @State private var sort: Int = 0
    
    let dataSource: RSSItemDataSource
    let rss: RSS
    var start = 0

    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }

    init(withURL url:String, rssViewModel: RSSFeedViewModel, rss: RSS, dataSource: RSSItemDataSource) {
        imageLoader = ImageLoader(urlString:url)
        self.rssFeedViewModel = rssViewModel
        self.dataSource = dataSource
        self.rss = rss
    }

    var body: some View {
        ForEach(rssFeedViewModel.items, id: \.self) { item in
                NavigationLink(destination: WebView(rssViewModel: rssFeedViewModel, wrapper: item, rss: rssSource, rssItem: item, url: URL(string: item.url)!)) {
                        RSSItemRow(withURL: "", rssViewModel: rssFeedViewModel, wrapper: item)
                }
        }
    }
}
#if DEBUG
struct PostList_Previews: PreviewProvider {
    static let rssFeedViewModel = RSSFeedViewModel(rss: RSS(context: Persistence.current.context), dataSource: DataSourceService.current.rssItem)
    static let current = DataSourceService()
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

    static var previews: some View {
        Group {
            
//            NavigationView {
//                PostList(viewModel: RSSListViewModel(rss: RSS.testObject))
//            }
            
            NavigationView {
                PostList(withURL: "", rssViewModel: rssFeedViewModel, rss: RSS(), dataSource: DataSourceService.current.rssItem)
            }.environment(\.colorScheme, .dark)
        }
    }
}
#endif
struct PostCell: View {
//    @ObservedObject var post: Post
//    @ObservedObject var viewModel: RSSFeedViewModel

    @EnvironmentObject var rssDataSource: RSSDataSource
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    @ObservedObject var imageLoader:ImageLoader
    @State var image:UIImage = UIImage()
    @State private var useReadText = false

    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @State private var selectedItem: RSSItem?
    @State private var isSafariViewPresented = false
    @State private var start: Int = 0
    @State var cancellables = Set<AnyCancellable>()
    
    @State var isRefreshing: Bool = false
    @State private var isShowing = false

    @State var viewState = CGSize.zero
    @State var scrollView: UIScrollView?
    @State private var sort: Int = 0

    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }

    init(withURL url:String, rssViewModel: RSSFeedViewModel) {
        imageLoader = ImageLoader(urlString:url)
        self.rssFeedViewModel = rssViewModel
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(rssSource.title)
                .font(.headline)
                .foregroundColor(Color(.label))
            Text(rssSource.desc)
                .font(.subheadline)
                .foregroundColor(Color(.label))
            
            HStack {
//                Text(formatDate(with: rssSource.date))
//                    .frame(height: 15)
//                    .font(.footnote)
//                    .padding(.all, 8)
//                    .foregroundColor(.white)
//                    .background(Color.red)
//                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Image(systemName: "circle")
                    .frame(height: 15)
                    .foregroundColor(.white)
                    .padding(.all, 8)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .opacity(rssSource.isRead ? 1 : 0)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 100)
        .padding(.trailing)
        .background(Color.backgroundNeo)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    func formatDate(with date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today at " + date.toString(format: "HH:mm a")
        } else {
            return date.toString(format: "dd/MM/yyyy")
        }
    }
}
