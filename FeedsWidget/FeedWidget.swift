//
//  FeedWidget.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 4/14/21.
//

import SwiftUI
import WidgetKit
import CoreData
import Combine
import KingfisherSwiftUI
import Foundation
import FeedKit

class RSSParser: NSObject, XMLParserDelegate {
    var rssItems: [RSSItem] = []
    private var currentElement = ""

    private var currentTitle: String = "" {
        didSet {
            currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentDescription: String = "" {
        didSet {
            currentDescription = currentDescription.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentPubDate: String = "" {
        didSet {
            currentPubDate = currentPubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentLink: String = "" {
        didSet {
            currentLink = currentLink.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var parserCompletionHandler: (([RSSItem]) -> Void)?
        func parse(url: String, completionHandler: (([RSSItem]) -> Void)?) {
        self.parserCompletionHandler = completionHandler

        let request = URLRequest(url: URL(string: url)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            /// parse our xml data
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        
        task.resume()
    }

    // MARK: - XML Parser Delegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "item" {
            currentTitle = ""
            currentDescription = ""
            currentPubDate = ""
            currentLink = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "title": currentTitle += string
        case "description" : currentDescription += string
        case "pubDate" : currentPubDate += string
        case "link" : currentLink += string

        default: break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
//            let rssItem = RSSItem(title: currentTitle, link: currentLink, description: currentDescription, pubDate: currentPubDate)
            let rssItem = RSSItem()
            self.rssItems.append(rssItem)
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        WidgetCenter.shared.reloadAllTimelines()
        parserCompletionHandler?(rssItems)
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}


struct ParserProvider: TimelineProvider {
//    @State private var rssItems:[RSSItem]?
    var rssItems:[RSSItem]?
    let feedParser = RSSParser()
    func placeholder(in context: Context) -> SimpleEntry {
        //SimpleEntry(date: Date(), title:"News", description: "News article here", url: "Http://link", createTime: Date())
        SimpleEntry(date: Date(), title: "A Message on the Upcoming Shows", description: "We are happy to announce that the Band and Fans WILL be seeing each other, in concert setting – SOON! A long awaited moment.", url: "https://www.apple.com", createTime: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), title: "A Message on the Upcoming Shows", description: "We are happy to announce that the Band and Fans WILL be seeing each other, in concert setting – SOON! A long awaited moment.", url: "https://www.apple.com", createTime: Date())
            //SimpleEntry(date: Date(), title:"News", description: "News Article Here", url: "https://link", createTime: Date())
        completion(entry)
    }
    
//    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        guard !feedParser.rssItems.isEmpty else { return }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        
        var entries: [SimpleEntry] = []
        feedParser.parse(url: "https://widespreadpanic.com/feed") {(rssItems) in
//             self.rssItems = rssItems
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
            let currentDate = Date()
            let entry = SimpleEntry(date: currentDate, title:rssItems[0].title, description: rssItems[0].description, url: rssItems[0].url, createTime: rssItems[0].createTime!)
            entries.append(entry)
        
            let timeline = Timeline(entries: entries, policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let description: String
    let url: String
    let createTime: Date
    let rssItems = RSSItem()
}

struct FritchNewsEntryView : View {
    var entry: SimpleEntry
    var body: some View {
        ZStack {
            Image("launch")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(0.4).padding([.top, .leading], -45)
                .frame(width: 125, height: 125)
                
        Spacer()
            
        VStack(alignment: .leading, spacing: 2) {
            Text("\(entry.createTime.string())")
                .textCase(.uppercase)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
            
            Text(entry.title)
                .lineLimit(3)
                .font(.system(.subheadline).bold())
                .foregroundColor(Color("text"))
            
            Text(entry.description)
                .lineLimit(1)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                .padding()
        .background(Color(UIColor.systemBackground).blur(radius: 10.0).opacity(0.3))
        }
    }
}

struct TestWidget: Widget {
    let kind: String = "TestWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ParserProvider()) { entry in
            FritchNewsEntryView(entry: entry)
        }
        .configurationDisplayName("Random Article")
        .description("One of your most recent articles")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TestWidget_Previews: PreviewProvider {
    static var previews: some View {
        FritchNewsEntryView(entry: SimpleEntry(date: Date(), title: "A Message on the Upcoming Shows", description: "We are happy to announce that the Band and Fans WILL be seeing each other, in concert setting – SOON! A long awaited moment.", url: "https://www.apple.com", createTime: Date()))
            .background(Color(UIColor.systemBackground)).environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
