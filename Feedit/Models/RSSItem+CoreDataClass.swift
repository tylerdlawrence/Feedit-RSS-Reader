//
//  RSSItem+CoreDataClass.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//


import SwiftUI
import FeedKit
import FaviconFinder
import Combine
import CoreData
import BackgroundTasks

@objc(RSSItem)
public class RSSItem: NSManagedObject {
    
}

class Post: Codable, Identifiable, ObservableObject {
    var id = UUID()
    var title: String
    var description: String
    var url: URL
    var date: Date
    var post: [Post] {
        didSet {
            objectWillChange.send()
        }
    }
    
    var isRead: Bool {
        return readDate != nil
    }

    var readDate: Date? {
        didSet {
            objectWillChange.send()
        }
    }
    
    var lastUpdateDate: Date
    
//    init?(item: RSSItem) {
//        self.title =  item.title ?? ""
//        self.description = item.description ?? ""
//        
//        if let link = item.link, let url = URL(string: link) {
//            self.url = url
//        } else {
//            return nil
//        }
//        self.date = item.pubDate ?? Date()
//        lastUpdateDate = Date()
//    }
    
//    init?(atomFeed: AtomFeedEntry) {
//        self.title =  atomFeed.title ?? ""
//        let description = atomFeed.content?.value ?? ""
//
//        let attributed = try? NSAttributedString(data: description.data(using: .unicode)!, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
//        self.description = attributed?.string ?? ""
//
//        if let link = atomFeed.links?.first?.attributes?.href, let url = URL(string: link) {
//            self.url = url
//        } else {
//            return nil
//        }
//        self.date = atomFeed.updated ?? Date()
//        lastUpdateDate = Date()
//    }
    
//    init(title: String, description: String, url: URL) {
//        self.title = title
//        self.description = description
//        self.url = url
//        self.date = Date()
//        lastUpdateDate = Date()
//    }
    
//    static var testObject: Post {
//        return Post(title: "Test post title",
//        description: "Test post description",
//        url: URL(string: "https://www.google.com")!)
//    }
}
