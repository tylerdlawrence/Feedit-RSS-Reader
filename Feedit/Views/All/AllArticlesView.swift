//
//  AllArticlesView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/17/21.
//

import SwiftUI
import CoreData
import Foundation
import os.log
import Combine
import UIKit
import FeedKit
import KingfisherSwiftUI

struct AllArticlesView: View {
    @EnvironmentObject private var persistence: Persistence
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var rssDataSource: RSSDataSource
    
    @ObservedObject var articles: AllArticles
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    @State private var selectedItem: RSSItem?
    @State private var footer = "Load More Articles"
    
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    
    init(articles: AllArticles, rssFeedViewModel: RSSFeedViewModel, selectedFilter: FilterType) {
        self.articles = articles
        self.rssFeedViewModel = rssFeedViewModel
        self.selectedFilter = selectedFilter
    }
        
    private var refreshButton: some View {
        Button(action: self.articles.loadMore) {
            Image(systemName: "arrow.clockwise").font(.system(size: 16, weight: .bold)).foregroundColor(Color("tab")).padding()
        }.buttonStyle(BorderlessButtonStyle())
    }
    
    private func list(of articles: [RSSItem]) -> some View {
        return List(filteredArticles) { item in
               NavigationLink(
                   destination: RSSFeedDetailView(rssItem: item, rssFeedViewModel: self.rssFeedViewModel),
                   label: { RSSItemRow(rssItem: item, menu: self.contextmenuAction(_:), rssFeedViewModel: rssFeedViewModel) }
               )
           }
       }
    
    @State private var selection = Set<String>()
    
    var filteredArticles: [RSSItem] {
        return articles.items.filter({ (item) -> Bool in
            return !((self.articles.isOn && !item.isArchive) || (self.articles.unreadIsOn && item.isRead))
        })
    }
    
    @State var selectedFilter: FilterType
    private var navButtons: some View {
        HStack(alignment: .center, spacing: 30) {
            Toggle(isOn: $rssFeedViewModel.unreadIsOn) { Text("") }
                .toggleStyle(CheckboxStyle()).padding(.leading)
//        }
            Spacer(minLength: 1)
            
            Picker("", selection: $selectedFilter, content: {
                ForEach(FilterType.allCases, id: \.self) {
                    Text($0.rawValue)
                }
//                SelectedFilterView(selectedFilter: selectedFilter)
            }).pickerStyle(SegmentedPickerStyle()).frame(width: 180, height: 20)
            .listRowBackground(Color("accent"))
            
            Spacer(minLength: 0)
            
            Toggle(isOn: $rssFeedViewModel.isOn) { Text("") }
                .toggleStyle(StarStyle()).padding(.trailing)
        }
    }
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ZStack {
                List {
                    ForEach(articles.items, id: \.self) { article in
    //                    list(of: filteredArticles).eraseToAnyView()
                        ZStack {
                            NavigationLink(destination: WebView(rssItem: article, onCloseClosure: {})) {
    //                        NavigationLink(destination: RSSFeedDetailView(rssItem: unread, rssFeedViewModel: RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)).environmentObject(DataSourceService.current.rss)) {
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
                    }.environment(\.managedObjectContext, Persistence.current.context)
                    .environmentObject(rssFeedViewModel)
    //                .environmentObject(persistence)
                }
                .animation(.default)
                .add(self.searchBar)
                .accentColor(Color("tab"))
                .listRowBackground(Color("accent"))
                .navigationBarTitle("", displayMode: .inline)
//                .navigationBarItems(trailing: refreshButton)
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
                                .frame(width: 21, height: 21,alignment: .center)
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

//                    ToolbarItem(placement: .bottomBar) {
//                        Toggle(isOn: $rssFeedViewModel.unreadIsOn) { Text("") }
//                            .toggleStyle(CheckboxStyle())
//    //                    MarkAsReadButton(isSet: $rssItem.isRead)
//
//
//                    }
//                    ToolbarItem(placement: .bottomBar) {
//                        Spacer()
//                    }
//                    ToolbarItem(placement: .bottomBar) {
//    //                    MarkAsStarredButton(isSet: $rssItem.isArchive)
//                        Toggle(isOn: $rssFeedViewModel.isOn) { Text("") }
//                            .toggleStyle(StarStyle())
                    }
//                }
//            Spacer()
//            navButtons
//                .frame(width: UIScreen.main.bounds.width, height: 49)
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

//struct AllArticlesView_Previews: PreviewProvider {
//    static let rss = RSS()
//    static var previews: some View {
//        AllArticlesView(articles: AllArticles(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
//    }
//}
