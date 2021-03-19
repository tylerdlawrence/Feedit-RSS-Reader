//
//  AllArticlesRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/18/21.
//

import SwiftUI
import Foundation
import Combine
import UIKit
import SwipeCell
import FeedKit
import KingfisherSwiftUI
import SDWebImageSwiftUI

struct AllArticlesRow: View {
    @EnvironmentObject private var persistence: Persistence
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var articles: AllArticles
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @State private var selectedItem: RSSItem?
//    @ObservedObject var rss: RSS
        
    init(articles: AllArticles, rssFeedViewModel: RSSFeedViewModel) {
        self.articles = articles
        self.rssFeedViewModel = rssFeedViewModel
    }
    
    var filteredArticles: [RSSItem] {
        return rssFeedViewModel.items.filter({ (item) -> Bool in
            return !((self.rssFeedViewModel.isOn && !item.isArchive) || (self.rssFeedViewModel.unreadIsOn && item.isRead))
        })
    }
    

    @Environment(\.imageCache) var cache: ImageCache
    private func list(of articles: [RSSItem]) -> some View {
        return List(filteredArticles) { item in
               NavigationLink(
                   destination: RSSFeedDetailView(rssItem: item, rssFeedViewModel: self.rssFeedViewModel),
                   label: { RSSItemRow(wrapper: item, menu: self.contextmenuAction(_:), rssFeedViewModel: rssFeedViewModel) }
               )
           }
       }
        
    private var spinner: some View {
        Spinner(isAnimating: true, style: .medium)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
//                ForEach(thumbnails, id: \.self) { url in
                list(of: filteredArticles).eraseToAnyView()
                    .environment(\.managedObjectContext, Persistence.current.context)
                    .environmentObject(Persistence.current)
                    .environmentObject(DataSourceService.current.rssItem)
//                }
            }
        }
//        HStack {
//            KFImage(URL(string: rssItem.image)!)
//                .placeholder({
//                    ProgressView()
//                })
//                .resizable()
//                .scaledToFill()
//                .frame(width: 100, height: 120)
//                .clipped()
//                .cornerRadius(12)
//
//
//            VStack(alignment: .leading, spacing: 8) {
//                Text(rssItem.title)
//
//                    .font(.headline)
//                    .lineLimit(3)
//
//                Text(rssItem.desc)
//                    .font(.subheadline)
//                    .opacity(0.7)
//                    .lineLimit(1)
//
//                Text(rssItem.author)
//                    .font(.system(size: 13, weight: .medium, design: .rounded))
//                    .multilineTextAlignment(.leading)
//            }.padding(.horizontal, 12)
//        }
//        .padding(12)

    }
    func contextmenuAction(_ item: RSSItem) {
        rssFeedViewModel.archiveOrCancel(item)
    }
}

struct AllArticlesRow_Previews: PreviewProvider {
    static var previews: some View {
        let rss = RSS()
        let articles = AllArticles(dataSource: DataSourceService.current.rssItem)
        return AllArticlesRow(articles: articles, rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
            .environment(\.managedObjectContext, Persistence.current.context)
            .environmentObject(Persistence.current)
            .environmentObject(DataSourceService.current.rssItem)
            .preferredColorScheme(.dark)
    }
}

struct Spinner: UIViewRepresentable {
    let isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: style)
        spinner.hidesWhenStopped = true
        return spinner
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}
