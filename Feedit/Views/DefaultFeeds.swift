//
//  DefaultFeeds.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 12/5/20.
//

import Foundation
import SwiftUI
import Combine
import FeedKit

struct DefaultFeeds: Codable, Identifiable {
    let id: String
    let desc: String
    let htmlUrl: String
    let xmlUrl: String
}

struct DefaultFeedsListView: View {
    
    let defaultFeeds: [DefaultFeeds] = Bundle.main.decode("DefaultFeeds.json")
    
//    func onDoneAction() {
//        self.viewModel.fecthResults()
//    }
    
    private func defaultFeeds(_ rss: RSS) -> some View {
        RSSFeedListView(viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
            .environmentObject(DataSourceService.current.rss)
    }

    func deleteItems(at offsets: IndexSet) {
        viewModel.items.remove(atOffsets: offsets)
    }
    @State var sources: [RSS] = []

    @ObservedObject var viewModel: RSSListViewModel
    
    var body: some View {
                    ForEach(viewModel.items, id: \.self) { rss in
                        NavigationLink(destination: self.defaultFeeds(rss)) {
                            RSSRow(rss: rss)
            
//            ForEach(viewModel.items, id: \.self) { rss in
//                NavigationLink(destination: self.defaultFeeds(rss)) {
//                    RSSRow(rss: rss)
//                }
//                .tag("RSS")
//            }
//            .onDelete { indexSet in
//                if let index = indexSet.first {
//                    self.viewModel.delete(at: index)
//                }
//            }
        }
            
    }
}
//"title": "The Shape of Everything",
//"desc": "",
//"htmlUrl": "",
//"xmlUrl": "https://shapeof.com/feed.json"

//ForEach(viewModel.items, id: \.self) { rss in
//    NavigationLink(destination: self.destinationView(rss)) {
//        RSSRow(rss: rss)
//    }
//    .tag("RSS")
//}
//.onDelete { indexSet in
//    if let index = indexSet.first {
//        self.viewModel.delete(at: index)
//        }
//    }
}
