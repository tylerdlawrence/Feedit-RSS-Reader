//
//  RSSItem.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation
import Combine
import CoreData
import FeedKit

protocol RSSItemConvertable {
    func asRSSItem(container uuid: UUID, in context: NSManagedObjectContext) -> RSSItem
}



extension Array where Element: RSSItemConvertable {
    func asRSSItems(container uuid: UUID, in context: NSManagedObjectContext, condition: ((Element) -> Bool)? = nil) -> [RSSItem] {
         return filter { e -> Bool in
            return condition?(e) ?? true
         }.map { $0.asRSSItem(container: uuid, in: context) }
    }
}

extension RSSFeedItem: RSSItemConvertable {
    func asRSSItem(container uuid: UUID, in context: NSManagedObjectContext) -> RSSItem {
        return RSSItem.create(uuid: uuid, image: "", title: title ?? "",
                              desc: description ?? "",
                              author: author ?? "",
                              url: link ?? "",
                              createTime: pubDate ?? Date(),
                              in: context)
    }
}

extension AtomFeedEntry: RSSItemConvertable {
    func asRSSItem(container uuid: UUID, in context: NSManagedObjectContext) -> RSSItem {
        return RSSItem.create(uuid: uuid, image: "",
                              title: title ?? "",
                              desc: "",
                              author: authors?.first?.name ?? "",
                              url: links?.first?.attributes?.href ?? "",
                              createTime: (published ?? updated) ?? Date(),
                              in: context)
    }
}

extension JSONFeedItem: RSSItemConvertable {
    func asRSSItem(container uuid: UUID, in context: NSManagedObjectContext) -> RSSItem {
        return RSSItem.create(uuid: uuid, image: image!,
                              title: title ?? "",
                              author: author?.name ?? "",
                              url: url ?? "",
                              createTime: datePublished ?? Date(),
                              in: context)
    }
}
