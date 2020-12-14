//
//  DataNStorageViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/15/20.
//

import SwiftUI
import UIKit
import WidgetKit

class DataNStorageViewModel: NSObject, ObservableObject {
    
    let rssDataSource: RSSDataSource
    let rssItemDataSource: RSSItemDataSource
    
    @Published var rssCount: Int = 0
    @Published var rssItemCount: Int = 0
 
    init(rss: RSSDataSource, rssItem: RSSItemDataSource) {
        rssDataSource = rss
        rssItemDataSource = rssItem
        super.init()
    }
    
    func getRSSCount() {
        rssCount = rssDataSource.performFetchCount(RSS.requestDefaultObjects())
        print("getRSSCount = \(rssCount)")
    }
    
//    func getRSSItemCount() {
//        rssItemCount = rssItemDataSource.performFetchCount(RSSItem.requestDefaultObjects())
//        print("getRSSItemCount = \(rssItemCount)")
//    }
}
