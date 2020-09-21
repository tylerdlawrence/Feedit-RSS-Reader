//
//  AppEnvironment.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation


class AppEnvironment: NSObject {
    
    static let prefix = //"com.acumen.rss.app.environment"
        "com.tylerdlawrence.feedit.app.environment"
    static let current = AppEnvironment()
    
    @UserDefault(key: "\(prefix).useSafari", default: true)
    var useSafari: Bool
}
