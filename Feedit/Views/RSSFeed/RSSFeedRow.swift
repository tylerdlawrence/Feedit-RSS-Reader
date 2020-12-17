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
    
    @Environment(\.managedObjectContext) var managedObjectContext

    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }

    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var itemWrapper: RSSItem
    var contextMenuAction: ((RSSItem) -> Void)?
    var imageLoader: ImageLoader!

    init(rssViewModel: RSSFeedViewModel, wrapper: RSSItem, menu action: ((RSSItem) -> Void)? = nil) {
        self.rssFeedViewModel = rssViewModel
        itemWrapper = wrapper
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

                KFImage(URL(string: rssSource.imageURL))
                                .placeholder({
                                    //ZStack{
                                        Image("Thumbnail")
                                            .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 25, height: 25,alignment: .center)
                                                .cornerRadius(5)
                                                .border(Color.clear, width: 1)
                                            .opacity(0.8)
                                    //}
                                    //.padding(.trailing)
                                })
                    .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25,alignment: .center)
                        .cornerRadius(5)
                        .border(Color.clear, width: 1)
                    .opacity(0.8)

                    pureTextView

                .contextMenu {
                    ActionContextMenu(
                        label: itemWrapper.isArchive ? "Untag" : "Tag",
                        systemName: "star\(itemWrapper.isArchive ? "" : "star")",
                        onAction: {
                            self.contextMenuAction?(self.itemWrapper)
                        })
                    }

            }
        }

//        HStack{
//            VStack(alignment: .leading, spacing: 8) {
//                Text(itemWrapper.title)
//                    .font(.headline)
//                    .lineLimit(3)
//                Text(itemWrapper.desc.trimHTMLTag.trimWhiteAndSpace)
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .lineLimit(1)
//                HStack{
//                    Text("\(itemWrapper.createTime?.string() ?? "")")
//                        .font(.custom("Gotham", size: 14))
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.trailing)
//                    if itemWrapper.progress >= 1.0 {
//                        Text("DONE")
//                            .font(.footnote)
//                            .foregroundColor(.blue)
//                    } else if itemWrapper.progress > 0 {
//                        ProgressBar(
//                            boardWidth: 4,
//                            font: Font.system(size: 9),
//                            color: .blue,
//                            content: false,
//                            progress: self.$itemWrapper.progress
//                        )
//                        .frame(width: 13, height: 13, alignment: .center)
//                        }
//                        if itemWrapper.isArchive {
//                            Image("star")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 15, height: 15)
//                        }
//                    }
//                }
//            .padding(.horizontal, 12)
//            .contextMenu {
//                ActionContextMenu(
//                    label: itemWrapper.isArchive ? "Untag" : "Tag",
//                    systemName: "star\(itemWrapper.isArchive ? "" : "star")",
//                    onAction: {
//                        self.contextMenuAction?(self.itemWrapper)
//                    })
//                }
//            KFImage(URL(string: rssSource.imageURL))
//                            .placeholder({
//                                ZStack{
//                                    Image("launch")
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                        .font(.body)
//                                        .frame(width: 90, height: 90,alignment: .center)
//                                        .opacity(0.5)
//                                        .cornerRadius(5)
//                                        .border(Color.clear, width: 2)
//                                     //ProgressView()
//                                }
//                                .padding(.trailing)
//                            })
////                            .cancelOnDisappear(true)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 90, height: 90)
//                            .opacity(0.7)
//                            .clipped()
//                            .cornerRadius(12)
//                            .multilineTextAlignment(.trailing)
//
//        }
    }
}
