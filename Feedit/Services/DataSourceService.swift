//
//  DataSourceService.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import UIKit
import SwiftUI

class DataSourceService: NSObject {
    
    static let current = DataSourceService()
    
    var rss = RSSDataSource(parentContext: CoreData.stack.context)
    var rssItem = RSSItemDataSource(parentContext: CoreData.stack.context)
}
