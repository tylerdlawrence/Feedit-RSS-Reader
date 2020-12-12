//
//  RSSItemRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//  View once you choose Feed on Main Screen

import UIKit
import SwiftUI
import Combine
import KingfisherSwiftUI
import FeedKit

struct RSSItemRow: View {
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
        self.imageLoader = ImageLoader(path: wrapper.imageURL)
    }
    private var pureTextView: some View {
            Text(itemWrapper.title)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
    }
    private var descView: some View {
            Text(itemWrapper.desc)
                .font(.subheadline)
                .lineLimit(1)
    }
    var body: some View{
        HStack{
            VStack(alignment: .leading, spacing: 8) {
                Text(itemWrapper.title)
                    .font(.headline)
                    .lineLimit(3)
                Text(itemWrapper.desc.trimHTMLTag.trimWhiteAndSpace)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                HStack{
                    Text("\(itemWrapper.createTime?.string() ?? "")")
                        .font(.custom("Gotham", size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                    if itemWrapper.progress >= 1.0 {
                        Text("DONE")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    } else if itemWrapper.progress > 0 {
                        ProgressBar(
                            boardWidth: 4,
                            font: Font.system(size: 9),
                            color: .blue,
                            content: false,
                            progress: self.$itemWrapper.progress
                        )
                        .frame(width: 13, height: 13, alignment: .center)
                        }
                        if itemWrapper.isArchive {
                            Image("star")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 15)
                        }
                    }
                }.padding(.horizontal, 12)
//            KFImage(URL(string: self.itemWrapper.imageURL)) //"3icon"
            KFImage(URL(string: self.rssSource.imageURL))
                            .placeholder({
                                ZStack{
                                    Image("launch")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .font(.body)
                                        .frame(width: 90, height: 90,alignment: .center)
                                        .opacity(0.5)
                                        .cornerRadius(5)
                                        .border(Color.clear, width: 2)
//                                      ProgressView()
                                }
                            })
                            .cancelOnDisappear(true)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .clipped()
                            .cornerRadius(12)
                            .multilineTextAlignment(.trailing)
                            }


        .contextMenu {
            ActionContextMenu(
                label: itemWrapper.isArchive ? "Untag" : "Tag",
                systemName: "star\(itemWrapper.isArchive ? "" : "star")",
                onAction: { //self.
                    self.contextMenuAction?(self.itemWrapper)
                })
            }
        }
    }
//struct RSSFeedRow_Previews: PreviewProvider {
//    static var previews: some View {
//        let simple = DataSourceService.current.rssItem.simple()
////        return RSSItemRow(wrapper: simple!)
//        RSSItemRow(rssViewModel: rssFeedViewModel, wrapper: simple!)
//    }
//}
