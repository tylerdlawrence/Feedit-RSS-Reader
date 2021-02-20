//
//  Extensions.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 1/18/21.
//

import Foundation
import SwiftUI

extension UserDefaults {
//    static var items: [RSSItem] {
//        get {
//            guard let data = UserDefaults(suiteName: "group.feedit.tylerdlawrence")?.value(forKey: "feeds") as? Data else {
//                return []
//            }
//            return (try? JSONDecoder().decode([RSSItem].self, from: data)) ?? []
//        }
//        set {
//            let data = try? JSONEncoder().encode(newValue)
//            UserDefaults(suiteName: "group.feedit.tylerdlawrence")?.set(data, forKey: "feeds")
//        }
//    }
    
    static var fetchContentTime: ContentTimeType {
        get {
            guard let contentString = UserDefaults(suiteName: "group.feedit.tylerdlawrence")?.value(forKey: "fetchContentTime") as? String else {
                return .minute60
            }
            return ContentTimeType(rawValue: contentString) ?? .minute60
        }
        set {
            UserDefaults(suiteName: "group.siligg")?.set(newValue.rawValue, forKey: "fetchContentTime")
        }
    }
    
    static var newFeedsToAdd: [URL] {
        get {
            guard let feeds = UserDefaults(suiteName: "group.feedit.tylerdlawrence")?.value(forKey: "newFeedsToAdd") as? [String] else {
                return []
            }
            return feeds.compactMap { URL(string: $0) }
        }
        set {
            UserDefaults(suiteName: "group.feedit.tylerdlawrence")?.set(newValue.map { $0.absoluteString }, forKey: "newFeedsToAdd")
        }
    }
    
    static var newItemsToAdd: [URL] {
        get {
            guard let feeds = UserDefaults(suiteName: "group.feedit.tylerdlawrence")?.value(forKey: "newItemsToAdd") as? [String] else {
                return []
            }
            return feeds.compactMap { URL(string: $0) }
        }
        set {
            UserDefaults(suiteName: "group.feedit.tylerdlawrence")?.set(newValue.map { $0.absoluteString }, forKey: "newItemsToAdd")
        }
    }

//    static var showOnboarding: Bool {
//        get {
//            return (UserDefaults(suiteName: "group.feedit.tylerdlawrence")?.value(forKey: "showOnboarding") as? Bool) ?? true
//        }
//        set {
//            UserDefaults(suiteName: "group.feedit.tylerdlawrence")?.set(newValue, forKey: "showOnboarding")
//        }
//    }
    
    static var notificationsEnabled: Bool {
        get {
            return (UserDefaults(suiteName: "group.feedit.tylerdlawrence")?.value(forKey: "notificationsEnabled") as? Bool) ?? false
        }
        set {
            UserDefaults(suiteName: "group.feedit.tylerdlawrence")?.set(newValue, forKey: "notificationsEnabled")
        }
    }


}
