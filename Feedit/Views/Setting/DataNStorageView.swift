//
//  DataNStorageView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/15/20.
//

import SwiftUI
import Introspect
import Combine
import CoreData

struct DataNStorageView: View {
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    
    @State private var selectedItem: RSSItem?
    @State private var start: Int = 0
    @State private var footer: String = "Refresh"
    @State var isRead = false
    @State var starOnly = false
    
    @ObservedObject var dataViewModel: DataNStorageViewModel
    @ObservedObject var viewModel: RSSListViewModel
    @State private var revealFeedsDisclosureGroup = true
    
    init(rssFeedViewModel: RSSFeedViewModel, viewModel: RSSListViewModel, isRead: Bool) {
        let db = DataSourceService.current
        dataViewModel = DataNStorageViewModel(rss: db.rss, rssItem: db.rssItem)
        self.rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem, isRead: isRead)
        self.viewModel = viewModel
        self.isRead = isRead
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Archive").font(.system(size: 28, weight: .medium, design: .rounded)).padding()
                    HStack(spacing: 12) {
                        DataUnitView(label: "Feeds", content: self.$dataViewModel.rssCount, colorType: .blue)
                        DataUnitView(label: "Article Count", content: self.$dataViewModel.rssItemCount, colorType: .orange)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                    }
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                    .frame(height: 120)
                Spacer()
                }
                .padding([.top, .horizontal])
                .offset(x: geo.frame(in: .global).minX / 5)
            }
            .introspectScrollView { scrollView in
                scrollView.refreshControl = UIRefreshControl()
            }
            .onAppear {
                self.dataViewModel.getRSSCount()
                self.dataViewModel.getRSSItemCount()
            }
        }
    }
}

//struct DataNStorageView_Previews: PreviewProvider {
//    static let rss = RSS()
//    static let rssFeedViewModel = RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem)
//
//    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
//
//    static var previews: some View {
//        DataNStorageView(rssFeedViewModel: self.rssFeedViewModel, viewModel: self.viewModel)
//            .preferredColorScheme(.dark)
//    }
//}

