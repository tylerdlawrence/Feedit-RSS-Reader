//
//  SmartFeedsHomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/29/21.
//

import SwiftUI
import CoreData
import Combine

// MARK: DISCLOSURE GROUP STYLE
struct SmartFeedsHomeView: View {

    @StateObject var rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    @StateObject var archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    @StateObject var articles: AllArticles
    @StateObject var unread: Unread
    
    @State private var revealSmartFilters = true
    
    private var allArticlesView: some View {
        let rss = RSS()
        return AllArticlesView(articles: AllArticles(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
    }

    private var archiveListView: some View {
        ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: self.rssFeedViewModel)
    }

    private var unreadListView: some View {
        UnreadListView(unreads: Unread(dataSource: DataSourceService.current.rssItem))
    }
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $revealSmartFilters,
            content: {
//        Section(header: Text("Smart Feeds").font(.system(size: 18, weight: .medium, design: .rounded)).textCase(nil).foregroundColor(Color("text"))) {
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
                }.listRowBackground(Color("accent"))

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
                }.listRowBackground(Color("accent"))

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
                }.listRowBackground(Color("accent"))
            },
            label: {
                HStack {
                    Text("Smart Feeds")
                        .font(.system(size: 18, weight: .regular, design: .rounded)).textCase(nil)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                self.revealSmartFilters.toggle()
                            }
                        }
                }
            })
//        }.listStyle(InsetGroupedListStyle())
//            .listRowBackground(Color("accent"))
            .listRowBackground(Color("darkerAccent"))
            .accentColor(Color("tab"))
    }
}

struct SmartFeedsHomeView_Previews: PreviewProvider {
    static let rss = RSS()
    static var previews: some View {
        NavigationView {
            List {
                SmartFeedsHomeView(rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), archiveListViewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem), articles: AllArticles(dataSource: DataSourceService.current.rssItem), unread: Unread(dataSource: DataSourceService.current.rssItem))
        
                    .environmentObject(DataSourceService.current.rss)
                    .environmentObject(DataSourceService.current.rssItem)
                    .environment(\.managedObjectContext, Persistence.current.context)
                .preferredColorScheme(.dark)
            }
        }
    }
}

struct SmartFeedsSectionHomeView: View {

    @StateObject var rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    @StateObject var archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    @StateObject var articles: AllArticles
    @StateObject var unread: Unread
    
    @State private var revealSmartFilters = true
    
    private var allArticlesView: some View {
        let rss = RSS()
        return AllArticlesView(articles: AllArticles(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
    }

    private var archiveListView: some View {
        ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: self.rssFeedViewModel)
    }

    private var unreadListView: some View {
        UnreadListView(unreads: Unread(dataSource: DataSourceService.current.rssItem))
    }
    
    @State var selectedFilter: FilterType
    
    var body: some View {
        Section(header: Text("Smart Feeds").font(.system(size: 18, weight: .medium, design: .rounded)).textCase(nil).foregroundColor(Color("text")).padding(.leading)) {
            
            if selectedFilter == .all {
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
            } else {
                self.hidden(true)
            }
            
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
            } else {
                self.hidden(true)
            }
            
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
                
                //.listRowBackground(Color("accent"))
            } else {
                self.hidden(true)
            }

        }.listStyle(InsetGroupedListStyle())
        
//            .listRowBackground(Color("accent"))
//            .listRowBackground(Color("darkerAccent"))
            .accentColor(Color("tab"))
    }
}

struct SmartFeedsSectionHomeView_Previews: PreviewProvider {
    static let rss = RSS()
    static var previews: some View {
        NavigationView {
            List {
                SmartFeedsSectionHomeView(rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), archiveListViewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem), articles: AllArticles(dataSource: DataSourceService.current.rssItem), unread: Unread(dataSource: DataSourceService.current.rssItem), selectedFilter: .all)
        
                    .environmentObject(DataSourceService.current.rss)
                    .environmentObject(DataSourceService.current.rssItem)
                    .environment(\.managedObjectContext, Persistence.current.context)
                .preferredColorScheme(.dark)
            }.listStyle(InsetGroupedListStyle())
        }
    }
}
