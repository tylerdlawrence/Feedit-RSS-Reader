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
    
    var rssSource: RSS? {
        return self.rssFeedViewModel.rss
    }
    
    let rss = RSS()
    
    @State private var hideRemove = false
    @State private var hideKeep = false
    
    init(rssItem: RSSItem, menu action: ((RSSItem) -> Void)? = nil, rssFeedViewModel: RSSFeedViewModel) {
        self.rssItem = rssItem
        contextMenuAction = action
        self.rssFeedViewModel = rssFeedViewModel
        
        formatter = NumberFormatter()
        formatter.numberStyle = .percent
        
    }
    
    
    var remoteImage: RemoteImage?
    var post: RSSItem? {
            didSet {
                guard let post = post else {
                    return
                }
                remoteImage = URLImageService.shared.makeRemoteImage(url: post.thumbnailURL)
                cancellable = remoteImage?.$loadingState.sink { state in
                    switch state {
                        case .initial, .inProgress, .failure:
                            break
                    case .success:
                        WidgetCenter.shared.reloadAllTimelines()
                        URLImageService.shared.cleanup()
                        URLImageService.shared.removeAllCachedImages()
                    }
                }
                remoteImage?.load()
            }
        }

    var cancellable: AnyCancellable?
    
    let id = UUID()
    private let formatter: NumberFormatter


    
    
    var body: some View {
        let toggleStarred = SwipeCellButton(
            buttonStyle: .view,
            title: "",
            systemImage: "",
            view: {
                AnyView(
                    Group {
                        if rssItem.isArchive {
                            Image(systemName: "star")
                                .foregroundColor(Color("bg"))
                                .imageScale(.small)
                        }
                        else {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color("bg"))
                                .imageScale(.small)
                        }
                    }
                )
            },
            backgroundColor: Color("accent"),
            action: {
                self.contextMenuAction?(self.rssItem)
            },
            feedback: false
        )
        let toggleRead = SwipeCellButton(
            buttonStyle: .view,
            title: "",
            systemImage: "",
            view: {
                AnyView(
                    Group {
                        if rssItem.isRead {
                            Image(systemName: "largecircle.fill.circle")
                                .foregroundColor(Color("bg"))
                                .imageScale(.small)
                        }
                        else {
                            Image(systemName: "circle")
                                .foregroundColor(Color("bg"))
                                .imageScale(.small)
                        }
                    }
                )
            },
            backgroundColor: Color("accent"),
            action: {
                rssItem.progress = 1
                rssItem.isRead.toggle()
            },
            feedback: false
        )
        
        let star = SwipeCellSlot(slots: [toggleStarred], slotStyle: .destructive, buttonWidth: 60)
        let read = SwipeCellSlot(slots: [toggleRead], slotStyle: .destructive, buttonWidth: 60)
        
        
        
        ZStack {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .center, spacing: 4) {
                        if !rssItem.isRead {
                            Text("")
                                .frame(width: 10, height: 10)
                                .background(Color.blue)
                                .opacity(rssItem.isRead ? 0 : 1)
                                .clipShape(Circle())
                                //.padding([.bottom])
                        } else {
                            Text("")
                                .frame(width: 10, height: 10)
                                .background(Color.blue)
                                .opacity(0)
                                .clipShape(Circle())
                                //.padding([.bottom])
                        }
                        
                        Rectangle().foregroundColor(.gray)
                            .clipped()
                            .cornerRadius(3)
                            .frame(width: 22, height: 22)
                        
//                        KFImage(URL(string: rssSource.image ?? ""))
//                            .renderingMode(.original)
//                            .resizable()
//                            .placeholder {
//                                Rectangle().foregroundColor(.gray)
//                            }
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .clipped()
//                            .cornerRadius(3)
//                            .frame(width: 22, height: 22)

//                        URLImage(url: ((URL(string: self.rssSource?.image ?? "https://picsum.photos/60") ?? nil)!), options: URLImageOptions(cachePolicy: .useProtocol)) { image in
//                                image
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .clipped()
//                                    .cornerRadius(3)
//                                    .frame(width: 22, height: 22)
//                        }
                    }
                    HStack{
                        VStack(alignment: .leading){
                            HStack {
                                Text("\(rssItem.createTime?.string() ?? "")")
                                    .textCase(.uppercase)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray)
                                    .opacity(0.8)
                                
                                if rssItem.isArchive {
                                    Image(systemName: "star.fill").font(.system(size: 8, design: .rounded))
                                        .foregroundColor(Color.gray)
                                        .frame(width: 8, height: 8)
                                        .opacity(0.8)
                                } else {
                                    Image(systemName: "star.fill").font(.system(size: 8, design: .rounded))
                                        .foregroundColor(Color.gray)
                                        .opacity(rssItem.isArchive ? 1 : 0)
                                        .frame(width: 8, height: 8)
                                }
                                Spacer()
                            }
                            
                            if rssItem.progress >= 1.0 {
                                Text(rssItem.title)
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("text"))
                                    .opacity(0.6)
                                    .lineLimit(3)
                            } else if rssItem.progress > 0 {
                                Text(rssItem.title)
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("text"))
                                    .opacity(0.6)
                                    .lineLimit(3)
                            } else {
                                Text(rssItem.title)
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("text"))
                                    .opacity(rssItem.isRead ? 0.6 : 1)
                                    .lineLimit(3)
                            }
                            
                            Text((rssItem.desc).trimHTMLTag.trimWhiteAndSpace)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .opacity(0.8)
                                .foregroundColor(Color.gray)
                                .lineLimit(1)
                            
//                            Text(self.rssSource.title).font(.system(size: 11, weight: .medium, design: .rounded))
//                                .textCase(.uppercase)
//                                .foregroundColor(.gray)
                            
                            Text(rssItem.author).font(.system(size: 11, weight: .medium, design: .rounded))
                                .textCase(.uppercase)
                                .foregroundColor(.gray)
                        }
                                                
                        //KFImage(URL(string: rssSource.image))
//                        WebImage(url: rssSource.rssURL ?? nil)
//                            .placeholder(content: {
//                                Rectangle().foregroundColor(.gray)
//                            })
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 70, height: 70)
//                            .clipped()
//                            .cornerRadius(12)
                        
                        URLImage(url: ((URL(string: post?.image ?? "https://picsum.photos/60") ?? nil)!), options: URLImageOptions(cachePolicy: .useProtocol)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipped()
                                    .cornerRadius(3)
                                    .frame(width: 60, height: 60)
                            }
                    }
                }
            }
            .swipeCell(cellPosition: .both, leftSlot: read, rightSlot: star)
            .contextMenu {
                Section{
                    
//                    NavigationLink(destination: RSSFeedDetailView(rssItem: rssItem, rssFeedViewModel: self.rssFeedViewModel)) {
//                        Text("Open Article")
//                        Image(systemName: "doc.richtext")
//                    }
                    
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
        RSSItemRow(rssItem: RSSItem(), rssFeedViewModel: RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem))
            .previewLayout(.fixed(width: 375, height: 75))
            .preferredColorScheme(.dark)
    }
}
#endif
