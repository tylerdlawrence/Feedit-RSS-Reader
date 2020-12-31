//
//  SwipeCellDemoView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 12/21/20.
//

import SwiftUI
import SwipeCell

struct SwipeCellDemoView: View {
    
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
    
    var slidableContent: some View {
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
//                if itemWrapper.isDone {
//                    MarkAsRead(isRead: true)
//                }
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
    
    var slots = [
        // First item
        Slot(
            image: {
                Image(systemName: "envelope.open.fill")
            },
            title: {
                Text("Read")
                .foregroundColor(.white)
                .font(.footnote)
                .fontWeight(.semibold)
                .embedInAnyView()
            },
            action: { print("Read Slot tapped") },
            style: .init(background: .orange)
        ),
        // Second item
        Slot(
            image: {
                Image(systemName: "hand.raised.fill")
            },
            title: {
                Text("Block")
                .foregroundColor(.white)
                .font(.footnote)
                .fontWeight(.semibold)
                .embedInAnyView()
            },
            action: { print("Block Slot Tapped") },
            style: .init(background: .blue, imageColor: .red)
        )
    ]
    
    var left2Right: some View {
        slidableContent
        .frame(height: 60)
        .padding()
        .onSwipe(leading: slots)
    }
    
    var right2Left: some View {
        slidableContent
        .frame(height: 60)
        .padding()
        .onSwipe(trailing: slots)
    }
    
    var leftAndRight: some View {
        slidableContent
        .frame(height: 60)
        .padding()
        .onSwipe(leading: slots, trailing: slots)
    }
    
    var items: [AnyView] {
        [
            left2Right.embedInAnyView(),
            right2Left.embedInAnyView(),
            leftAndRight.embedInAnyView()
        ]
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items.indices, id: \.self) { idx in
                    self.items[idx]
                }.listRowInsets(EdgeInsets())
            }
        }
    }
    
}


