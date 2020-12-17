//
//  ArticleViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 12/16/20.
//

import Foundation
import Combine

class ArticleViewModel: ObservableObject {
    
    var htmlScrapUtlity = HTMLScraperUtility()
    
    @Published var articles = [Article]()
    @Published var isArticlesLoading = false
    
    var cancellableTask: AnyCancellable? = nil
    
    func loadArticles(for rss:RSS) {
        guard let url = URL(string: rss.url) else { return }
        self.isArticlesLoading = true
        self.cancellableTask?.cancel() //cancel last subscription to prevent race condition
        self.cancellableTask = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data) //extract Data() from tuple
            .flatMap(htmlScrapUtlity.scrapArticle(from:)) //send data to scrap function that will return article objects (array)
            .sink { (completion) in
                self.isArticlesLoading = false //once we got articles, close the loader
            } receiveValue: { [unowned self] (articles) in
                self.articles = articles
            }
    }
    
    deinit {
        cancellableTask = nil
    }
    
}
