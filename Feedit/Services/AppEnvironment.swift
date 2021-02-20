//
//  AppEnvironment.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import UIKit
import CoreData
import Foundation

class AppEnvironment: NSObject {
    
    static let prefix = "com.tylerdlawrence.feedit.app.environment"
    
    static let current = AppEnvironment()
    
    @UserDefault(key: "\(prefix).light", default: false)
    var lightMode: Bool

    @UserDefault(key: "\(prefix).dark", default: true)
    var darkMode: Bool
    
    @UserDefault(key: "\(prefix).useSafari", default: true)
    var useSafari: Bool
}
