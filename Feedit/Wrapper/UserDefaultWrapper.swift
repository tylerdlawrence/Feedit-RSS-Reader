//
//  UserDefaultWrapper.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation
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
