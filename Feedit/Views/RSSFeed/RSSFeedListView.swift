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

    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @Environment(\.colorScheme) var colorScheme

    @State private var selectedItem: RSSItem?
    @State private var isSafariViewPresented = false
    @State private var start: Int = 0
    @State private var footer: String = "Refresh more articles"
    @State var cancellables = Set<AnyCancellable>()
    
    init(viewModel: RSSFeedViewModel) {
        self.rssFeedViewModel = viewModel
    }
    private var archiveListView: some View {
        Button(action: {
            print ("Tags")
        }) {
            Image(systemName: "arrow.counterclockwise")
                .imageScale(.medium)
        }
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
            Image(systemName: "checkmark")
                .imageScale(.medium)
        }
    }
    private var trailingFeedView: some View {
        HStack(alignment: .top, spacing: 24) {
            archiveListView
            markAllRead
            infoListView
        }
    }
    var body: some View {
        VStack(alignment: .leading){
                Text(rssSource.title)
                    .font(.title2)
                    .fontWeight(.heavy)
            Text("Today at ").font(.system(.headline)) +
                Text(Date(), style: .time)
                .fontWeight(.bold)
            
//            HStack{
//                Text("Added")
//                    .font(.footnote)
//                    .fontWeight(.heavy)
//                Text(rssSource.createTimeStr)
//                    .font(.footnote)
//                    .fontWeight(.heavy)
//            }
//            Text(rssSource.desc)
//                    .font(.footnote)
        }
        .frame(width: 325.0, height: 80)

        VStack{
            List {
                ForEach(self.rssFeedViewModel.items, id: \.self) { item in
                    RSSItemRow(wrapper: item,
                               menu: self.contextmenuAction(_:))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.selectedItem = item
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
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: trailingFeedView)
        .sheet(item: $selectedItem, content: { item in
            if AppEnvironment.current.useSafari {
                SafariView(url: URL(string: item.url)!)
            } else {
                WebView(
                    wrapper: item, rss: RSS.simple(), rssItem: item,
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
    func contextmenuAction(_ item: RSSItem) {
        rssFeedViewModel.archiveOrCancel(item)
    }
}

extension RSSFeedListView {
    private func destinationView(_ rss: RSS) -> some View {
        RSSFeedListView(viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
            .environmentObject(DataSourceService.current.rss)
    }
}
