//
//  RSSListViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import UIKit
import FeedKit
import Foundation
import CoreData

class RSSListViewModel: NSObject, ObservableObject {

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
    
    func fecthResults(start: Int = 0) {
        if start == 0 {
            items.removeAll()
        }
        dataSource.performFetch(RSS.requestObjects())
        if let objects = dataSource.fetchedResult.fetchedObjects {
            items.append(contentsOf: objects)
        }
    }
    
    func delete(at index: Int) {
        let object = items[index]
        dataSource.delete(object, saveContext: true)
        items.remove(at: index)
    }
    
    class FeedsAPIResponse: Codable {
        var status: String
        var articles: [RSSListItem]?
    }
    
    class RSSListItem: Identifiable, Codable {
        var uuid = UUID()
        //var item = String?.self
        let title: String = ""
        let children: [RSS]? = nil
        var author: String?
        //var title: String
        var urlToImage: String?
        var url: String
        var image: String?
    
        enum CodingKeys: String, CodingKey {
            case author, title, urlToImage, url, image
        }
    }
    
    
}

