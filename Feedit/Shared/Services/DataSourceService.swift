//
//  DataSourceService.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import UIKit
import SwiftUI
import Combine
import CoreData
import Intents

class DataSourceService: NSObject {
    
    static let current = DataSourceService()
    
    var rss = RSSDataSource(parentContext: Persistence.current.context)
    var rssItem = RSSItemDataSource(parentContext: Persistence.current.context)
    

}
