//
//  DefaultFeeds.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 12/5/20.
//

import Foundation
import SwiftUI
import Combine
import FeedKit
import UIKit
import KingfisherSwiftUI
import Foundation
import RSCore

struct DefaultFeeds: Codable, Identifiable {
    let id: String
    let desc: String
    let htmlUrl: String
    let xmlUrl: String
    
    var displayName: String {
        "\(id)"
    }
    
    var description: String {
        "\(desc)"
    }
    
    var xml: String {
        "\(xmlUrl)"
    }
}

struct DefaultFeedsListView: View {
    
    let defaultFeeds: [DefaultFeeds] = Bundle.main.decode("DefaultFeeds.json")
   
    @State var sources: [DefaultFeeds] = []

    var body: some View {
        List(defaultFeeds) { defaultFeeds in
            NavigationLink(destination: AnyView(_fromValue: DefaultFeedsListView.self)) {
                Section(header: Text(defaultFeeds.displayName)) {
                }
            }
            .navigationTitle("Default Feeds")
        }
    }
}

struct DefaultFeedsListView_Previews: PreviewProvider {
    
    static let defaultFeeds: [DefaultFeeds] = Bundle.main.decode("DefaultFeeds.json")
    
    @State var sources: [DefaultFeeds] = []

    static var previews: some View {
        DefaultFeedsListView(sources: defaultFeeds)
    }
}

//import Foundation
//import SwiftUI
//import Combine
//import FeedKit
//import UIKit
//import KingfisherSwiftUI
//import Foundation
//import RSCore
//
//struct DefaultFeeds: Codable, Identifiable {
//    let id: String
//    let desc: String
//    let htmlUrl: String
//    let xmlUrl: String
//
//    var displayName: String {
//        "\(id)"
//    }
//
//    var description: String {
//        "\(desc)"
//    }
//
//    var xml: String {
//        "\(xmlUrl)"
//    }
//}
//
//struct DefaultFeedsListView: View {
//
//    @ObservedObject var viewModel: RSSListViewModel
//    @ObservedObject var rss: RSS
//
//    let defaultFeeds: [DefaultFeeds] = Bundle.main.decode("DefaultFeeds.json")
//
//    @State var sources: [DefaultFeeds] = []
//
//    var body: some View {
//        List(defaultFeeds) { defaultFeeds in
//            NavigationLink(destination: AnyView(_fromValue: DefaultFeedsListView.self)) {
//                Section(header: Text(defaultFeeds.displayName)) {
//                    RSSRow(rss: rss)
//                }
//            }
//            .navigationTitle("Default Feeds")
//        }
//    }
//}
//extension DefaultFeedsListView {
//
//    func onDoneAction() {
//        self.viewModel.fecthResults()
//    }
//
//    private func destinationView(_ rss: RSS) -> some View {
//        RSSFeedListView(viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
//            .environmentObject(DataSourceService.current.rss)
//    }
//
//}
//
////struct DefaultFeedsListView_Previews: PreviewProvider {
////
////    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
////
////    static let defaultFeeds: [DefaultFeeds] = Bundle.main.decode("DefaultFeeds.json")
////
////    @State var sources: [DefaultFeeds] = []
////
////    static var previews: some View {
////        DefaultFeedsListView(viewModel: RSSListViewModel, rss: RSS)
////            //viewModel: self.viewModel, rss: RSS, sources: defaultFeeds)
////    }
////}
