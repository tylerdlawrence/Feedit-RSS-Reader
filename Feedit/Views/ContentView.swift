//
//  HomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import UIKit
import SwiftUI
import FeedKit
import SwipeCell
    
struct ContentView: View {
    
    @State private var archiveScale: Image.Scale = .small

    private var homeListView: some View {

        RSSListView(viewModel: RSSListViewModel(dataSource: DataSourceService.current.rss))

      }

      private var settingListView: some View {
            SettingListView()

      }

      private var archiveListView: some View {
            ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))

      }

      var body: some View {

          TabView {
              homeListView
                  .tabItem {
                      VStack() {
                          Image(systemName:"square.3.stack.3d")
                              .imageScale(.small)
                          Text("")
                      }
                  }

              archiveListView
                  .tabItem {
                      VStack {
                          Image(systemName: "bookmark")
                              .imageScale(.small)
                          Text("")

                      }
                  }

              settingListView
                  .tabItem {
                    VStack(){
                          Image(systemName: "switch.2")
                              .imageScale(.small)
                          Text("")
                        }
                    }
                }
            }
    
struct RSSList: View {

    @State private var showContent = false
    
    var body: some View {
            List {
                
            }
            .listStyle(SidebarListStyle())
        }
    }


#if DEBUG

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
        .preferredColorScheme(.dark)
          .previewDevice("iPhone 12")
    

  }
}

#endif

    
    //struct Tree<Value: Hashable>: Hashable {
    //    let value: Value
    //    var children: [Tree]? = nil
    //}
    //
    //let categories: [Tree<String>] = [
    //    .init(
    //        value: "Today",
    //        children: [
    //            .init(value: "Hoodies"),
    //            .init(value: "Jackets"),
    //            .init(value: "Joggers"),
    //            .init(value: "Jumpers"),
    //            .init(
    //                value: "Jeans",
    //                children: [
    //                    .init(value: "Regular"),
    //                    .init(value: "Slim")
    //                ]
    //            ),
    //        ]
    //    ),
    //    .init(
    //        value: "Unread",
    //        children: [
    //            .init(value: "Boots"),
    //            .init(value: "Sliders"),
    //            .init(value: "Sandals"),
    //            .init(value: "Trainers"),
    //        ]
    //    ),
    //    .init(
    //        value: "Bookmarked",
    //        children: [
    //            .init(value: "Boots"),
    //            .init(value: "Sliders"),
    //            .init(value: "Sandals"),
    //            .init(value: "Trainers"),
    //            ]
    //        ),
    //    ]
    
    //struct RSSListItem: Identifiable {
    //    let id = UUID()
    //    let text: String
    //    let title: String
    //    let description: String
    //    let htmlURL: String
    //    let xmlURL: String
    //    var items: [RSSListItem]?
    //
    //}
    //extension RSSListView {
        //json file
    //}
//            {
//                "_text": "36氪",
//                "_title": "36氪",
//                "_description": "",
//                "_htmlUrl": "http://36kr.com/",
//                "_xmlUrl": "http://36kr.com/feed"
//            },
//            {
//                "_text": "Accidentally in Code",
//                "_title": "Accidentally in Code",
//                "_description": "",
//                "_htmlUrl": "",
//                "_xmlUrl": "https://cate.blog/feed/"
//            },
//            {
//                "_text": "Becky Hansmeyer",
//                "_title": "Becky Hansmeyer",
//                "_description": "",
//                "_htmlUrl": "",
//                "_xmlUrl": "https://beckyhansmeyer.com/feed/"
//            },
//            {
//                "_text": "Craig Hockenberry",
//                "_title": "Craig Hockenberry",
//                "_description": "",
//                "_htmlUrl": "",
//                "_xmlUrl": "https://furbo.org/feed/json"
//            },
//            {
//                "_text": "Daring Fireball",
//                "_title": "Daring Fireball",
//                "_description": "",
//                "_htmlUrl": "",
//                "_xmlUrl": "https://daringfireball.net/feeds/json"
//            },
//            {
//                "_text": "Erica Sadun",
//                "_title": "Erica Sadun",
//                "_description": "",
//                "_htmlUrl": "",
//                "_xmlUrl": "https://ericasadun.com/feed/"
//            },
//            {
//                "_text": "inessential",
//                "_title": "inessential",
//                "_description": "",
//                "_htmlUrl": "",
//                "_xmlUrl": "https://inessential.com/feed.json"
//            },
//            {
//                "_text": "Jason Kottke",
//                "_title": "Jason Kottke",
//                "_description": "",
//                "_htmlUrl": "",
//                "_xmlUrl": "http://feeds.kottke.org/json"
//            },
//            {
//                "_text": "Julia Evans",
//                "_title": "Julia Evans",
//                "_description": "",
//                "_htmlUrl": "",
//                "_xmlUrl": "https://jvns.ca/atom.xml"
//            },
//            {
//                "_text": "Loop Insight",
//                "_title": "Loop Insight",
//                "_description": "",
//                "_htmlUrl": "",
//                "_xmlUrl": "https://www.loopinsight.com/feed/"
//            },
//            {
//                "_text": "Manton Reece",
//                "_title": "Manton Reece",
//                "_description": "",
//                "_htmlUrl": "",
//                "_xmlUrl": "https://www.manton.org/feed/json"
//            },
//            {
//                "_text": "Michael Tsai",
//                "_title": "Michael Tsai",
//                "_description": "",
//                "_htmlUrl": "",
//                "_xmlUrl": "https://mjtsai.com/blog/feed/"
//            },
//            {
//                "_text": "NetNewsWire Blog",
//                "_title": "NetNewsWire Blog",
//                "_description": "",
//                "_htmlUrl": "",
//                "_xmlUrl": "https://nnw.ranchero.com/feed.json"
//            },
//            {
//                "_text": "One Foot Tsunami",
//                "_title": "One Foot Tsunami",
//                "_description": "",
//                "_htmlUrl": "",
//                "_xmlUrl": "https://onefoottsunami.com/feed/json/"
//            },
//            {
//                "_text": "Rose Orchard",
//                "_title": "Rose Orchard",
//                "_description": "",
//                "_htmlUrl": "",
//                "_xmlUrl": "https://rosemaryorchard.com/blog/feed/"
//            },
//            {
//                "_text": "Six Colors",
//                "_title": "Six Colors",
//                "_description": "",
//                "_htmlUrl": "",
//                "_xmlUrl": "https://sixcolors.com/feed.json"
//            },
//            {
//                "_text": "The Shape of Everything",
//                "_title": "The Shape of Everything",
//                "_description": "",
//                "_htmlUrl": "",
//                "_xmlUrl": "https://shapeof.com/feed.json"
//            }
//

}
