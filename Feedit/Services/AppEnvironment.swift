//
//  AppEnvironment.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation


class AppEnvironment: NSObject {
    
    static let prefix = "com.tylerdlawrence.feedit.app.environment"
    static let current = AppEnvironment()
    
    @UserDefault(key: "\(prefix).light", default: true)
    var lightMode: Bool
    
    @UserDefault(key: "\(prefix).dark", default: false)
    var darkMode: Bool
    
    @UserDefault(key: "\(prefix).useSafari", default: true)
    var useSafari: Bool
    
}
