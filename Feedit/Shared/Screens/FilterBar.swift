//
//  SmartFilters.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 1/19/21.
//

import SwiftUI
import Combine
import FeedKit
import Foundation

enum FilterType: String, CaseIterable {
    case isArchive = "Starred"
    case unreadIsOn = "Unread"
    case all = "All"
}

struct FilterPicker: View {
    @State var selectedFilter: FilterType = .all
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    
    var body: some View {
        NavigationView {
            Picker("", selection: $selectedFilter, content: {
                ForEach(FilterType.allCases, id: \.self) {
                    Text($0.rawValue)
                }
                SelectedFilterView(selectedFilter: selectedFilter)
            }).pickerStyle(SegmentedPickerStyle()).frame(width: 180, height: 20).listRowBackground(Color("accent"))
        }
    }
}

struct SelectedFilterView: View {
    var selectedFilter: FilterType
    @StateObject var rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    @StateObject var archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    @ObservedObject var articles = AllArticles(dataSource: DataSourceService.current.rssItem)
    @ObservedObject var unread = Unread(dataSource: DataSourceService.current.rssItem)
    @StateObject var viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
    private var allArticlesView: some View {
        let rss = RSS()
        return AllArticlesView(articles: AllArticles(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), selectedFilter: .all)
    }
    private var archiveListView: some View {
        ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: self.rssFeedViewModel, selectedFilter: .isArchive)
    }
    private var unreadListView: some View {
        UnreadListView(unreads: Unread(dataSource: DataSourceService.current.rssItem), selectedFilter: .unreadIsOn)
    }
    
    var filteredFeeds: [RSS] {
        return viewModel.items.filter({ (rss) -> Bool in
            return !((self.viewModel.isOn && !rss.isArchive) || (self.viewModel.unreadIsOn && rss.isRead))
        })
    }
    
    func filterFeeds(url: String?) -> RSS? {
            guard let url = url else { return nil }
        return viewModel.items.first(where: { $0.url.id == url })
        }
    
    var filteredArticles: [RSSItem] {
        return rssFeedViewModel.items.filter({ (item) -> Bool in
            return !((self.rssFeedViewModel.isOn && !item.isArchive) || (self.rssFeedViewModel.unreadIsOn && item.isRead))
        })
    }
    
    let item = RSSItem()
    let rss = RSS()
    
    var body: some View {
        switch selectedFilter {
        case .all:
//            RSSFeedListView(rss: rss, viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), rssItem: item, selectedFilter: .all)
//                .environmentObject(DataSourceService.current.rssItem)
            allArticlesView
            
        case .unreadIsOn:
//            RSSFeedListView(rss: rss, viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), rssItem: item, selectedFilter: .unreadIsOn)
//                .environmentObject(DataSourceService.current.rssItem)
            unreadListView

        case .isArchive:
//            RSSFeedListView(rss: rss, viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), rssItem: item, selectedFilter: .isArchive)
//                .environmentObject(DataSourceService.current.rssItem)
            archiveListView

        }
    }
}

struct FilterPicker_Previews: PreviewProvider {
    static let rss = RSS()
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static var previews: some View {
        FilterPicker(selectedFilter: .unreadIsOn, rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
//            .previewLayout(.fixed(width: 250, height: 70))
                .preferredColorScheme(.dark)
        
    }
}

struct FilterBar: View {
    @Binding var selectedFilter: FilterType
//    @Binding var showFilter: Bool
//    @Binding var isOn: Bool
    var markedAllPostsRead: (() -> Void)?
    
    var body: some View {
        ZStack {
//            Capsule()
            RoundedRectangle(cornerRadius: 25.0)
                .frame(width: 205, height: 35).foregroundColor(Color("text")).opacity(0.1)
            HStack(spacing: 0) {
                Spacer()
                ZStack {
                    if selectedFilter == .isArchive {
                        Capsule()
                            .frame(width: 85, height: 25)
                            .opacity(0.5)
                            .foregroundColor(Color.gray.opacity(0.5))

                    HStack {
                        Image(systemName: "star.fill").font(.system(size: 10, weight: .black))
                        Text(FilterType.isArchive.rawValue)
                            .textCase(.uppercase)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(Color("text"))
                        }
                    } else {
                        Image(systemName: "star.fill").font(.system(size: 10, weight: .black))
                    }
                }
                .padding()
                .onTapGesture {
                    self.selectedFilter = .isArchive
                }
                Divider()
        
                ZStack {
                    if selectedFilter == .unreadIsOn {
                        Capsule()
                            .frame(width: 85, height: 25)
                            .opacity(0.5)
                            .foregroundColor(Color.gray.opacity(0.5))
                    HStack {
                        Image(systemName: "circle.fill").font(.system(size: 10, weight: .black))
                        Text(FilterType.unreadIsOn.rawValue)
                            .textCase(.uppercase)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(Color("text"))
                        }
                    } else {
                        Image(systemName: "circle.fill").font(.system(size: 10, weight: .black)).padding()
                    }
                }//.padding()
                .onTapGesture {
                    self.selectedFilter = .unreadIsOn
                }
                Divider()
                
                ZStack {
                    if selectedFilter == .all {
                        Capsule()
                            .frame(width: 65, height: 25)
                            .opacity(0.5)
                            .foregroundColor(Color.gray.opacity(0.5))


                    HStack{
                        Image(systemName: "text.justifyleft").font(.system(size: 10, weight: .black))
                        Text(FilterType.all.rawValue)
                            .textCase(.uppercase)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(Color("text"))
                        }
                    } else {
                        Image(systemName: "text.justifyleft").font(.system(size: 10, weight: .black))
                        }
                    }.padding()
                    .onTapGesture {
                        self.selectedFilter = .all
                    }
                    Spacer()
            }
            .frame(width: 125, height: 20)
        }
    }
}

//struct FilterBar_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack{
//            Spacer()
//            FilterBar(selectedFilter: .constant(.unreadIsOn),
//                   isOn: .constant(true), markedAllPostsRead: nil)
//                .preferredColorScheme(.dark)
//        }
//    }
//}