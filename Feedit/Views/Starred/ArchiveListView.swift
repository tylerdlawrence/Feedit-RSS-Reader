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
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var archiveListViewModel: ArchiveListViewModel


    @State private var selectedItem: RSSItem?
    @State var footer = "Load More Articles"
    
    init(viewModel: ArchiveListViewModel, rssFeedViewModel: RSSFeedViewModel) {
        self.archiveListViewModel = viewModel
        self.rssFeedViewModel = rssFeedViewModel
    }
    
    @State private var isLoading = false
    var animation: Animation {
        Animation.linear
    }
    private var loadMore: some View {
        VStack(alignment: .center) {
            HStack {
                Button(action: self.archiveListViewModel.loadMore) {
                    //self.isLoading.toggle()
//                    self.archiveListViewModel.loadMore()
//                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .rotationEffect(.degrees(isLoading ? 360 : 0))
                        .animation(animation)
                        .onAppear() {
                            self.isLoading.toggle()
                        }
                        
                }//.buttonStyle(LoadingButtonStyle())
            }
        }
    }
    struct LoadingButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color("bg"))
                .multilineTextAlignment(.center)
                .frame(width: 44, height: 44)
                .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
        }
    }
    
    private var trailingView: some View {
        HStack(alignment: .top, spacing: 24) {
            loadMore
        }
    }
    
    private var markAllRead: some View {
        Button(action: {
            print ("Mark all as Read")
        }) {
            Image("MarkAllAsRead")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color("bg"))
                .frame(width: 44, height: 44)


        }
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(self.archiveListViewModel.items, id: \.self) { item in
                    NavigationLink(destination: WebView(rssViewModel: rssFeedViewModel, wrapper: item, rss: rssSource, rssItem: item, url: URL(string: item.url)!)) {
                        RSSItemRow(withURL: "https://macstories.net/feed/", rssViewModel: rssFeedViewModel, wrapper: item)
                        //https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTtDx_WhOP_7JS1s0-iOdb2agehqkGRCnMAg&usqp=CAU
                    }
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        let item = self.archiveListViewModel.items[index]
                        self.archiveListViewModel.unarchive(item)
                    }
                }
                VStack(alignment: .center, spacing: 0.0) {
                    EmptyView()
                        .padding(.bottom)
//                        Button(action: self.archiveListViewModel.loadMore) {
//                            loadMore
//                        }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(alignment: .center) {
                        //loadMore
                        markAllRead
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack{
                        HStack{
                            Image(systemName: "star.fill")
                                .imageScale(.small)
                                .foregroundColor(Color("bg"))
                            Text("Starred")
                                .font(.system(.body))
                                .fontWeight(.bold)
                            Text("\(archiveListViewModel.items.count)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 1)
                                .background(Color("darkShadow"))
                                .foregroundColor(Color("text"))
                                .cornerRadius(8)
                        }
                        HStack {
                            Text("Last Sync ")
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .font(.system(.footnote)) +
                                Text(Date(), style: .time)
                                .font(.system(.footnote))
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
//                .sheet(item: $selectedItem, content: { item in
//                    SafariView(url: URL(string: item.url)!)
//                })
            .onAppear {
                self.archiveListViewModel.fecthResults()
        }
    }
    .navigationBarTitle("", displayMode: .inline)
    }
}

extension ArchiveListView {

}

struct ArchiveListView_Previews: PreviewProvider {
    
    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    static let rssFeedViewModel = RSSFeedViewModel(rss: RSS(context: Persistence.current.context), dataSource: DataSourceService.current.rssItem)
    static let rssListViewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

    static var previews: some View {
        ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: self.rssFeedViewModel)
    }
}

