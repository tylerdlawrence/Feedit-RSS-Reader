//
//  RSSItemRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import Foundation
import KingfisherSwiftUI
import SwipeableView
import UIKit
import Combine
import SwiftUIX
import ASCollectionView
import Introspect
import SwipeCellKit
import FeedKit
import SDWebImageSwiftUI
import SwipeCellKit
import Intents

struct RSSItemRow: View {
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.managedObjectContext) private var viewContext
    @Environment (\.presentationMode) var presentationMode


    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }

    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var itemWrapper: RSSItem
    @ObservedObject static var container = SwManager()
    @State private var selectedItem: RSSItem?
    @State var value:CGFloat = 0.0
    @State var didSwipe:Bool = false
    @State private var fontColor = Color("text")

    var contextMenuAction: ((RSSItem) -> Void)?
    var imageLoader: ImageLoader!
    var isRead: ((RSSItem) -> Void)?
    var model: GroupModel
    
    init(rssViewModel: RSSFeedViewModel, wrapper: RSSItem, isRead: ((RSSItem) -> Void)? = nil, menu action: ((RSSItem) -> Void)? = nil) {
        self.rssFeedViewModel = rssViewModel
        itemWrapper = wrapper
        contextMenuAction = action
        self.model = GroupModel(icon: "text.justifyleft", title: "")
    }
    
    private var pureTextView: some View {
        VStack(alignment: .leading) {
           HStack(alignment: .top) {
               VStack {
                   KFImage(URL(string: rssSource.imageURL))
                       .placeholder({
                       Image(systemName: model.icon)
                           .imageScale(.medium)
                           .font(.system(size: 16, weight: .heavy))
                           .foregroundColor(.white)
                           .background(
                               Rectangle().fill(model.color)
                                   .opacity(0.6)
                                   .frame(width: 25, height: 25)
                                   .cornerRadius(5)
                           )})
                           .resizable()
                           .aspectRatio(contentMode: .fit)
                           .frame(width: 25, height: 25,alignment: .center)
                           .cornerRadius(5)
                    }
                    .padding(.top, 3.0)
            
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
               Text(itemWrapper.title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(useReadText ? Color.gray.opacity(0.8) : Color("text"))
//                .opacity(0.8)
                //.foregroundColor(fontColor)
                .lineLimit(3)
               Text(itemWrapper.desc.trimHTMLTag.trimWhiteAndSpace)
                   .font(.system(size: 15, weight: .medium, design: .rounded))
                   .opacity(0.8)
                   .foregroundColor(Color.gray)
                   .lineLimit(1)
               }
           }
       }
    }
    
    @State private var showingInfo = false
    private var infoListView: some View {
        Button(action: {
            self.showingInfo = true
            }) {
            Image(systemName: "info.circle")
            }.sheet(isPresented: $showingInfo) {
                InfoView(rssViewModel: rssFeedViewModel)
        }
    }
    @State private var useReadText = false
    
    @State var indices : [Int] = []
    @State var offset = CGSize.zero
    @State var offsetY : CGFloat = 0
    @State var scale : CGFloat = 0.5
    
    var body: some View{
        
//        let left = [
//            Action(title: "", iconName: "star.fill", bgColor: Color("Color"), action: {self.contextMenuAction?(self.itemWrapper)})
//        ]
//        let right = [
//            Action(title: "", iconName: "circle", bgColor: Color("Color"), action: {self.useReadText.toggle()})
//        ]
        
        ZStack{
//            SwipeableView(content: {
//                GroupBox {
                pureTextView
//                    .padding()
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
//                }
//            },
//            leftActions: left,
//            rightActions: right,
//            rounded: true,
//            container: RSSItemRow.container
//            ).frame(height: 90)
                .contextMenu {
                    Section{
                        ActionContextMenu(
                            label: self.useReadText ? "Mark As Unread" : "Mark As Read",
                            systemName: "circle\(self.useReadText ? ".fill" : "")",
                            onAction: {
                                self.useReadText.toggle()
                        })
                    
                        ActionContextMenu(
                            label: itemWrapper.isArchive ? "Unstar" : "Star",
                            systemName: "star\(itemWrapper.isArchive ? "" : ".fill")",
                            onAction: {
                                self.contextMenuAction?(self.itemWrapper)
                        })
                    }
                    Section{
                        ActionContextMenu(
                            label: "Feed Info",
                            systemName: "info.circle",
                            onAction: {
                                
                        })
                    }
                }

        }
    }
}

struct MarkAsRead: View {
    let isRead: Bool;
    var body: some View {
        //Text("")
        Image(isRead ? "" : "smartFeedUnread")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 15, height: 15, alignment: .center)
            .foregroundColor(isRead ? .clear : .blue)
    }
}
struct MarkAsRead_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MarkAsRead(isRead: true) //blank
            MarkAsRead(isRead: false) //image shown
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
struct GroupModel: Identifiable {
    var icon: String
    var title: String
    var contentCount: Int? = Int.random(in: 0 ... 20)
    var color: Color = [Color.blue].randomElement()!
    static var demo = GroupModel(icon: "globe", title: "Feed Demo", contentCount: 19)
    var id: String { title }
}
struct GroupSmall: View {
    var model: GroupModel

    var body: some View
    {
        HStack(alignment: .center)
        {
            Image(systemName: model.icon)
                .font(.system(size: 16, weight: .regular))
                .padding(14)
                .foregroundColor(.white)
                .background(
                    Circle().fill(model.color)
                )

            Text(model.title)
                .multilineTextAlignment(.leading)
                .foregroundColor(Color(.label))

            Spacer()
            model.contentCount.map
            {
                Text("\($0)")
            }
        }
        .padding(10)
    }
}
