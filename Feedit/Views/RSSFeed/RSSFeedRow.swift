//
//  RSSItemRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import URLImage
import Foundation
import MobileCoreServices
import KingfisherSwiftUI
import class Kingfisher.ImageCache
import class Kingfisher.KingfisherManager
import UIKit
import Combine
import CoreData
import SwipeCell
import FeedKit
import SDWebImageSwiftUI
import Intents
import WidgetKit

struct RSSItemRow: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var rssDataSource: RSSDataSource
    let persistence = Persistence.current
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    
    @ObservedObject var rssItem: RSSItem
    
    @State private var selectedItem: RSSItem?
    var contextMenuAction: ((RSSItem) -> Void)?
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @ObservedObject var rss = RSS()
    
    @State private var hideRemove = false
    @State private var hideKeep = false
                
    init(rssItem: RSSItem, menu action: ((RSSItem) -> Void)? = nil, rssFeedViewModel: RSSFeedViewModel) {
        self.rssItem = rssItem
        contextMenuAction = action
        self.rssFeedViewModel = rssFeedViewModel
        
    }
    
    //var articleImage = RSSFeedImage().url//?.isImage()
    //var data = ArticleItem(from: RSSItem())
    
    let options = URLImageOptions(identifier: "imageUrl")
    @State private var sample: SampleURLs = .midRes50
    var body: some View {
        let toggleStarred = SwipeCellButton(buttonStyle: .view, title: "", systemImage: "", view: {
                AnyView(
                    Group {
                        if rssItem.isArchive {
                            Image(systemName: "star")
                                .foregroundColor(Color("bg")).imageScale(.small)
                        } else {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color("bg")).imageScale(.small)
                        }
                    }
                )
            }, backgroundColor: Color("accent"), action: {
                self.contextMenuAction?(self.rssItem) }, feedback: false)
        
        let toggleRead = SwipeCellButton(
            buttonStyle: .view, title: "", systemImage: "", view: {
                AnyView(
                    Group {
                        if rssItem.isRead {
                            Image(systemName: "largecircle.fill.circle")
                                .foregroundColor(Color("bg")).imageScale(.small)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(Color("bg")).imageScale(.small)
                        }
                    }
                )
            }, backgroundColor: Color("accent"), action: {
                rssItem.progress = 1
                rssItem.isRead.toggle() }, feedback: false)

        let star = SwipeCellSlot(slots: [toggleStarred], slotStyle: .destructive, buttonWidth: 60)
        let read = SwipeCellSlot(slots: [toggleRead], slotStyle: .destructive, buttonWidth: 60)
        
        //let urls = URL(string: "")
                
        ZStack {
            VStack {
                HStack(alignment: .top, spacing: 4) {
                    VStack(alignment: .center, spacing: 4) {
                        if !rssItem.isRead {
                            Text("")
                                .frame(width: 10, height: 10).background(Color.blue).opacity(rssItem.isRead ? 0 : 1).clipShape(Circle())
                        } else {
                            Text("")
                                .frame(width: 10, height: 10).background(Color.blue).opacity(0).clipShape(Circle())
                        }
                        
//                        if let imageUrl = rssItem.image,
//                           let url = URL(string: imageUrl)! {
//                                URLImage(url: url,
//                                         options: URLImageOptions(
//                                            identifier: rssItem.image,
//                                            cachePolicy: .returnCacheElseLoad(cacheDelay: nil, downloadDelay: nil)
//                                         ),
//                                         failure: { error, _ in
//                                            Image("getInfo")
//                                                .resizable()
//                                                .aspectRatio(contentMode: .fit)
//                                                .clipped()
//                                            //ProgressView()
//                                         },
//                                         content: { image in
//                                            image
//                                                .resizable()
//                                                .aspectRatio(contentMode: .fill)
//                                    }).frame(width: 22, height: 22).cornerRadius(3)
//                            }
                    }
                    
                    HStack{
                        VStack(alignment: .leading){
                            HStack {
                                Text("\(rssItem.createTime?.string() ?? "")")
                                    .textCase(.uppercase).font(.system(size: 11, weight: .medium, design: .rounded)).foregroundColor(.gray)
                                
                                if rssItem.isArchive {
                                    Image(systemName: "star.fill").font(.system(size: 8, design: .rounded)).foregroundColor(Color.gray).frame(width: 8, height: 8).opacity(0.8)
                                } else {
                                    Image(systemName: "star.fill").font(.system(size: 8, design: .rounded)).foregroundColor(Color.gray).opacity(rssItem.isArchive ? 1 : 0).frame(width: 8, height: 8)
                                }
                                Spacer()
                            }
                            
                            if rssItem.progress >= 1.0 {
                                Text(rssItem.title)
                                    .font(.system(size: 17, weight: .medium, design: .rounded)).foregroundColor(Color("text")).opacity(0.6).lineLimit(3)
                            } else if rssItem.progress > 0 {
                                Text(rssItem.title)
                                    .font(.system(size: 17, weight: .medium, design: .rounded)).foregroundColor(Color("text")).opacity(0.6).lineLimit(3)
                            } else {
                                Text(rssItem.title)
                                    .font(.system(size: 17, weight: .medium, design: .rounded)).foregroundColor(Color("text")).opacity(rssItem.isRead ? 0.6 : 1).lineLimit(3)
                            }
                            
                            Text(rssItem.desc.tagsStripped.trimHTMLTag.decodedURLString?.trimWhiteAndSpace ?? "")
                                .font(.system(size: 15, weight: .medium, design: .rounded)).foregroundColor(Color.gray).lineLimit(1)
                            
                            Text(rssItem.url).font(.system(size: 11, weight: .medium, design: .rounded)).textCase(.uppercase).foregroundColor(.gray)
                                .lineLimit(1)
                        }
                        URLImage(url: URL(string: rssItem.url) ?? URL(string: "https://picsum.photos/60")!,
//                        URLImage(url: URL(string: rssItem.url ?? "https://picsum.photos/60")!,
                                 options: options) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipped()
                                .cornerRadius(3)
                                .frame(width: 60, height: 60)
                        }
                        
//                        URLImage(url: URL(string: rssItem.url) ?? URL(string: "https://picsum.photos/60")!,
//                                 options: options) { image in
//                            image
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .clipped()
//                                .cornerRadius(3)
//                                .frame(width: 60, height: 60)
//                        }
                    }
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
            .swipeCell(cellPosition: .both, leftSlot: read, rightSlot: star)
            .contextMenu {
                Section{
                    Link(destination: URL(string: rssItem.url)!, label: {
                        HStack {
                            Text("Open Article")
                            Image(systemName: "doc.richtext")
                        }
                    })
                    
                    Divider()
                    
                    ActionContextMenu(
                        label: rssItem.progress > 0 ? "Mark As Unread" : "Mark As Read",
                        systemName: "circle\(rssItem.progress > 0 ? ".fill" : "")",
                        onAction: {
                            rssItem.progress = 1
                        })
                    ActionContextMenu(
                        label: rssItem.isArchive ? "Unstar" : "Star",
                        systemName: "star\(rssItem.isArchive ? ".fill" : "")",
                        onAction: {
                            self.contextMenuAction?(self.rssItem)
                        })
                    
                    ActionContextMenu(
                        label: "Hide Article",
                        systemName: "eye.slash",
                        onAction: {
                            self.hideRemove.toggle()
                        })
                    
                    Divider()
                    
                    Button(action: {
                        UIPasteboard.general.setValue(rssItem.url,
                                                      forPasteboardType: kUTTypePlainText as String)
                    }) {
                        Text("Copy Article Link")
                        Image(systemName: "link")
                    }
                    
                    Button(action: actionSheet) {
                        Text("Share Article")
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    func actionSheet() {
        guard let urlShare = URL(string: rssItem.url) else { return }
        let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
        UIApplication.init().windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}

#if DEBUG
struct RSSFeedRow_Previews: PreviewProvider {
    static var previews: some View {
        RSSItemRow(rssItem: RSSItem.create(uuid: UUID(), title: "Benefits of NetNewsWire's Threading Model", desc: "In my previous post I describe how NetNewsWire handles threading, and I touch on some of the benefits — but I want to be more explicit about them.", author: "Brent Simmons", url: "https://inessential.com/feed.json", createTime: Date(), in: Persistence.previews.context), rssFeedViewModel: RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem))
            .previewLayout(.fixed(width: 400, height: 100))
            .preferredColorScheme(.dark)
    }
}
#endif

enum SampleURLs: Int, CaseIterable, Identifiable {

    /// 50 images ~500px wide
    case midRes50

    /// 50 images ~1000px wide
    case highRes50

    /// 50 images ~2500px wide
    case higherRes50

    /// 1000 images starting from 500px wide
    case largeSet

    var id: Int {
        rawValue
    }

    var urls: [URL] {
        switch self {
            case .midRes50:
                return SampleURLs.picsum(range: 500..<550)
            case .highRes50:
                return SampleURLs.picsum(range: 1000..<1050)
            case .higherRes50:
                return SampleURLs.picsum(range: 2500..<2550)
            case .largeSet:
                return SampleURLs.picsum(range: 500..<500 + 1000)
        }
    }

    static func picsum(range: Range<Int>) -> [URL] {
        range.map { URL(string: "https://picsum.photos/\($0)")! }
    }
}
