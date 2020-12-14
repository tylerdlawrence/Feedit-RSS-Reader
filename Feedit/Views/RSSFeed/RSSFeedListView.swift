//
//  RSSItemListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import FeedKit
import Combine

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
    
    //@Environment(\.colorScheme) var colorScheme
    @State private var selectedItem: RSSItem?
    @State private var isSafariViewPresented = false
    @State private var start: Int = 0
    @State private var footer: String = "Refresh more articles"
    @State var cancellables = Set<AnyCancellable>()
    var onDoneAction: (() -> Void)?

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
        ZStack {
            VStack {
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
                
//                ForEach(rssFeedViewModel.items, id: \.self) { item in
//                    NavigationLink(destination: WebView(rssViewModel: rssFeedViewModel, wrapper: item,
//                            rss: RSS.simple(), rssItem: item)) {
//                        RSSItemRow(rssViewModel: rssFeedViewModel, wrapper: item)
//                            .contentShape(Rectangle())
//                            .onTapGesture {
//                                self.selectedItem = item
//                                self.isPresented.toggle()
//                        }
//                    }
//                }
                ForEach(self.rssFeedViewModel.items, id: \.self) { item in
                  RSSItemRow(rssViewModel: rssFeedViewModel, wrapper: item,
                      menu: self.contextmenuAction(_:))
                          .contentShape(Rectangle())
                          .onTapGesture {
                            self.selectedItem = item
                            self.isPresented.toggle()
                        }
                    }
                VStack(alignment: .center) {
                    Button(action: self.rssFeedViewModel.loadMore) {
                        HStack{
                            Text("↺")
                            Text(self.footer)
                                .font(.title3)
                                .fontWeight(.bold)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationBarTitle("", displayMode: .inline)
            }.onAppear {
                self.rssFeedViewModel.fecthResults()
                self.rssFeedViewModel.fetchRemoteRSSItems()
        }
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
        }
    }
    
    func contextmenuAction(_ item: RSSItem) {
        rssFeedViewModel.archiveOrCancel(item)
    }
}
