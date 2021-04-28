//
//  ArticleModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 4/27/21.
//

import SwiftUI
import Foundation
import CoreData
import FeedKit
import FaviconFinder
import Combine
import BackgroundTasks
import KingfisherSwiftUI

public class ArticleItem: NSObject,Codable,Identifiable {
    
    public let id: UUID
    var url: String
    var title: String
    var desc: String
    var author: String
    var imageUrl:String
    
    init(id: UUID = UUID(),url: String, imageUrl:String,title: String, desc: String, author: String) {
        self.id = id
        self.url = url
        self.title = title
        self.desc = desc
        self.author = author
        self.imageUrl = imageUrl
    }
    
    init(from dataArticle:RSSItem){
        self.id = dataArticle.uuid.self //UUID()
        self.url = dataArticle.url
        self.title = dataArticle.title
        self.desc = dataArticle.desc
        self.author = dataArticle.author ?? ""
        self.imageUrl = dataArticle.imageUrl ?? ""
    }
   
    static var placeholder = ArticleItem(url: "Url", imageUrl: "imageUrl", title: String(repeating: "Title", count: 5), desc: String(repeating: "Desc", count: 10), author: String(repeating: "Author", count: 3))
}

class ArticleItemViewModel: ObservableObject {
    
    var htmlScrapUtlity = HTMLScraperUtility()
    
    @Published var articles = [RSSItem]()
    @Published var isArticlesLoading = false
    
    var cancellableTask: AnyCancellable? = nil
    
    func loadArticles(for category:RSSGroup) {
        guard let url = URL(string: category.url ?? "") else { return }
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

struct NewsFeedView: View {
    
    var article: ArticleItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    
                    .font(.headline)
                    .lineLimit(2)
                
                Text(article.desc)
                    .font(.subheadline)
                    .opacity(0.7)
                    .lineLimit(2)
                
                Text(article.author)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.leading)
            }.padding(.horizontal, 12)
            
            KFImage(URL(string: article.imageUrl)!)
                .placeholder({
                    ProgressView()
                })
                .resizable()
                .scaledToFill()
                .frame(width: 75, height: 75)
                .clipped()
                .cornerRadius(12)
            
        }
        .padding(12)
    }
}

struct NewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NewsFeedView(article: ArticleItem(
            url: "https://static01.nyt.com/images/2020/07/28/science/28SCI-MARS-JEZERO1/28SCI-MARS-JEZERO1-jumbo.jpg",
            imageUrl: "https://static01.nyt.com/images/2020/07/28/science/28SCI-MARS-JEZERO1/28SCI-MARS-JEZERO1-jumbo.jpg",
            title: "How NASA Found the Ideal Hole on Mars to Land In",
            desc: "Jezero crater, the destination of the Perseverance rover, is a promising place to look for evidence of extinct Martian life.",
            author: "KENNETH CHANG"
        )).preferredColorScheme(.dark)
        .previewDevice(.init(stringLiteral: "iPhone X"))
        .edgesIgnoringSafeArea(.all)
    }
}
