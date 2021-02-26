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

    @State private var isStarred = false
    @State private var isRead = false
    
    @State private var selectedItem: RSSItem?
    var contextMenuAction: ((RSSItem) -> Void)?
    
    init(wrapper: RSSItem, menu action: ((RSSItem) -> Void)? = nil) { //, rssFeedViewModel: RSSFeedViewModel) {
        itemWrapper = wrapper
        contextMenuAction = action
//        self.rssFeedViewModel = rssFeedViewModel
    }
    var body: some View {
        let toggleStarred = SwipeCellButton(
            buttonStyle: .view,
            title: "",
            systemImage: "",
            view: {
                AnyView(
                    Group {
                        if itemWrapper.isArchive {
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
                itemWrapper.progress = 1
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
                    if itemWrapper.isArchive {
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
                VStack{
                    KFImage(URL(string: itemWrapper.image))
                        .placeholder({
                            Image("getInfo")
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20,alignment: .center)
                                .cornerRadius(1)
                                .border(Color("text"), width: 2)
                        })
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20,alignment: .center)
                        .cornerRadius(1)
                        .border(Color("text"), width: 2)
                }.padding(.top)
                    HStack{
                        VStack(alignment: .leading){
                            HStack {
                                Text("\(itemWrapper.createTime?.string() ?? "")")
                                    .textCase(.uppercase)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray)
                                    .opacity(0.8)
                                Spacer()
                            }
                            if itemWrapper.progress >= 1.0 {
                                Text(itemWrapper.title)
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("text"))
                                    .opacity(0.6)
                                    .lineLimit(3)
                            } else if itemWrapper.progress > 0 {
                                Text(itemWrapper.title)
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("text"))
                                    .opacity(0.6)
                                    .lineLimit(3)
                            } else {
                                Text(itemWrapper.title)
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("text"))
                                    .opacity(self.isRead ? 0.6 : 1)
                                    .lineLimit(3)
                            }
                                
                            Text(itemWrapper.desc.trimHTMLTag.trimWhiteAndSpace)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .opacity(0.8)
                                .foregroundColor(Color.gray)
                                .lineLimit(1)
                            
                            Text(itemWrapper.author).font(.system(size: 11, weight: .medium, design: .rounded))
                                .textCase(.uppercase)
                                .foregroundColor(.gray)
                        }
                        Spacer()
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
                        label: itemWrapper.progress > 0 ? "Mark As Unread" : "Mark As Read",
                        systemName: "circle\(itemWrapper.progress > 0 ? ".fill" : "")",
                        onAction: {
                            itemWrapper.progress = 1
                    })
                    ActionContextMenu(
                        label: itemWrapper.isArchive ? "Unstar" : "Star",
                        systemName: "star\(itemWrapper.isArchive ? ".fill" : "")",
                        onAction: {
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
}

extension Int {
    static func * (lhs: Int, rhs: CGFloat) -> CGFloat {
        return CGFloat(lhs) * rhs
    }
}

struct RSSFeedRow_Previews: PreviewProvider {
    static var previews: some View {
        let simple = DataSourceService.current.rssItem.simple()
        return RSSItemRow(wrapper: simple!).environmentObject(DataSourceService.current.rssItem)
            .frame(width: 360, height: 60)
            .preferredColorScheme(.dark)
    }
}
