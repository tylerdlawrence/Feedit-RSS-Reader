//
//  UserDefaultWrapper.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation
import Combine


@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    init(key: String, default value: T) {
        self.key = key
        self.defaultValue = value
    }
    
    var wrappedValue: T {
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
    }
}

extension UserDefaults {
    static let appGroup = UserDefaults(suiteName: "group.com.tylerdlawrence.feedit.shared")!
}

extension UserDefaults {
    static var feeds: [RSS] {
        get {
            guard let data = UserDefaults(suiteName: "group.update.lucasfarah")?.value(forKey: "feeds") as? Data else {
                return []
            }
            return (try? JSONDecoder().decode([RSS].self, from: data)) ?? []
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults(suiteName: "group.update.lucasfarah")?.set(data, forKey: "feeds")
        }
    }
    
    static var fetchContentTime: ContentTimeType {
        get {
            guard let contentString = UserDefaults(suiteName: "group.update.lucasfarah")?.value(forKey: "fetchContentTime") as? String else {
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
            guard let feeds = UserDefaults(suiteName: "group.update.lucasfarah")?.value(forKey: "newFeedsToAdd") as? [String] else {
                return []
            }
            return feeds.compactMap { URL(string: $0) }
        }
        set {
            UserDefaults(suiteName: "group.update.lucasfarah")?.set(newValue.map { $0.absoluteString }, forKey: "newFeedsToAdd")
        }
    }
    
    static var newItemsToAdd: [URL] {
        get {
            guard let feeds = UserDefaults(suiteName: "group.update.lucasfarah")?.value(forKey: "newItemsToAdd") as? [String] else {
                return []
            }
            return feeds.compactMap { URL(string: $0) }
        }
        set {
            UserDefaults(suiteName: "group.update.lucasfarah")?.set(newValue.map { $0.absoluteString }, forKey: "newItemsToAdd")
        }
    }

    
    static var showOnboarding: Bool {
        get {
            return (UserDefaults(suiteName: "group.update.lucasfarah")?.value(forKey: "showOnboarding") as? Bool) ?? true
        }
        set {
            UserDefaults(suiteName: "group.update.lucasfarah")?.set(newValue, forKey: "showOnboarding")
        }
    }
    
    static var notificationsEnabled: Bool {
        get {
            return (UserDefaults(suiteName: "group.update.lucasfarah")?.value(forKey: "notificationsEnabled") as? Bool) ?? false
        }
        set {
            UserDefaults(suiteName: "group.update.lucasfarah")?.set(newValue, forKey: "notificationsEnabled")
        }
    }


}
