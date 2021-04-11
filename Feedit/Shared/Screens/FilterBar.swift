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
    @StateObject var articles = AllArticles(dataSource: DataSourceService.current.rssItem)
    @StateObject var unread = Unread(dataSource: DataSourceService.current.rssItem)
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
//            if selectedFilter == .all {
                HStack {
                    ZStack{
                        NavigationLink(destination: allArticlesView) {
                            EmptyView()
                        }
                        .opacity(0.0)
                        .buttonStyle(PlainButtonStyle())
                    HStack{
                        Image(systemName: "chart.bar.doc.horizontal")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 21, height: 21,alignment: .center)
//                            .foregroundColor(Color.red.opacity(0.8))
                            .foregroundColor(Color("tab").opacity(0.9))
                        Text("All Articles")
                        Spacer()
                        Text("\(articles.items.count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 1)
                            .background(Color.gray.opacity(0.5))
                            .opacity(0.4)
                            .cornerRadius(8)

                        }.accentColor(Color("tab").opacity(0.9))
                    }
                    .onAppear {
                        self.articles.fecthResults()
                    }
                }//.listRowBackground(Color("accent"))
//            }
//            allArticlesView
        
            HStack {
                ZStack{
                    NavigationLink(destination: unreadListView) {
                        EmptyView()
                    }
                    .opacity(0.0)
                    .buttonStyle(PlainButtonStyle())
                HStack{
                    Image(systemName: "largecircle.fill.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 21, height: 21,alignment: .center)
                        .foregroundColor(Color("tab").opacity(0.9))
                    Text("Unread")
                    Spacer()
                    Text("\(unread.items.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 1)
                        .background(Color.gray.opacity(0.5))
                        .opacity(0.4)
                        .cornerRadius(8)

                    }.accentColor(Color("tab").opacity(0.8))

                }.environment(\.managedObjectContext, Persistence.current.context)
                .onAppear {
                    self.unread.fecthResults()
                }
            }//.listRowBackground(Color("accent"))
        
            HStack {
                ZStack{
                NavigationLink(destination: archiveListView) {
                    EmptyView()
                }
                .opacity(0.0)
                .buttonStyle(PlainButtonStyle())
                HStack{
                    Image(systemName: "star")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 21, height: 21,alignment: .center)
                        .foregroundColor(Color("tab").opacity(0.9))
//                            .foregroundColor(Color.yellow.opacity(0.8))
                    Text("Starred")

                        Spacer()
                    Text("\(archiveListViewModel.items.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 1)
                        .background(Color.gray.opacity(0.5))
                        .opacity(0.4)
                        .cornerRadius(8)
                }
            }
                .accentColor(Color("tab").opacity(0.9))
                .environment(\.managedObjectContext, Persistence.current.context)
                .onAppear {
                    self.archiveListViewModel.fecthResults()
                }
            }
            
        case .unreadIsOn:
//            unreadListView
            if selectedFilter == .unreadIsOn {
                HStack {
                    ZStack{
                        NavigationLink(destination: unreadListView) {
                            EmptyView()
                        }
                        .opacity(0.0)
                        .buttonStyle(PlainButtonStyle())
                    HStack{
                        Image(systemName: "largecircle.fill.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 21, height: 21,alignment: .center)
                            .foregroundColor(Color("tab").opacity(0.9))
                        Text("Unread")
                        Spacer()
                        Text("\(unread.items.count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 1)
                            .background(Color.gray.opacity(0.5))
                            .opacity(0.4)
                            .cornerRadius(8)

                        }.accentColor(Color("tab").opacity(0.8))

                    }.environment(\.managedObjectContext, Persistence.current.context)
                    .onAppear {
                        self.unread.fecthResults()
                    }
                }//.listRowBackground(Color("accent"))
            }

        case .isArchive:
//            archiveListView
            if selectedFilter == .isArchive {
                HStack {
                    ZStack{
                    NavigationLink(destination: archiveListView) {
                        EmptyView()
                    }
                    .opacity(0.0)
                    .buttonStyle(PlainButtonStyle())
                    HStack{
                        Image(systemName: "star")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 21, height: 21,alignment: .center)
                            .foregroundColor(Color("tab").opacity(0.9))
                        Text("Starred")

                            Spacer()
                        Text("\(archiveListViewModel.items.count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 1)
                            .background(Color.gray.opacity(0.5))
                            .opacity(0.4)
                            .cornerRadius(8)
                    }
                }
                    .accentColor(Color("tab").opacity(0.9))
                    .environment(\.managedObjectContext, Persistence.current.context)
                    .onAppear {
                        self.archiveListViewModel.fecthResults()
                    }
                }
                
            }
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
    var selectedFilter: FilterType
    @StateObject var rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    @StateObject var archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    @StateObject var articles = AllArticles(dataSource: DataSourceService.current.rssItem)
    @StateObject var unread = Unread(dataSource: DataSourceService.current.rssItem)
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
            allArticlesView
        case .unreadIsOn:
            unreadListView
        case .isArchive:
            archiveListView
        }
    }
}
