//
//  DeepLinks.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/24/21.
//

import Foundation
import SwiftUI

enum WidgetDeepLink {
    case unread
    case unreadArticle(id: String)
    case today
    case todayArticle(id: String)
    case starred
    case starredArticle(id: String)
    case icon
    
    var url: URL {
        switch self {
        case .unread:
            return URL(string: "feeditrssreader://showunread")!
//            return URL(string: "nnw://showunread")!
        case .unreadArticle(let articleID):
            var url = URLComponents(url: WidgetDeepLink.unread.url, resolvingAgainstBaseURL: false)!
            url.queryItems = [URLQueryItem(name: "id", value: articleID)]
            return url.url!
            
        case .today:
            return URL(string: "feeditrssreader://showtoday")!
//            return URL(string: "nnw://showtoday")!
        case .todayArticle(let articleID):
            var url = URLComponents(url: WidgetDeepLink.today.url, resolvingAgainstBaseURL: false)!
            url.queryItems = [URLQueryItem(name: "id", value: articleID)]
            return url.url!
            
        case .starred:
            return URL(string: "feeditrssreader://showstarred")!
//            return URL(string: "nnw://showstarred")!
        case .starredArticle(let articleID):
            var url = URLComponents(url: WidgetDeepLink.starred.url, resolvingAgainstBaseURL: false)!
            url.queryItems = [URLQueryItem(name: "id", value: articleID)]
            return url.url!
            
        case .icon:
            return URL(string: "feeditrssreader://icon")!
//            return URL(string: "nnw://icon")!
        }
    }
}
