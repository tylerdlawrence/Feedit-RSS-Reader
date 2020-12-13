//
//  RSSItemListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import FeedKit
import Combine
import KingfisherSwiftUI

struct RSSFeedListView: View {
    
//    @Environment(\.managedObjectContext) var managedObjectContext
//
//    @Environment(\.presentationMode) var presentationMode
    
    @State private var isPresented = false

    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @Environment(\.colorScheme) var colorScheme
    var onDoneAction: (() -> Void)?
    @State private var selectedItem: RSSItem?
    @State private var isSafariViewPresented = false
    @State private var start: Int = 0
    @State private var footer: String = "Refresh more articles"
    @State var cancellables = Set<AnyCancellable>()
    
    init(rssViewModel: RSSFeedViewModel) {
        self.rssFeedViewModel = rssViewModel
    }
    

    
    private var infoListView: some View {
        Button(action: {
            print ("Tags")
        }) {
            Image(systemName: "info.circle")
                .imageScale(.medium)
        }
    }
    private var markAllRead: some View {
        Button(action: {
            print ("Mark all as Read")
        }) {
            Image("MarkAllAsRead")
                //.imageScale(.medium)
        }
    }
    
    private var trailingFeedView: some View {
        HStack(alignment: .top, spacing: 24) {
            //infoListView
            markAllRead
        }
    }
    
    var body: some View {
        
        ZStack { //(alignment: .leading){
            //ScrollView{
            //HStack(alignment: .center){
//            KFImage(URL(string: self.rssSource.imageURL))
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 50, height: 50)
//                .cornerRadius(5.0)
               // VStack(alignment: .leading){
//                    Text(rssSource.title)
//                        .font(.title2)
//                        .fontWeight(.heavy)
//                    Text("Today at ").font(.system(.headline)) +
//                        Text(Date(), style: .time)
//                        .fontWeight(.bold)
                //Divider()

                //}
            //}
        //}
        //.frame(width: 325.0, height: 80)

        VStack{
            List {
                VStack(alignment: .leading){
                    Text(rssSource.title)
                        .font(.title2)
                        .fontWeight(.heavy)
                    Text("Today at ").font(.system(.headline)) +
                        Text(Date(), style: .time)
                        .fontWeight(.bold)
                }
                .padding(.leading)
                    ForEach(self.rssFeedViewModel.items, id: \.self) { item in
                        RSSItemRow(rssViewModel: rssFeedViewModel, wrapper: item,
                                   menu: self.contextmenuAction(_:))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.selectedItem = item
                                self.isPresented.toggle()
                        //}
                    }
                }
                VStack(alignment: .center) {
                    Button(action: self.rssFeedViewModel.loadMore) {
                        HStack{
                            Text("↺")
                            Text(self.footer)
                                .font(.title2)
                                .fontWeight(.bold)
                            }
                        }
                    }
            }
            .listStyle(PlainListStyle())
            }
//        .navigationBarTitle(Text(rssSource.title) + Text(" Today at ") + Text(Date(), style: .time))
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarTitle("dummy header").navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)
        //.navigationBarItems(trailing: trailingFeedView)
        //.fullScreenCover
        .sheet(item: $selectedItem, content: { item in
            if AppEnvironment.current.useSafari {
                SafariView(url: URL(string: item.url)!)
            } else {
                WebView(
                    rssViewModel: rssFeedViewModel, wrapper: item, rss: RSS.simple(), rssItem: item,
                    onArchiveAction: {
                        self.rssFeedViewModel.archiveOrCancel(item)
                    })
                }
            })
        
        .onAppear {
            self.rssFeedViewModel.fecthResults()
            self.rssFeedViewModel.fetchRemoteRSSItems()
            }
        }
    }
    func contextmenuAction(_ item: RSSItem) {
        rssFeedViewModel.archiveOrCancel(item)
    }
}

extension RSSFeedListView {
    private func destinationView(_ rss: RSS) -> some View {
        RSSFeedListView(rssViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
            .environmentObject(DataSourceService.current.rss)
    }
}
