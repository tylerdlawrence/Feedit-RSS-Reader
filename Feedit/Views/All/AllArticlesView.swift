//
//  AllArticlesView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/17/21.
//

import SwiftUI
import Introspect
import DispatchIntrospection
import CoreData
import Foundation
import os.log
import Combine
import UIKit
import FeedKit
import KingfisherSwiftUI
import libcmark

struct AllArticlesView: View {
    @EnvironmentObject private var persistence: Persistence
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var rssDataSource: RSSDataSource
    
    @ObservedObject var articles: AllArticles
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    @State private var selectedItem: RSSItem?
    @State private var footer = "Load More Articles"
    
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    
    init(articles: AllArticles, rssFeedViewModel: RSSFeedViewModel) {
        self.articles = articles
        self.rssFeedViewModel = rssFeedViewModel        
    }
        
    private var refreshButton: some View {
        Button(action: self.articles.loadMore) {
            Image(systemName: "arrow.clockwise").font(.system(size: 16, weight: .bold)).foregroundColor(Color("tab")).padding()
        }.buttonStyle(BorderlessButtonStyle())
    }

    @State private var selection = Set<String>()
    
    var filteredArticles: [RSSItem] {
        return articles.items.filter({ (item) -> Bool in
            return !((self.articles.isOn && !item.isArchive) || (self.articles.unreadIsOn && item.isRead))
        })
    }
    
    @State var selectedFilter: FilterType = .all
    private var navButtons: some View {
        HStack(alignment: .center, spacing: 30) {
            Toggle(isOn: $rssFeedViewModel.unreadIsOn) { Text("") }
                .toggleStyle(CheckboxStyle()).padding(.leading)
            Spacer(minLength: 1)
            
            Picker("", selection: $selectedFilter, content: {
                ForEach(FilterType.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }).pickerStyle(SegmentedPickerStyle()).frame(width: 180, height: 20)
            .listRowBackground(Color("accent"))
            
            Spacer(minLength: 0)
            
            Toggle(isOn: $rssFeedViewModel.isOn) { Text("") }
                .toggleStyle(StarStyle()).padding(.trailing)
        }
    }
    
    @State var isShowing: Bool = false
    @State private var searchTerm : String = ""
        
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ZStack {
                List {
                    ForEach(articles.items, id: \.self) { article in
                        ZStack {
//                            NavigationLink(destination: RSSFeedDetailView(rssItem: article, rssFeedViewModel: self.rssFeedViewModel)) {
                            NavigationLink(destination: WebView(rssItem: article, onCloseClosure: {})) {
                               EmptyView()
                           }
                           .opacity(0.0)
                           .buttonStyle(PlainButtonStyle())
                           
                            HStack(alignment: .top) {
                                RSSItemRow(rssItem: article, menu: self.contextmenuAction(_:), rssFeedViewModel: RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem))
                                   .contentShape(Rectangle())
                                   .onTapGesture {
                                       self.selectedItem = article
                                   }
                               }
                           }
                    }.environmentObject(rssDataSource)
                    .environment(\.managedObjectContext, Persistence.current.context)
                    .environmentObject(rssFeedViewModel)
                }
//                .animation(.default)
                .add(searchBar)
                .accentColor(Color("tab"))
                .listRowBackground(Color("accent"))
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarItems(trailing:
                                        Button(action: {
                                            articles.items.forEach { (article) in
                                                article.isRead = true
                                                articles.items.removeAll()
                                                saveContext()
                                            }
                                        }) {
                                            Image(systemName: "checkmark.circle").font(.system(size: 18)).foregroundColor(Color("tab"))
                                        }
                )
            }

            Spacer()
            navButtons
                .frame(width: UIScreen.main.bounds.width, height: 49)
                .toolbar{
                    ToolbarItem(placement: .principal) {
                        HStack{
                            Image(systemName: "chart.bar.doc.horizontal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18, height: 18,alignment: .center)
                                .foregroundColor(Color("tab").opacity(0.9))
                            Text("All Articles")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                            Text("\(articles.items.count)")
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
                }
            }
        .onAppear {
            self.articles.fecthResults()
        }
    }
    func contextmenuAction(_ item: RSSItem) {
        articles.archiveOrCancel(item)
    }
    private func saveContext() {
        do {
            try Persistence.current.context.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved Error: \(error)")
        }
    }
}

extension AllArticlesView {
    
}

struct AllArticlesView_Previews: PreviewProvider {
    static let rss = RSS()
    static var previews: some View {
        NavigationView {
            AllArticlesView(articles: AllArticles(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem))
                .preferredColorScheme(.dark)
        }
    }
}
