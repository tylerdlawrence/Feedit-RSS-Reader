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
        return RSSItem.create(uuid: uuid,
                              title: title ?? "",
                              desc: (description?.trimWhiteAndSpace.trimHTMLTag ?? content?.contentEncoded) ?? "",
                              author: author?.first?.description ?? "",
                              url: (link ?? link?.urlParts.host) ?? "",
                              createTime: pubDate ?? Date(),
                              image: (source?.attributes?.url ?? source?.value?.decodedURLString ?? media?.mediaThumbnails?.first?.value) ?? "",
                              in: context)
    }
}

extension AtomFeedEntry: RSSItemConvertable {
    func asRSSItem(container uuid: UUID, in context: NSManagedObjectContext) -> RSSItem {
        return RSSItem.create(uuid: uuid,
                              title: title ?? "",
                              desc: summary?.value ?? "",
                              author: authors?.first?.name ?? "",
                              url: links?.first?.attributes?.href ?? "",
                              createTime: (published ?? updated) ?? Date(),
                              image: (media?.mediaThumbnails?.first?.value ?? source?.title?.tagsStripped) ?? "",
                              in: context)
    }
}

extension JSONFeedItem: RSSItemConvertable {
    func asRSSItem(container uuid: UUID, in context: NSManagedObjectContext) -> RSSItem {
        return RSSItem.create(uuid: uuid,
                              title: title ?? "",
                              desc: (contentHtml ?? summary?.trimHTMLTag ?? contentText?.escapedHTML.tagsStripped ?? contentHtml ?? contentHtml?.escapedHTML.tagsStripped) ?? "",
                              author: author?.name ?? "",
                              url: (url?.decodedURLString ?? id?.decodedURLString) ?? "",
                              createTime: datePublished ?? Date(),
                              image: image?.isImage().string ?? "",
//                              image: (image ?? contentHtml ?? contentText ?? image?.decodedURLString?.tagsStripped.trimHTMLTag) ?? "",
                              in: context)
    }
}
