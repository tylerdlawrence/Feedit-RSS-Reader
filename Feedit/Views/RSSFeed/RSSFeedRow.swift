//
//  RSSItemRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//  View once you choose Feed on Main Screen

import SwiftUI
import UIKit
import SwiftUIX
import ASCollectionView
import SwipeableView
import Introspect
import SwipeCellKit
import FeedKit
import KingfisherSwiftUI
import SDWebImageSwiftUI
import SwipeCell
import Intents

struct RSSItemRow: View {

    @Environment(\.managedObjectContext) var managedObjectContext

    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var itemWrapper: RSSItem
    var contextMenuAction: ((RSSItem) -> Void)?
    var imageLoader: ImageLoader!
    var isDone: (() -> Void)? //((RSSItem) -> Void)?
    @State private var selectedItem: RSSItem?

    init(rssViewModel: RSSFeedViewModel, wrapper: RSSItem, isRead: (() -> Void)? = nil, menu action: ((RSSItem) -> Void)? = nil) {
        //self.text = ""
        self.rssFeedViewModel = rssViewModel
        itemWrapper = wrapper
        isDone = isRead
        contextMenuAction = action
    }
    

    
    private var pureTextView: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                KFImage(URL(string: rssSource.imageURL))
                    .placeholder({
                            Image("Thumbnail")
                                .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25,alignment: .center)
                                    .cornerRadius(5)
                                    .border(Color.clear, width: 1)
                    })
                    .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25,alignment: .center)
                        .cornerRadius(5)
                        .border(Color.clear, width: 1)
            VStack(alignment: .leading, spacing: 4) {
                Text(itemWrapper.title)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    //.font(.headline)
                    .lineLimit(3)
                Text(itemWrapper.desc.trimHTMLTag.trimWhiteAndSpace)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    //.font(.subheadline)
                    .opacity(0.7)
                    .foregroundColor(Color.gray)
                    .lineLimit(1)
                HStack{
                    if itemWrapper.isDone {
                        MarkAsRead(isRead: false)
                    }
                    Text("\(itemWrapper.createTime?.string() ?? "")")
                        //.font(.custom("Gotham", size: 14))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    if itemWrapper.isArchive {
                        Image("star")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 12, height: 12)
                            .opacity(0.7)
                        }
                    }
                }
            }
        }
    }

    
    @State var value:CGFloat = 0.0
    @State var didSwipe:Bool = false
    var body: some View{
        
        let drag = DragGesture()
            .onEnded{ (dragValue) in
                didSwipe = abs(dragValue.translation.width) > 30
            }
            .onChanged{ (dragValue) in self.value = dragValue.translation.width}
        
        let left = [
            Action(title: "", iconName: "star.fill", bgColor: Color("Color"), action: {self.isDone?()})//,
    //        Action(title: "Edit doc", iconName: "doc.text", bgColor: .yellow, action:
        ]

        let right = [
            Action(title: "", iconName: "circle", bgColor: Color("Color"), action: {self.contextMenuAction?(itemWrapper)})//,
    //        Action(title: "Edit doc", iconName: "doc.text", bgColor: .yellow, action: {})
        ]
        
//        VStack(alignment: .leading) {
//            HStack(alignment: .top) {
//                VStack{
//                    Button(action: {
//                        self.itemWrapper.isDone.toggle()
//                    }) {
//                        MarkAsRead(isRead: itemWrapper.isDone)
//                            .font(.caption)
//                        }
//                    }
                    //.padding(.top, 5.0)
        
                pureTextView
                    //.frame(maxWidth: .infinity, maxHeight: .infinity)
//                SwipeableView(content: {
////                    GroupBox {
//                    pureTextView
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .gesture(drag)
//                        .onTapGesture {
//                            self.value = 0
//                            didSwipe = false
//                        }
////                    }
//                },
//                leftActions: left,
//                rightActions: right,
//                rounded: true
//                ).frame(height: 90)
                

                //.gesture(DragGesture(minimumDistance: 30, coordinateSpace: .local))

                
                    .contextMenu {
                        ActionContextMenu(
                            label: itemWrapper.isArchive ? "Unstar" : "Star",
                            systemName: "star.\(itemWrapper.isArchive ? "fill" : "")",
                            onAction: {
                                self.contextMenuAction?(self.itemWrapper)
                            }
                        )
                    }
                    .contextMenu {
                        ActionContextMenu(
                            label: itemWrapper.isDone ? "Mark As Unread" : "Mark As Read",
                            systemName: "circle.fill\(itemWrapper.isDone ? "" : "circle")",
                            onAction: {
                                self.contextMenuAction?(self.itemWrapper)
                            }
                        )
                    }
//            }
//        }
    }
}

struct MarkAsRead: View {
    
    let isRead: Bool;
    
    var body: some View {
        Text("")
//        Image(isRead ? "" : "smartFeedUnread")
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: 15, height: 15, alignment: .center)
//            .foregroundColor(isRead ? .clear : .blue)
    }
}
 
//struct MarkAsRead_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            MarkAsRead(isRead: true)
//            MarkAsRead(isRead: false)
//        }
//        .padding()
//        .previewLayout(.sizeThatFits)
//        }
//    }

