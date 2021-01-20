//
//  UserDefaultWrapper.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation
import SwiftUI
import UIKit

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    init(key: String, default value: T) {
        self.key = key
        self.defaultValue = value
    }
    
    enum UserInterfaceColorPalette: Int, CustomStringConvertible, CaseIterable {
        case automatic = 0
        case light = 1
        case dark = 2

        var description: String {
            switch self {
            case .automatic:
                return NSLocalizedString("Automatic", comment: "Automatic")
            case .light:
                return NSLocalizedString("Light", comment: "Light")
            case .dark:
                return NSLocalizedString("Dark", comment: "Dark")
            }
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

    
    var wrappedValue: T {
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
    }
}

//https://www.swiftbysundell.com/articles/property-wrappers-in-swift/
private protocol AnyOptional {
    var isNil: Bool { get }
}
extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

@propertyWrapper struct UserDefaultsBacked<Value> {
    let key: String
    let defaultValue: Value
    var storage: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                storage.removeObject(forKey: key)
            } else {
                storage.setValue(newValue, forKey: key)
            }
        }
    }
}

@propertyWrapper final class Flag<Value> {
    
    var projectedValue: Flag { self }

    let name: String
    var wrappedValue: Value

    fileprivate init(name: String, defaultValue: Value) {
        self.name = name
        self.wrappedValue = defaultValue
    }
}

struct FeatureFlags {
    @Flag(name: "feature-search", defaultValue: false)
    var isSearchEnabled: Bool

    @Flag(name: "experiment-note-limit", defaultValue: 999)
    var maximumNumberOfNotes: Int
}

private struct FlagCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init(name: String) {
        stringValue = name
    }
    
    // These initializers are required by the CodingKey protocol:

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }
}

private protocol DecodableFlag {
    typealias Container = KeyedDecodingContainer<FlagCodingKey>
    func decodeValue(from container: Container) throws
}

extension Flag: DecodableFlag where Value: Decodable {
    fileprivate func decodeValue(from container: Container) throws {
        // This enables us to pass an override using a command line
        // argument matching the flag's name:
        if let value = UserDefaults.standard.value(forKey: name) {
            if let matchingValue = value as? Value {
                wrappedValue = matchingValue
                return
            }
        }

        let key = FlagCodingKey(name: name)

        // We only want to attempt to decode a value if it's present,
        // to enable our app to fall back to its default value
        // in case the flag is missing from our backend data:
        if let value = try container.decodeIfPresent(Value.self, forKey: key) {
            wrappedValue = value
        }
    }
}

extension FeatureFlags: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FlagCodingKey.self)

        for child in Mirror(reflecting: self).children {
            guard let flag = child.value as? DecodableFlag else {
                continue
            }

            try flag.decodeValue(from: container)
        }
    }
}
