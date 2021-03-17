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

struct AllArticlesView: View {
    
    @ObservedObject var articles: AllArticles
    
    @State private var selectedItem: RSSItem?
    @State var footer = "load more"
    
    init(articles: AllArticles) {
        self.articles = articles
    }
    
    var body: some View {
        List {
            ForEach(articles.items, id: \.self) { article in
                RSSItemRow(wrapper: article, rssFeedViewModel: RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem))
                    .onTapGesture {
                        self.selectedItem = article
                }
            }
            VStack(alignment: .center) {
                Button(action: self.articles.loadMore) {
                    Text(self.footer)
                }
            }
        }
        .onAppear {
            self.articles.fecthResults()
        }
    }
}

extension AllArticlesView {
    
}

struct AllArticlesView_Previews: PreviewProvider {
    static var previews: some View {
        AllArticlesView(articles: AllArticles(dataSource: DataSourceService.current.rssItem))
    }
}
