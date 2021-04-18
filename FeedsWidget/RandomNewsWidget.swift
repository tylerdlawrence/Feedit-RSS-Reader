//
//  FeedsWidget.swift
//  FeedsWidget
//
//  Created by Tyler D Lawrence on 3/23/21.
//

import WidgetKit
import SwiftUI
import Intents
import CoreData
import KingfisherSwiftUI
import Foundation
import UIKit
import Combine

struct NewsProvider: TimelineProvider {
    
    let defaultContent = NewsWidgetContent(date: Date(),title: "Today News title", description: "This is news text. It contains the beginning of some news")
    
    func placeholder(in context: Context) -> NewsWidgetContent {
        defaultContent
    }
    
    //data widget displays in widget gallery
    func getSnapshot(in context: Context, completion: @escaping (NewsWidgetContent) -> ()) {
        completion(defaultContent)
    }
    
    //the main method to produce data and timeline
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        print(#function)
        //initiate date
        var entryDate = Date()
        
        var entries: [NewsWidgetContent] = []
        //get saved contents from shared container
        //var contents = WidgetContent.readContents()
        
        //update contents from Network
        WidgetContent.loadData { (articles) in
            if let articles = articles, articles.count >= 6 {
                print("articles.count: \(articles.count)")

                for i in 0...6 {

                    //generate date for time line
                    entryDate = Calendar.current.date(byAdding: .minute, value: 1, to: entryDate)!
                    
                    //create entry
                    var newsEntry = NewsWidgetContent(date: entryDate, title: articles[i].title, description: articles[i].description ?? "")
                
                    //populate with image if there is some
                    if let urlToImage = articles[i].urlToImage {
                        WidgetContent.downloadImageBy(url: urlToImage) { (image) in
                            newsEntry.image = image
                            print("IMAGE")
                            entries.append(newsEntry)
                            //stupidly check for last value
                            if i == 6 {
                                let timeline = Timeline(entries: entries, policy: .atEnd)
                                print("entries.count")
                                print(entries.count)
                                completion(timeline)
                            }
                        }
                    } else {
                    entries.append(newsEntry)
                        //stupidly check for last value
                        if i == 6 {
                            let timeline = Timeline(entries: entries, policy: .atEnd)
                            completion(timeline)
                        }
                    }
                }
                
            }

        }
        
//Dispay only one news
//                WidgetContent.loadData { (articles) in
//                    if let articles = articles {
//                        var entries: [NewsWidgetContent] = []
//
//                        if let first = articles.first {
//                            entryDate = Calendar.current.date(byAdding: .minute, value: 1, to: entryDate)!
//                            var newsEntry = NewsWidgetContent(date: entryDate, title: first.title, description: first.description ?? "")
//
//                            if let urlToImage = first.urlToImage {
//                            WidgetContent.downloadImageBy(url: urlToImage) { (image) in
//                                newsEntry.image = image
//                                entries.append(newsEntry)
//                                let timeline = Timeline(entries: entries, policy: .after(entryDate))
//                                completion(timeline)
//                            }
//                            } else {
//                            entries.append(newsEntry)
//                            let timeline = Timeline(entries: entries, policy: .after(entryDate))
//                            completion(timeline)
//                            }
//                        }
//                    }
//                }
        

    }
}

struct NewsWidget: Widget {
    let kind: String = "NewsWidget"
    
    var body: some WidgetConfiguration {
        
        StaticConfiguration(kind: kind, provider: NewsProvider()) { entry in
            NewsWidgetEntryView(entry: entry)//, article: ArticleListViewModel().articles[0])

        }
        .configurationDisplayName("News Widget")
        .description("This is an example of news widget.")
    }
}

struct SmallNewsWidgetView: View {
    var entry: NewsWidgetContent
    var article: ArticleViewModel?
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if entry.image != nil {
                Image(uiImage: entry.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.4)
            } else {
                Image("launch")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.4).padding([.top, .leading], -45)
                    .frame(width: 125, height: 125)
            }
            Spacer()
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color("text"))
                    .lineLimit(5)
