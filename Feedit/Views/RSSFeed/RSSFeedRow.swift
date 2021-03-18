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
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var rssDataSource: RSSDataSource
//    @StateObject var rss: RSS
    let persistence = Persistence.current
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var itemWrapper: RSSItem
    
    @State private var selectedItem: RSSItem?
    var contextMenuAction: ((RSSItem) -> Void)?
        
    init(wrapper: RSSItem, menu action: ((RSSItem) -> Void)? = nil, rssFeedViewModel: RSSFeedViewModel) {
        itemWrapper = wrapper
        contextMenuAction = action
        self.rssFeedViewModel = rssFeedViewModel
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
                        if itemWrapper.isRead {
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
                itemWrapper.isRead.toggle()
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
                            .opacity(itemWrapper.isArchive ? 1 : 0)
                            .frame(width: 8, height: 8)
                            .padding([.top, .leading])
                    }
                }
                VStack{
//                    KFImage(URL(string: self.rss.image))
//
//                    KFImage(URL(string: itemWrapper.image))
//                        .placeholder({
//                            Image("getInfo")
//                                .renderingMode(.original)
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 20, height: 20,alignment: .center)
//                                .cornerRadius(1)
//                        })
//                        .renderingMode(.original)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 20, height: 20,alignment: .center)
//                        .cornerRadius(1)
                    
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
                                    .opacity(itemWrapper.isRead ? 0.6 : 1)
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
                        
                    }
               }
            }
            .swipeCell(cellPosition: .both, leftSlot: read, rightSlot: star)
            .contextMenu {
                Section{
//                    NavigationLink(destination: RSSFeedDetailView(rssItem: itemWrapper, rssFeedViewModel: self.rssFeedViewModel)) {
//                        Text("Open Article")
//                        Image(systemName: "doc.richtext")
//                    }
                    Link(destination: URL(string: itemWrapper.url)!, label: {
                        HStack {
                            Text("Open Article")
                            Image(systemName: "doc.richtext")
                        }
                    })
                    
                    Divider()
                    
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


                    Button(action: actionSheet) {
                        Text("Share Article")
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    func actionSheet() {
        guard let urlShare = URL(string: itemWrapper.url) else { return }
           let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
           UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
       }
}

extension Int {
    static func * (lhs: Int, rhs: CGFloat) -> CGFloat {
        return CGFloat(lhs) * rhs
    }
}


#if DEBUG
struct RSSFeedRow_Previews: PreviewProvider {
    static var rss = RSS()

    static var rssFeedViewModel = RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem)

    static var previews: some View {
        let simple = DataSourceService.current.rssItem.simple()
        return RSSItemRow(wrapper: simple!, rssFeedViewModel: rssFeedViewModel).environmentObject(DataSourceService.current.rssItem)
            
            .previewLayout(.fixed(width: 375, height: 75))
            .preferredColorScheme(.dark)
    }
}
#endif

struct tags: View {
    var tags: Array<String>
    var body: some View {
        HStack {
        ForEach(tags, id: \.self) { e in
            Text(e)
                .foregroundColor(Color("text"))
                .font(.system(size: 6))
                .padding(4)
                .overlay(
                   RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("tab"), lineWidth: 0.5)
               )
           }
        }
    }
}
