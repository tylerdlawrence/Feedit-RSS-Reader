//
//  DefaultFeedsImporter.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 12/4/20.
//

import Foundation
import Account
import RSCore

struct DefaultFeedsImporter {
    
    static func importDefaultFeeds(rss: RSS) {
        _ = Bundle.main.url(forResource: "DefaultFeeds", withExtension: "json")!
        //AccountManager.shared.defaultAccount.importOPML(defaultFeedsURL) { result in }
    }
}
