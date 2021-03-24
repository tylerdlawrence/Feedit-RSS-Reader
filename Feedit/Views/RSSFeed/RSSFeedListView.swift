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
//import SDWebImageSwiftUI

struct RSSFeedListView: View {
    
    enum FilterType {
        case all, starred, unread
    }

    let filter: FilterType

    var filterTitle: String {
        switch filter {
        case .all:
            return "All"
        case .starred:
            return "Starred"
        case .unread:
            return "Unread"
        }
    }
//    var filteredArticleList: [RSSItem] {
//        switch filter {
//        case .all:
//            return rssFeedViewModel.items
//        case .starred:
//            return rssFeedViewModel.items.filter { item in
//                (!self.rssFeedViewModel.isOn && !item.isArchive)}
//        case .unread:
//            return rssFeedViewModel.items.filter { item in
//                (!self.rssFeedViewModel.unreadIsOn && item.isRead)}
//        }
//    }
    
    var filteredArticles: [RSSItem] {
        return rssFeedViewModel.items.filter({ (item) -> Bool in
            return !((self.rssFeedViewModel.isOn && !item.isArchive) || (self.rssFeedViewModel.unreadIsOn && item.isRead))
        })
    }
            
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @ObservedObject var rssItem: RSSItem
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    @State private var selectedItem: RSSItem?
    @State private var start: Int = 0
    @State private var footer: String = "Refresh"
    @State var cancellables = Set<AnyCancellable>()
    
    init(viewModel: RSSFeedViewModel, rssItem: RSSItem, filter: FilterType) {
        self.rssFeedViewModel = viewModel
        self.rssItem = rssItem
        self.filter = filter
    }
    
    private var refreshButton: some View {
        Button(action: self.rssFeedViewModel.loadMore) {
            Image(systemName: "arrow.clockwise").font(.system(size: 16, weight: .bold)).foregroundColor(Color("tab")).padding()
        }.buttonStyle(BorderlessButtonStyle())
    }
    
    private var thumbnailImage: some View {
        HStack {
            Image(systemName: "person.fill")
                .data(url: URL(string: rssSource.image)!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40, alignment: .center)
        }
    }
    
    
    var body: some View {
        
//        ZStack {
//            Color("accent")
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .edgesIgnoringSafeArea(.all)
        ScrollViewReader { scrollViewProxy in
            List {
                ForEach(filteredArticles) { item in
                    ZStack {
//                        NavigationLink(destination: WebView(rssItem: item, onCloseClosure: {})) {
//                            EmptyView()
//                        }
                        NavigationLink(destination: RSSFeedDetailView(rssItem: item, rssFeedViewModel: self.rssFeedViewModel)) {
                            EmptyView()
                        }
                        .opacity(0.0)
                        .buttonStyle(PlainButtonStyle())
                        HStack {
//                            thumbnailImage
//                            AsyncImage(
//                                url: URL(string: rssSource.image.description)!,
//                                placeholder: {
//                                    ProgressView()
//                                },
//                                image: {
//                                    Image(uiImage: $0)
//
//                                }
//                             )
//                            .frame(width: 40, height: 40, alignment: .center)
                            RSSItemRow(rssItem: item, menu: self.contextmenuAction(_:), rssFeedViewModel: rssFeedViewModel)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    self.selectedItem = item
                                }
                            }
                        }
                    }


            }
            .animation(.default)
            .add(self.searchBar)
            .accentColor(Color("tab"))
            .listRowBackground(Color("accent"))
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: refreshButton)
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
                            })
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20,alignment: .center)
                            .cornerRadius(2)
                        
                        Text(rssSource.title)
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                        
                        Text("\(filteredArticles.count)")
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
                        
                    
                }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    Toggle(isOn: $rssFeedViewModel.isOn) { Text("") }
                        .toggleStyle(StarStyle())
                        
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
}

//#if DEBUG
//struct RSSFeedListView_Previews: PreviewProvider {
//    static let rss = RSS()
//    static let rssItem = RSSItem()
//    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
//    
//    static var group: RSSGroup = {
//      let controller = Persistence.preview
//      return controller.makeRandomFolder(context: controller.context)
//    }()
//    @State static var selection: Set<RSSGroup> = [group]
//
//    static var previews: some View {
//        HomeView(rssItem: rssItem, viewModel: self.viewModel, rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), archiveListViewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
//            .environment(\.managedObjectContext, Persistence.current.context)
//            .environmentObject(Persistence.current)
//                .environment(\.colorScheme, .dark)
//    }
//}
//#endif

extension Image {

    func data(url:URL) -> Self {

        if let data = try? Data(contentsOf: url) {

            return Image(uiImage: UIImage(data: data)!)

                .resizable()

        }

        return self

            .resizable()

    }

}
