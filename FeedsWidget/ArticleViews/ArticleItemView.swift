//
//  ArticleItemView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/24/21.
//

import SwiftUI
import WidgetKit
import CoreData
import Foundation
import os.log
import UIKit
import RSWeb

//MARK: FOR MEDIUM AND LARGE WIDGETS

struct ArticleItemView: View {
    
    var article: LatestArticle
    var deepLink: URL
    
    var body: some View {
        Link(destination: deepLink, label: {
            HStack(alignment: .top, spacing: nil, content: {
                // Feed Icon
                Image(uiImage: thumbnail(article.feedIcon))
                    .resizable()
                    .frame(width: 30, height: 30)
                    .cornerRadius(4)
                
                // Title and Feed Name
                VStack(alignment: .leading) {
                    Text(article.articleTitle ?? "Untitled")
                        .font(.footnote)
                        .bold()
                        .lineLimit(1)
                        .foregroundColor(.primary)
                        .padding(.top, -3)
                    
                    HStack {
                        Text(article.feedTitle)
                            .font(.caption)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(pubDate(article.pubDate))
                            .font(.caption)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                }
            })
        })
    }
    
    func thumbnail(_ data: Data?) -> UIImage {
        if data == nil {
            return UIImage(systemName: "getInfo")!
        } else {
            return UIImage(data: data!)!
        }
    }
    
    func pubDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        guard let date = dateFormatter.date(from: dateString) else {
            return ""
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none
        
        return displayFormatter.string(from: date)
    }
}

//MARK: FOR SMALL WIDGET

struct SmallArticleItemView: View {
    
    var article: LatestArticle
    var deepLink: URL
    
    var body: some View {
        Link(destination: deepLink, label: {
            ZStack(alignment: .topLeading) {
                Image("launch")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.4).padding([.top, .leading], -50)
                    .frame(width: 100, height: 100)
                VStack(alignment: .leading) {
                    Spacer(minLength: 0)
                    Text(article.articleTitle ?? "Untitled").font(.subheadline).bold().foregroundColor(Color("text"))
                    Spacer(minLength: 0)
                    HStack(alignment: .center, spacing: 4.0) {
                        VStack(alignment: .leading) {
                            Text(article.feedTitle).font(.caption).foregroundColor(.gray)
                            Text(pubDate(article.pubDate)).font(.caption2).foregroundColor(.gray)
                        }.lineLimit(1).minimumScaleFactor(0.5)
                    }
                }.background(Color(UIColor.systemBackground).blur(radius: 10.0).opacity(0.5))
            }
        })
        .widgetURL(WidgetDeepLink.icon.url)
    }
    
    func pubDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        guard let date = dateFormatter.date(from: dateString) else {
            return ""
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .short
        displayFormatter.timeStyle = .none
        
        return displayFormatter.string(from: date)
    }
}
