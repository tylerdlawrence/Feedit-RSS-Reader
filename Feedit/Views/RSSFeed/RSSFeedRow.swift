//
//  RSSItemRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//  View once you choose Feed on Main Screen

import SwiftUI
import FeedKit
import KingfisherSwiftUI
import SDWebImageSwiftUI

struct RSSItemRow: View {
    
    enum FavoriteFilter: Int {
        case want
        case done
        
        var label: String {
            switch self {
            case .want: return "Want to do"
            case .done: return "Done"
            }
        }
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext

    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    //let isRead:Bool;
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var itemWrapper: RSSItem
    var contextMenuAction: ((RSSItem) -> Void)?
    var imageLoader: ImageLoader!
    var isDone: (() -> Void)? //((RSSItem) -> Void)?

    init(rssViewModel: RSSFeedViewModel, wrapper: RSSItem, isRead: (() -> Void)? = nil, menu action: ((RSSItem) -> Void)? = nil) {
        self.rssFeedViewModel = rssViewModel
        itemWrapper = wrapper
        isDone = isRead
        contextMenuAction = action
    }
    private var pureTextView: some View {
        VStack(alignment: .leading, spacing: 4) {
                Text(itemWrapper.title)
                    .font(.headline)
                    .lineLimit(3)
//            Text(itemWrapper.desc)
            Text(itemWrapper.desc.trimHTMLTag.trimWhiteAndSpace)
                .font(.subheadline)
                .foregroundColor(Color.gray)
                .lineLimit(1)
            HStack{
                if itemWrapper.isDone {
                    MarkAsRead(isRead: true)
                }
                Text("\(itemWrapper.createTime?.string() ?? "")")
                    .font(.custom("Gotham", size: 14))
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
    
    var body: some View{
        VStack(alignment: .leading) {

            HStack(alignment: .top) {
                VStack{
                Button(action: { self.itemWrapper.isDone.toggle() }) {
                                    MarkAsRead(isRead: itemWrapper.isDone)
                                        .font(.caption)
//                    if itemWrapper.isArchive {
//                        Image("star")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 12, height: 12)
//                            .opacity(0.7)
//                        }
                    }
                }
                .padding(.top, 5.0)
                KFImage(URL(string: rssSource.imageURL))
                                .placeholder({
                                    //ZStack{
                                        Image("Thumbnail")
                                            .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 25, height: 25,alignment: .center)
                                                .cornerRadius(5)
                                                .border(Color.clear, width: 1)
                                            //.opacity(0.8)
                                    //}
                                    //.padding(.trailing)
                                })
                    .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25,alignment: .center)
                        .cornerRadius(5)
                        .border(Color.clear, width: 1)
                    //.opacity(0.8)

                    pureTextView

                .contextMenu {
                    ActionContextMenu(
                        label: itemWrapper.isArchive ? "Unstar" : "Star",
                        systemName: "star\(itemWrapper.isArchive ? "" : "star")",
                        onAction: {
                            self.contextMenuAction?(self.itemWrapper)
                        }
                    )
                }
                    
//                .contextMenu {
//                    ActionContextMenu(
//                        label: itemWrapper.isDone ? "Unread" : "Read",
//                        systemName: "circle\(itemWrapper.isDone ? "" : "circle")",
//                        onAction: {
//                            self.contextMenuAction?(self.itemWrapper)
//                        })
//                    }
//                        .opacity((isDone != nil) ? 0.2 : 1.0)
            }
        }

    }
}

struct MarkAsRead: View {
    
    let isRead: Bool;
    
    var body: some View {
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
            MarkAsRead(isRead: true)
            MarkAsRead(isRead: false)
        }
        .padding()
        .previewLayout(.sizeThatFits)
        }
    }