//                        .widgetURL(URL(string:"NewsWidgetURL://link/\(entry.title)")!)
                Spacer()
                Text(article?.sourceName ?? "\(article?.publishedAt ?? entry.date.string())")
                    .textCase(.uppercase)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
            .padding()
            .background(Color(UIColor.systemBackground).blur(radius: 10.0).opacity(0.3))
        }
    }
}

struct MediumNewsWidgetView: View {
    var entry: NewsWidgetContent
    var article: ArticleViewModel?

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Image("launch")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                    .padding([.top, .leading])
            }
            Spacer()
        }
        Divider()
        VStack(alignment: .leading, spacing: 0) {
            Text(entry.title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color("text"))
                .lineLimit(2)
            HStack(spacing: 4.0) {
                Text(article?.sourceName ?? "\(article?.publishedAt ?? entry.date.string())")
                    .textCase(.uppercase)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                Spacer(minLength: 0)
//                Text("\(article?.publishedAt ?? entry.date.string())")
//                    .textCase(.uppercase)
//                    .font(.system(size: 11, weight: .medium, design: .rounded))
            }.foregroundColor(.gray)
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal)
        .background(Color(UIColor.systemBackground).blur(radius: 10.0).opacity(0.3))
        
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color("text"))
                .lineLimit(2)
            HStack(spacing: 4.0) {
                Text(article?.sourceName ?? "\(article?.publishedAt ?? entry.date.string())")
                    .textCase(.uppercase)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                Spacer(minLength: 0)
//                Text("\(article?.publishedAt ?? entry.date.string())")
//                    .textCase(.uppercase)
//                    .font(.system(size: 11, weight: .medium, design: .rounded))
            }.foregroundColor(.gray)
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        .padding([.bottom, .horizontal])
        .background(Color(UIColor.systemBackground).blur(radius: 10.0).opacity(0.3))
    }
}

struct LargeNewsWidgetView: View {
    var entry: NewsWidgetContent
    
    var article: ArticleViewModel?
//    var articles = [ArticleViewModel]()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Image("launch")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                    .padding([.top, .leading])
            }
            Spacer()
        }
        Divider()
        ForEach(0..<3, id: \.self, content: { i in
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(entry.title)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color("text"))
                        .lineLimit(2)
//                    HStack(spacing: 4.0) {
//                        Text(article?.sourceName ?? "\(article?.publishedAt ?? entry.date.string())")
//                            .textCase(.uppercase)
//                            .font(.system(size: 11, weight: .medium, design: .rounded))
//                        Spacer(minLength: 0)
//                    }.foregroundColor(.gray)
                    Spacer()
                    if article?.image != nil {
                        Image(uiImage: (article?.image)!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "globe").font(.system(size: 20, weight: .regular, design: .rounded))
                    }
                }
                HStack(spacing: 4.0) {
                    Text(article?.sourceName ?? "\(article?.publishedAt ?? entry.date.string())")
                        .textCase(.uppercase)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                    Spacer(minLength: 0)
                }.foregroundColor(.gray)
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading).padding()
            .background(Color(UIColor.systemBackground).blur(radius: 10.0).opacity(0.3))
        })
//        VStack(alignment: .leading, spacing: 0) {
//            Text(entry.title)
//                .font(.system(size: 14, weight: .medium, design: .rounded))
//                .foregroundColor(Color("text"))
//                .lineLimit(2)
//            HStack(spacing: 4.0) {
//                Text(article?.sourceName ?? "\(article?.publishedAt ?? entry.date.string())")
//                    .textCase(.uppercase)
//                    .font(.system(size: 11, weight: .medium, design: .rounded))
//                Spacer(minLength: 0)
////                Text("\(article?.publishedAt ?? entry.date.string())")
////                    .textCase(.uppercase)
////                    .font(.system(size: 11, weight: .medium, design: .rounded))
//            }.foregroundColor(.gray)
//        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
//        .padding()
//        .background(Color(UIColor.systemBackground).blur(radius: 10.0).opacity(0.3))
        
