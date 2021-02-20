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

    final class AppDefaults {

        //static
        let shared = AppDefaults()
        private init() {}

    //static
        var store: UserDefaults = {
            let appIdentifierPrefix = Bundle.main.object(forInfoDictionaryKey: "AppIdentifierPrefix") as! String
            let suiteName = "\(appIdentifierPrefix)group.\(Bundle.main.bundleIdentifier!)"
            return UserDefaults.init(suiteName: suiteName)!
        }()
    }
}

public extension Notification.Name {
    static let UnreadCountDidInitialize = Notification.Name("UnreadCountDidInitialize")
    static let UnreadCountDidChange = Notification.Name(rawValue: "UnreadCountDidChange")
}

public protocol UnreadCountProvider {

    var unreadCount: Int { get }

    func postUnreadCountDidChangeNotification()
    func calculateUnreadCount<T: Collection>(_ children: T) -> Int
}


public extension UnreadCountProvider {
    
    func postUnreadCountDidInitializeNotification() {
        NotificationCenter.default.post(name: .UnreadCountDidInitialize, object: self, userInfo: nil)
    }

    func postUnreadCountDidChangeNotification() {
        NotificationCenter.default.post(name: .UnreadCountDidChange, object: self, userInfo: nil)
    }

    func calculateUnreadCount<T: Collection>(_ children: T) -> Int {
        let updatedUnreadCount = children.reduce(0) { (result, oneChild) -> Int in
            if let oneUnreadCountProvider = oneChild as? UnreadCountProvider {
                return result + oneUnreadCountProvider.unreadCount
            }
            return result
        }

        return updatedUnreadCount
    }
}

// MARK: - Non Optional Value

@propertyWrapper
struct UserDefaultsValue<T> {
    
    let key: String
    
    let defaultValue: T
    
    var wrappedValue: T {
        set { UserDefaults.standard.set(newValue, forKey: key) }
        get { UserDefaults.standard.value(forKey: key) as? T ?? defaultValue }
    }
    
    
    init(forKey key: String, default value: T) {
        self.key = key
        self.defaultValue = value
    }
}


// MARK: - Optional Value

@propertyWrapper
struct UserDefaultsOptionalValue<T> {
    
    let key: String
    
    let defaultValue: T?
    
    var wrappedValue: T? {
        set { UserDefaults.standard.set(newValue, forKey: key) }
        get { UserDefaults.standard.value(forKey: key) as? T}
    }
    
    
    init(forKey key: String, default value: T?) {
        self.key = key
        self.defaultValue = value
    }
}
