//
//  RSSItemRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//  View once you choose Feed on Main Screen

import SwiftUI
import FeedKit

struct RSSItemRow: View {
    
    @ObservedObject var itemWrapper: RSSItem
//    @ObservedObject var imageLoader: ImageLoader
//    @ObservedObject var rss: RSS
    
    var contextMenuAction: ((RSSItem) -> Void)?
    
    
    init(wrapper: RSSItem, menu action: ((RSSItem) -> Void)? = nil) {
        itemWrapper = wrapper
        contextMenuAction = action
//        self.rss = rss
//        self.imageLoader = ImageLoader(path: rss.image)
    }
    
    func iconImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
        .resizable()
            .cornerRadius(0)
            .animation(.easeInOut)
            .border(Color.white, width: 1)
        
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image("AppIcon.png")
            Text(itemWrapper.title)
                .font(.headline)
                .fontWeight(.medium)
                .lineLimit(2)
            //Spacer()
            Text(itemWrapper.desc.trimHTMLTag.trimWhiteAndSpace)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.gray)
            //Spacer()
            HStack(spacing: 10) {
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
                    .frame(width: 20, height: 20, alignment: .center)
                }
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        HStack {
                Text("\(itemWrapper.createTime?.string() ?? "")")
                    .font(.footnote)
                    .foregroundColor(.gray)
                Spacer(minLength: 10)
                if itemWrapper.isArchive {
                    Image(systemName: "bookmark")
                    //tray.and.arrow.down.fill
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .contextMenu {
            ActionContextMenu(
                label: itemWrapper.isArchive ? "Remove Bookmark" : "Bookmark",
                systemName: "tray.and.arrow.\(itemWrapper.isArchive ? "up" : "down")",
                onAction: {
                    self.contextMenuAction?(self.itemWrapper)
            })
        }
    }
            }
        }
    }
}

struct RSSFeedRow_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 12")
    }
}