//        VStack(alignment: .leading, spacing: 0) {
//            Text(entry.title)
//                .font(.system(size: 14, weight: .medium, design: .rounded))
//                .foregroundColor(Color("text"))
//                .lineLimit(2)
//            HStack(spacing: 4.0) {
//                Text(article?.sourceName ?? "\(article?.publishedAt ?? entry.date.string())")
//                    .textCase(.uppercase)
//                    .font(.system(size: 11, weight: .medium, design: .rounded))
//                Spacer(minLength: 0)
////                Text("\(article?.publishedAt ?? entry.date.string())")
////                    .textCase(.uppercase)
////                    .font(.system(size: 11, weight: .medium, design: .rounded))
//            }.foregroundColor(.gray)
//        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
//        .padding()
//        .background(Color(UIColor.systemBackground).blur(radius: 10.0).opacity(0.3))
    }
}

// View of widget
struct NewsWidgetEntryView : View {
    var entry: NewsWidgetContent
//    @ObservedObject private var article = ArticleListViewModel()
    
    @Environment(\.widgetFamily) var widgetFamily
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallNewsWidgetView(entry: entry)
        case .systemMedium:
            MediumNewsWidgetView(entry: entry)
        case .systemLarge:
            LargeNewsWidgetView(entry: entry)//, article: article.articles[0])
        default:
            SmallNewsWidgetView(entry: entry)
        }
    }
}

struct JSONModel: Codable {
    let articles: [Article]
}

struct Article: Codable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
   // let content: String?
    
}
// MARK: - Source
struct Source: Codable {
    let id: String?
    let name: String
}

//struct NewsArticle: View {
//    var entry: WidgetContent
//    var source: Source?
//    var article: Article//?
//
//    var body: some View {
//
//        ZStack(alignment: .topLeading) {
//            HStack(alignment: .center, spacing: nil, content: {
//                VStack(alignment: .leading, spacing: 0) {
//                    Divider()
//                    Image(uiImage: thumbnail(entry.image))
//                        .resizable()
//                        .frame(width: 20, height: 20)
//                        .cornerRadius(4)
//                    Text("\(article.title)")
//                        .lineLimit(3)
//                        .font(.system(size: 14, weight: .medium, design: .rounded))
//                        .foregroundColor(Color("text"))
//                    HStack {
//                        Text(source?.name ?? "Unknown Author")
//                            .textCase(.uppercase)
//                            .font(.system(size: 11, weight: .medium, design: .rounded))
//                            .foregroundColor(.gray)
//                        Spacer()
//                        Text("\(article.publishedAt)")
//                            .textCase(.uppercase)
//                            .font(.system(size: 11, weight: .medium, design: .rounded))
//                            .foregroundColor(.gray)
//                    }
//                }
//                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
//            .background(Color(UIColor.systemBackground).blur(radius: 10.0).opacity(0.3))
//            })
//        }
//    }
//    func thumbnail(_ data: Data?) -> UIImage {
//        if data == nil {
//            return UIImage(systemName: "globe")!
//        } else {
//            return UIImage(data: data!)!
//        }
//    }
//    func string(format: String = "MMM d, h:mm") -> String {
//        let f = DateFormatter()
//        f.dateFormat = format
//        return f.string(from: Date())
//    }
//}

struct NewsWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        let entry = NewsWidgetContent(date: Date(), title: "A Message on the Upcoming Shows", description: "We are happy to announce that the Band and Fans WILL be seeing each other, in concert setting – SOON! A long awaited moment.")
        Group {
            NewsWidgetEntryView(entry: entry)//, article: ArticleListViewModel().articles[0])
                .background(Color(UIColor.systemBackground)).environment(\.colorScheme, .dark).previewContext(WidgetPreviewContext(family: .systemSmall))
            
            NewsWidgetEntryView(entry: entry)
                .background(Color(UIColor.systemBackground)).environment(\.colorScheme, .dark).previewContext(WidgetPreviewContext(family: .systemMedium))
            
            NewsWidgetEntryView(entry: entry)
                .background(Color(UIColor.systemBackground)).environment(\.colorScheme, .dark).previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
