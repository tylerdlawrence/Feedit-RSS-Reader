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
import Foundation
import CoreData
import BackgroundTasks

@objc(RSSItem)
public class RSSItem: NSManagedObject { //}, Codable {

}

//    //MARK: CONFORM MANAGED OBJECTS TO CODABLE
//    //https://www.donnywals.com/using-codable-with-core-data-and-nsmanagedobject/
//    enum CodingKeys: String, CodingKey {
//        case author, title, desc, url, imageUrl, external_url, content_text, content_html, summary, image, banner_image, date_published, date_modified, tags, attachments, avatar, next_url, icon, favicon, home_page_url
//    }
//
//    required convenience public init(from decoder: Decoder) throws {
//        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
//              throw DecoderConfigurationError.missingManagedObjectContext
//        }
//        self.init(context: context)
//
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.author = try container.decode(String.self, forKey: .author)
//        self.title = try container.decode(String.self, forKey: .title)
//        self.desc = try container.decode(String.self, forKey: .desc)
//        self.url = try container.decode(String.self, forKey: .url)
//
//        self.external_url = try container.decode(String.self, forKey: .external_url)
//        self.content_text = try container.decode(String.self, forKey: .content_text)
//        self.content_html = try container.decode(String.self, forKey: .content_html)
//        self.summary = try container.decode(String.self, forKey: .summary)
//        self.image = try container.decode(String.self, forKey: .image)
//        self.banner_image = try container.decode(String.self, forKey: .banner_image)
//        self.date_published = try container.decode(Date.self, forKey: .date_published)
//        self.date_modified = try container.decode(Date.self, forKey: .date_modified)
//        self.tags = try container.decode(String.self, forKey: .tags)
//        self.attachments = try container.decode(String.self, forKey: .attachments)
//        self.avatar = try container.decode(String.self, forKey: .avatar)
//        self.next_url = try container.decode(String.self, forKey: .next_url)
//        self.icon = try container.decode(String.self, forKey: .icon)
//        self.favicon = try container.decode(String.self, forKey: .favicon)
//        self.home_page_url = try container.decode(String.self, forKey: .home_page_url)
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(author, forKey: .author)
//        try container.encode(title, forKey: .title)
//        try container.encode(desc, forKey: .desc)
//        try container.encode(url, forKey: .url)
//
//        try container.encode(summary, forKey: .summary)
//        try container.encode(image, forKey: .image)
//        try container.encode(external_url, forKey: .external_url)
//        try container.encode(content_text, forKey: .content_text)
//        try container.encode(content_html, forKey: .content_html)
//        try container.encode(banner_image, forKey: .banner_image)
//        try container.encode(date_published, forKey: .date_published)
//        try container.encode(date_modified, forKey: .date_modified)
//        try container.encode(tags, forKey: .tags)
//        try container.encode(attachments, forKey: .attachments)
//        try container.encode(avatar, forKey: .avatar)
//        try container.encode(next_url, forKey: .next_url)
//        try container.encode(icon, forKey: .icon)
//        try container.encode(favicon, forKey: .favicon)
//        try container.encode(home_page_url, forKey: .home_page_url)
//    }
//}

enum DecoderConfigurationError: Error {
  case missingManagedObjectContext
}

extension CodingUserInfoKey {
  static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}
