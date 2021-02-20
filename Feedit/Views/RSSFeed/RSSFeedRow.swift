//
//  RSSItemRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
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

struct RSSItemRow: View {
//    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var itemWrapper: RSSItem
//    @ObservedObject var rss: RSS
    @State private var isStarred = false
    @State private var isRead = false
    @State private var selectedItem: RSSItem?
    var contextMenuAction: ((RSSItem) -> Void)?
    var markPostRead: (() -> Void)?
//    var rssSource: RSS {
//        return self.rssFeedViewModel.rss
//    }
    init(wrapper: RSSItem, isRead: ((RSSItem) -> Void)? = nil, menu action: ((RSSItem) -> Void)? = nil) {
        itemWrapper = wrapper
        contextMenuAction = action
    }
    var body: some View {
        let toggleStarred = SwipeCellButton(
            buttonStyle: .view,
            title: "",
            systemImage: "",
            view: {
                AnyView(
                    Group {
                        if isStarred {
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
                self.isStarred.toggle()
//                itemWrapper.isArchive.toggle()
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
                        if self.isRead {
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
                self.isRead.toggle()
            },
            feedback: false
        )
        
        let star = SwipeCellSlot(slots: [toggleStarred], slotStyle: .destructive, buttonWidth: 60)
        let read = SwipeCellSlot(slots: [toggleRead], slotStyle: .destructive, buttonWidth: 60)

        ZStack {
            VStack(alignment: .leading) {
               HStack(alignment: .top) {
                VStack {
                    if self.isStarred {
                        Image(systemName: "star.fill").font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(Color.yellow)
                            .multilineTextAlignment(.center)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8, height: 8)
                            .opacity(0.8)
                            .padding([.top, .leading])
                    } else {
                        Image(systemName: "star.fill").font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(Color.yellow)
                            .multilineTextAlignment(.center)
                            .aspectRatio(contentMode: .fit)
                            .opacity(self.isStarred ? 1 : 0)
                            .frame(width: 8, height: 8)
                            .padding([.top, .leading])
                    }
                }
                HStack{
                    VStack(alignment: .leading){
                        HStack {
                            Text("\(itemWrapper.createTime?.string() ?? "")")
                                .textCase(.uppercase)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                                .opacity(0.8)
                            Spacer()
                            if itemWrapper.progress >= 1.0 {
                                Text("DONE")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("tab"))


                            } else if itemWrapper.progress > 0 {
                                
                                Text(String(format: "%.1lf %%", itemWrapper.progress * 100))
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("tab"))

                            }
                        }
                        
                        Text(itemWrapper.title)
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(Color("text"))
                            .opacity(self.isRead ? 0.6 : 1)
                            .lineLimit(3)
                        
                        Text(itemWrapper.desc.trimHTMLTag.trimWhiteAndSpace)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .opacity(0.8)
                            .foregroundColor(Color.gray)
                            .lineLimit(1)
                        
//                        Text(rssSource.title).font(.system(size: 11, weight: .medium, design: .rounded))
//                            .textCase(.uppercase)
//                            .foregroundColor(.gray)
                    }
                    Spacer()

    //                HStack(spacing: 10) {
    //                    if itemWrapper.progress >= 1.0 {
    //                        Text("DONE")
    //                            .font(.footnote)
    //                            .foregroundColor(.orange)
    //                    } else if itemWrapper.progress > 0 {
    //                        Text(String(format: "%.1lf %%", itemWrapper.progress * 100))
    //                            .font(.footnote)
    //                            .foregroundColor(.orange)
    //                    }
    //                }
    //                Image(systemName: "eye")
    //                    .frame(height: 15)
    //                    .foregroundColor(.white)
    //                    .padding(.all, 8)
    //                    .background(Color.blue)
    //                    .clipShape(RoundedRectangle(cornerRadius: 10))
    //                    .opacity(self.isRead ? 1 : 0)
                    }
                }
            }
            .swipeCell(cellPosition: .both, leftSlot: read, rightSlot: star)
            .contextMenu {
                Section{
                    ActionContextMenu(
                        label: self.isRead ? "Mark As Unread" : "Mark As Read",
                        systemName: "circle\(self.isRead ? ".fill" : "")",
                        onAction: {
                            self.isRead.toggle()
                            self.contextMenuAction?(self.itemWrapper)
                        })
                    
                    
                
                    ActionContextMenu(
                        label: isStarred ? "Unstar" : "Star",
                        systemName: "star\(isStarred ? ".fill" : "")",
                        onAction: {
                            isStarred.toggle()
                            self.contextMenuAction?(self.itemWrapper)
                    })
                    
                    Divider()
                    
                    
                    Button(action: {
                        UIPasteboard.general.setValue(itemWrapper.url,
                                                      forPasteboardType: kUTTypePlainText as String)
                    }) {
                        Text("Copy Article Link")
                        Image(systemName: "link")
                    }
                    
                }
            }
        }
    }
//    func formatDate(with date: Date) -> String {
//        if Calendar.current.isDateInToday(date) {
//            return "" + date.toString(format: "h:mm a")
//        } else {
//            return date.toString(format: "MM/dd/yyyy")
//        }
//    }
}

//struct RSSFeedRow_Previews: PreviewProvider {
//    static let rssFeedViewModel = RSSFeedViewModel(rss: RSS(context: Persistence.current.context), dataSource: DataSourceService.current.rssItem)
//    static let rss = DataSourceService.current
//    static var previews: some View {
//        let simple = DataSourceService.current.rssItem.simple()
//        return RSSItemRow(rssFeedViewModel: self.rssFeedViewModel, wrapper: simple!)
//    }
//}

struct KeywordBadge: View {
    var string: String
    var body: some View {
        Text(string)
            .font(.system(size: 12))
            .padding(2)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(red: 182/255, green: 182/255, blue: 182/255), lineWidth: 1))
    }
}

