//
//  RSSListViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import UIKit

class RSSListViewModel: NSObject, ObservableObject{
    
    @Published var items: [RSS] = []
    let dataSource: RSSDataSource
    var start = 0
    
    init(dataSource: RSSDataSource) {
        self.dataSource = dataSource
        super.init()
    }
    
    func loadMore() {
        start = items.count
        fecthResults(start: start)
    }
    
//    func fecthResults(start: Int = 0) {
//        if start == 0 {
//            items.removeAll()
//        }
//        dataSource.performFetch(RSS.requestObjects())
//        if let objects = dataSource.fetchedResult.fetchedObjects {
//            items.append(contentsOf: objects)
//        }
//    }
    func fecthResults(start: Int = 0) {
        if start == 0 {
            items.removeAll()
        }
        dataSource.performFetch(RSS.requestObjects())//rssUUID: rss.uuid!, start: start
        if let objects = dataSource.fetchedResult.fetchedObjects {
            items.append(contentsOf: objects)
        }
    }
    
    func delete(at index: Int) {
        let object = items[index]
        dataSource.delete(object, saveContext: true)
        items.remove(at: index)
    }
    
    func move(at index: Int) {
        let object = items[index]
        dataSource.move(object, saveContext: true)
        items.move(fromOffsets: [index], toOffset: index)
    }

    
    class FeedsAPIResponse: Codable {
        var status: String
        var items: [RSSListItem]?
    }
    
    class RSSListItem: Identifiable, Codable {
        var uuid = UUID()
        let title: String = ""
        let children: [RSS]? = nil
        var rss: String = ""
        var imageURL: String?
        var url: String = ""
    
        enum CodingKeys: String, CodingKey {
            case title, url, imageURL
        }
    }
    struct DefaultFeeds: Codable, Identifiable {
        let id: String
        let desc: String
        let htmlUrl: String
        let xmlUrl: String
        
        var displayName: String {
            "\(id)"
        }
    }
}

