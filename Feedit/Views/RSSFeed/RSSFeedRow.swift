//
//  RSSItemRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import Foundation
import KingfisherSwiftUI
import class Kingfisher.ImageCache
import class Kingfisher.KingfisherManager
import UIKit
import Combine
import SwipeCell
import FeedKit
import SDWebImageSwiftUI
import Intents

struct RSSItemRow: View {
        
    @EnvironmentObject var rssDataSource: RSSDataSource
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.managedObjectContext) private var viewContext
    @Environment (\.presentationMode) var presentationMode


    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @ObservedObject var imageLoader:ImageLoader
    @State var image:UIImage = UIImage()

    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var itemWrapper: RSSItem
    @State private var selectedItem: RSSItem?
    @State var value:CGFloat = 0.0
    @State var didSwipe:Bool = false
    @State private var fontColor = Color("text")
    
    @State private var showSheet = false
    @State private var bookmark = false
    @State private var unread = false
    @State private var showAlert = false

    var contextMenuAction: ((RSSItem) -> Void)?
//    var imageLoader: ImageLoader!
    
    init(withURL url:String, rssViewModel: RSSFeedViewModel, wrapper: RSSItem, isRead: ((RSSItem) -> Void)? = nil, menu action: ((RSSItem) -> Void)? = nil) {
        self.rssFeedViewModel = rssViewModel
        itemWrapper = wrapper
        contextMenuAction = action
        imageLoader = ImageLoader(urlString:url)
//        imageLoader = ImageLoader(urlString: rssSource.imageURL)
    }
    

    
    /// Preload page images sequentially.
    private func preloadImages(for urls: [URL], index: Int = 0) {
        guard index < urls.count else { return }
        KingfisherManager.shared.retrieveImage(with: urls[index]) { (_) in
            self.preloadImages(for: urls, index: index + 1)
        }
    }

    private var pureTextView: some View {
        VStack(alignment: .leading) {
           HStack(alignment: .top) {
            VStack {
                Image(systemName: "largecircle.fill.circle")
                    .imageScale(.small)
                    .foregroundColor(.blue)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .opacity(itemWrapper.isRead ? 0 : 1)
//                KFImage(URL(string: rssSource.imageURL))
//                    .placeholder({
//
//                    })
//                 .renderingMode(.original)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 25, height: 25,alignment: .center)
//                .cornerRadius(5)
               }
               //.padding(.top, 1.0)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center) {
                    if itemWrapper.isArchive {
                        Text("Starred")
                            .textCase(.uppercase)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                            .opacity(0.8)
                            .multilineTextAlignment(.leading)
                    } else {
                    Text(rssSource.title)
                        .textCase(.uppercase)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                        .opacity(0.8)
                        .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    if itemWrapper.isArchive {
                        Image(systemName: "star.fill").font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(Color("bg"))
                            .multilineTextAlignment(.center)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8, height: 8)
                            .opacity(0.8)
                        }

                    Text("\(itemWrapper.createTime?.string() ?? "")")
                        .textCase(.uppercase)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                        .opacity(0.8)
                }
                if itemWrapper.isRead == false {
                    Text(itemWrapper.title)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(Color("text"))
                        .lineLimit(3)
                } else {
                    Text(itemWrapper.title)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
//                        .foregroundColor(Color("text"))
                        .opacity(0.6)
                        .lineLimit(3)
                }
//                .foregroundColor(useReadText ? Color.gray.opacity(0.8) : Color("text"))
//                .foregroundColor(fontColor)
               Text(itemWrapper.desc.trimHTMLTag.trimWhiteAndSpace)
                   .font(.system(size: 15, weight: .medium, design: .rounded))
                   .opacity(0.8)
                   .foregroundColor(Color.gray)
                   .lineLimit(1)
               }
           }
       }
    }
    

    
    @State private var useReadText = false
    @State private var isRead = false
    
    func swipeRow() -> some View {
        pureTextView
    }

    
    var body: some View{
        
        let toggleStarred = SwipeCellButton(
            buttonStyle: .view,
            title: "",
            systemImage: "",
            view: {
                AnyView(
                    Group {
                        if bookmark {
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
                bookmark.toggle()
                self.contextMenuAction?(self.itemWrapper)
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
                        if unread {
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
                unread.toggle()
//                self.useReadText.toggle()
                self.itemWrapper.isRead.toggle()
            },
            feedback: false
        )
        
        let star = SwipeCellSlot(slots: [toggleStarred], slotStyle: .destructive, buttonWidth: 60)
        let slot1 = SwipeCellSlot(slots: [toggleRead], slotStyle: .destructive, buttonWidth: 60)
        
        ZStack{
            swipeRow()
                .onTapGesture {
                    print("test")
                }
                .swipeCell(cellPosition: .both, leftSlot: slot1, rightSlot: star)
                .contextMenu {
                    Section{
                        ActionContextMenu(
                            label: self.unread ? "Mark As Unread" : "Mark As Read",
                            systemName: "circle\(self.unread ? ".fill" : "")",
                            onAction: {
                                unread.toggle()
                                self.useReadText.toggle()
                                self.itemWrapper.isRead.toggle()
                            })
                    
                        ActionContextMenu(
                            label: itemWrapper.isArchive ? "Unstar" : "Star",
                            systemName: "star\(itemWrapper.isArchive ? "" : ".fill")",
                            onAction: {
                                self.contextMenuAction?(self.itemWrapper)
                        })
                    }
                }

        }
    }
}
