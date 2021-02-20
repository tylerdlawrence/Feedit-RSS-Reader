//
//  RSSListViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import Foundation
import Combine

class RSSListViewModel: NSObject, ObservableObject{
    @ObservedObject var store = RSSStore.instance
    @EnvironmentObject var viewModel: RSSListViewModel
    @Environment(\.managedObjectContext) var managedObjectContext

    @Published var items: [RSS] = []
    @State var title = ""

    let dataSource: RSSDataSource
    var start = 0
    var cancellables = Set<AnyCancellable>()

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

    private func delete(rss: RSS) {
        if let index = self.viewModel.items.firstIndex(where: { $0.id == rss.id }) {
            viewModel.items.remove(at: index)
        }
    }

    func delete(at index: Int) {
        let object = items[index]
        dataSource.delete(object, saveContext: true)
        items.remove(at: index)
    }

    private func deleteItem() {
        for id in viewModel.items {
            if let index = viewModel.items.lastIndex(where: { $0 == id })  {
                viewModel.items.remove(at: index)
            }
        }
        self.viewModel.items = [RSS]()
        //selection = items
    }

    var isRead: Bool {
        return readDate != nil
    }
    var readDate: Date? {
        didSet {
            objectWillChange.send()
        }
    }
}
//import SwiftUI
//import UIKit
//import CoreData
//import Foundation
//import Combine
//import SwiftSoup
//
//class RSSListViewModel: NSObject, ObservableObject{
//    @ObservedObject var store = RSSStore.instance
//    @EnvironmentObject var dataModel: DataNStorageViewModel
//    @EnvironmentObject var viewModel: RSSListViewModel
//    @Environment(\.managedObjectContext) var managedObjectContext
//
//    @Published var rssCount: Int = 0
//    @Published var rssItemCount: Int = 0
//    let rssDataSource: RSSDataSource
//    let rssItemDataSource: RSSItemDataSource
//
//    @Published var items: [RSS] = []
//    @Published var feeds: [FeedObject] = []
//    @State var title = ""
//
//    let dataSource: RSSDataSource
//    var start = 0
//    var cancellables = Set<AnyCancellable>()
//
//    @Published var showNewFeedPopup = false
//    @Published var shouldSelectFeed = false
//    @Published var shouldSelectFeedObject: FeedObject?
//    @Published var shouldOpenSettings = false
//    @Published var feedURL: String = ""
//    @Published var feedAddColor: Color = Color("Color")
//    @Published var attempts: Int = 0
//    @Published var shouldPresentDetail = false
//    @Published var totalPostsReadToday: Int = 0
//    @Published var totalPostsUnread: Int = 0
//    @Published var showModal = false
//    @Published var revealSmartFilters = false
//    @Published var revealDetails = false
//    @Published var showFilter = false
//
//    private var itemsCountLabel: UILabel = UILabel()
//    private var dot: UIView = UIView()
//
//    init(dataSource: RSSDataSource, rss: RSSDataSource, rssItem: RSSItemDataSource) {
//        self.dataSource = dataSource
//        rssDataSource = rss
//        rssItemDataSource = rssItem
//        super.init()
//    }
//
//    func loadMore() {
//        start = items.count
//        fetchResults()
////        fetchResults(start: totalPostsUnread)
//    }
//
//    func fetchResults() {//(start: Int = 0) {
//        if start == 0 {
//            items.removeAll()
//        }
//        dataSource.performFetch(RSS.requestObjects())
//        if let objects = dataSource.fetchedResult.fetchedObjects {
//            items.append(contentsOf: objects)
//        }
//    }
//
//    var itemsCountText: String? {
//        didSet {
//            itemsCountLabel.text = itemsCountText
//            //setNeedsLayout()
//            dot.removeFromSuperview()
//        }
//    }
//
//    var wasReadCell: Bool = false {
//        didSet {
//            if wasReadCell {
//                dot.removeFromSuperview()
//            }
//            else {
//            //
//            }
//        }
//    }
//
//    func addFeed(url: String) {
//        guard URL(string: url) != nil else {
//            self.attempts += 1
//            self.feedAddColor = Color.blue
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.feedAddColor = Color("lightShadow")
//            }
//            return
//        }
//    }
//
//    func getRSSCount() {
//        rssCount = rssDataSource.performFetchCount(RSS.requestDefaultObjects())
//        print("getRSSCount = \(rssCount)")
//    }
//
//    func getRSSItemCount() {
//        rssItemCount = rssItemDataSource.performFetchCount(RSSItem.requestDefaultObjects())
//        print("getRSSItemCount = \(rssItemCount)")
//    }
//
//    private func delete(rss: RSS) {
//        if let index = self.viewModel.items.firstIndex(where: { $0.id == rss.id }) {
//            viewModel.items.remove(at: index)
//        }
//    }
//
//    func delete(at index: Int) {
//        let object = items[index]
//        dataSource.delete(object, saveContext: true)
//        items.remove(at: index)
//    }
//}
