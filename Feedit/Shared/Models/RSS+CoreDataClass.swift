//
//  RSS+CoreDataClass.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

//import Foundation
//import CoreData
//import SwiftUI
//import FeedKit
//import FaviconFinder
//import Combine
//import BackgroundTasks
//
//@objc(RSS)
//public class RSS: NSManagedObject, Identifiable {
//
//}

import Foundation
import CoreData
import SwiftUI
import FeedKit
import FaviconFinder
import Combine
import BackgroundTasks

@objc(RSS)
public class RSS: NSManagedObject, Codable {
    
    enum CodingKeys: String, CodingKey {
      case uuid, title, desc, createTime, groups, posts, image
    }
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
              throw DecoderConfigurationError.missingManagedObjectContext
        }
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try container.decode(UUID.self, forKey: .uuid)
        self.title = try container.decode(String.self, forKey: .title)
        self.desc = try container.decode(String.self, forKey: .desc)
        self.createTime = try container.decode(Date.self, forKey: .createTime)
//        self.groups = try container.decode(Set<RSSItem>.self, forKey: .groups) as NSSet
//        self.posts = try container.decode([RSSItem].self, forKey: .posts)
        self.image = try container.decode(String.self, forKey: .image)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(title, forKey: .title)
        try container.encode(desc, forKey: .desc)
        try container.encode(createTime, forKey: .createTime)
//        try container.encode(groups as! Set<RSSItem>, forKey: .groups)
        try container.encode(image, forKey: .image)
    }
    
    var posts = [RSSItem]() {
        didSet {
            objectWillChange.send()
        }
    }
}