//import SwiftUI
//import Foundation
//import KingfisherSwiftUI
//import class Kingfisher.ImageCache
//import class Kingfisher.KingfisherManager
//import UIKit
//import Combine
//import SwipeCell
//import FeedKit
//import SDWebImageSwiftUI
//import Intents
//
//struct RSSItemRow: View {
////    @ObservedObject var imageLoader:ImageLoader
//    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
//    @ObservedObject var itemWrapper: RSSItem
//
//    @State private var isStarred = false
//    @State private var isRead = false
//    @State private var selectedItem: RSSItem?
//    var contextMenuAction: ((RSSItem) -> Void)?
//    var markPostRead: (() -> Void)?
//    var rssSource: RSS {
//        return self.rssFeedViewModel.rss
//    }
//
//    init(rssFeedViewModel: RSSFeedViewModel, wrapper: RSSItem, menu action: ((RSSItem) -> Void)? = nil) {
//        self.rssFeedViewModel = rssFeedViewModel
//        itemWrapper = wrapper
//        contextMenuAction = action
//    }
//
//

////    /// Preload page images sequentially.
////    private func preloadImages(for urls: [URL], index: Int = 0) {
////        guard index < urls.count else { return }
////        KingfisherManager.shared.retrieveImage(with: urls[index]) { (_) in
////            self.preloadImages(for: urls, index: index + 1)
////        }
////    }
//
//    private var pureTextView: some View {
//        VStack(alignment: .leading) {
//           HStack(alignment: .top) {
//            VStack {
//                Image(systemName: "largecircle.fill.circle")
//                    .imageScale(.small)
//                    .foregroundColor(.blue)
//                    .font(.system(size: 13, weight: .medium, design: .rounded))
//                    .opacity(itemWrapper.isRead ? 0 : 1)
////                KFImage(URL(string: rssSource.imageURL))
////                    .placeholder({
////
////                    })
////                 .renderingMode(.original)
////                .resizable()
////                .aspectRatio(contentMode: .fit)
////                .frame(width: 25, height: 25,alignment: .center)
////                .cornerRadius(5)
//               }
//               //.padding(.top, 1.0)
//
//            VStack(alignment: .leading, spacing: 4) {
//                HStack(alignment: .center) {
//                    if itemWrapper.isArchive {
//                        Text("Starred")
//                            .textCase(.uppercase)
//                            .font(.system(size: 11, weight: .medium, design: .rounded))
//                            .foregroundColor(.gray)
//                            .opacity(0.8)
//                            .multilineTextAlignment(.leading)
//                    } else {
//                    Text(rssSource.title)
//                        .textCase(.uppercase)
//                        .font(.system(size: 11, weight: .medium, design: .rounded))
//                        .foregroundColor(.gray)
//                        .opacity(0.8)
//                        .multilineTextAlignment(.leading)
//                    }
//
//                    Spacer()
//
//                    if itemWrapper.isArchive {
//                        Image(systemName: "star.fill").font(.system(size: 11, weight: .black, design: .rounded))
//                            .foregroundColor(Color("bg"))
//                            .multilineTextAlignment(.center)
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 8, height: 8)
//                            .opacity(0.8)
//                        }
//
//                    Text("\(itemWrapper.createTime?.string() ?? "")")
//                        .textCase(.uppercase)
//                        .font(.system(size: 11, weight: .medium, design: .rounded))
//                        .foregroundColor(.gray)
//                        .opacity(0.8)
//                }
//                if itemWrapper.isRead == false {
//                    Text(itemWrapper.title)
//                        .font(.system(size: 17, weight: .medium, design: .rounded))
//                        .foregroundColor(Color("text"))
//                        .lineLimit(3)
//                } else {
//                    Text(itemWrapper.title)
//                        .font(.system(size: 17, weight: .medium, design: .rounded))
////                        .foregroundColor(Color("text"))
//                        .opacity(0.6)
//                        .lineLimit(3)
//                }
////                .foregroundColor(useReadText ? Color.gray.opacity(0.8) : Color("text"))
////                .foregroundColor(fontColor)
//               Text(itemWrapper.desc.trimHTMLTag.trimWhiteAndSpace)
//                   .font(.system(size: 15, weight: .medium, design: .rounded))
//                   .opacity(0.8)
//                   .foregroundColor(Color.gray)
//                   .lineLimit(1)
//               }
//           }
//       }
//    }
//    func swipeRow() -> some View {
//        pureTextView
//    }
//
//
//    var body: some View{
//        let toggleStarred = SwipeCellButton(
//            buttonStyle: .view,
//            title: "",
//            systemImage: "",
//            view: {
//                AnyView(
//                    Group {
//                        if isStarred {
//                            Image(systemName: "star")
//                                .foregroundColor(Color("bg"))
//                                .imageScale(.small)
//                        }
//                        else {
//                            Image(systemName: "star.fill")
//                                .foregroundColor(Color("bg"))
//                                .imageScale(.small)
//                        }
//                    }
//                )
//            },
//            backgroundColor: Color("accent"),
//            action: {
//                self.isStarred.toggle()
//                self.contextMenuAction?(self.itemWrapper)
//            },
//            feedback: false
//        )
//
//        let toggleRead = SwipeCellButton(
//            buttonStyle: .view,
//            title: "",
//            systemImage: "",
//            view: {
//                AnyView(
//                    Group {
//                        if self.isRead {
//                            Image(systemName: "largecircle.fill.circle")
//                                .foregroundColor(Color("bg"))
//                                .imageScale(.small)
//
//                        }
//                        else {
//                            Image(systemName: "circle")
//                                .foregroundColor(Color("bg"))
//                                .imageScale(.small)
//                        }
//                    }
//                )
//            },
//            backgroundColor: Color("accent"),
//            action: {
//                self.isRead.toggle()
//                self.contextMenuAction?(self.itemWrapper)
//            },
//            feedback: false
//        )
//
//        let star = SwipeCellSlot(slots: [toggleStarred], slotStyle: .destructive, buttonWidth: 60)
//        let read = SwipeCellSlot(slots: [toggleRead], slotStyle: .destructive, buttonWidth: 60)
//
//        ZStack{
//            swipeRow()
//                .onTapGesture {
//                    print("test")
//                }
//                .swipeCell(cellPosition: .both, leftSlot: read, rightSlot: star)
//                .contextMenu {
//                    Section{
//                        ActionContextMenu(
//                            label: self.isRead ? "Mark As Unread" : "Mark As Read",
//                            systemName: "circle\(self.isRead ? ".fill" : "")",
//                            onAction: {
//                                self.isRead.toggle()
//                            })
//
//                        ActionContextMenu(
//                            label: self.isStarred ? "Unstar" : "Star",
//                            systemName: "star\(self.isStarred ? ".fill" : "")",
//                            onAction: {
//                                self.isStarred.toggle()
//                                self.contextMenuAction?(self.itemWrapper)
//                        })
//                    }
//                }
//
//        }
//    }
//}
