//
//  RSSItemRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//  View once you choose Feed on Main Screen

import SwiftUI
import UIKit
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
        self.text = ""
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

    let text : String
//    let index : Int
    let width : CGFloat = 60
//    @Binding var indices : [Int]
    @State var offset = CGSize.zero
    @State var offsetY : CGFloat = 0
    @State var scale : CGFloat = 0.5
    
    var body: some View{
        
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack{
                    Button(action: {
                        self.itemWrapper.isDone.toggle()
                    }) {
                        MarkAsRead(isRead: itemWrapper.isDone)
                            .font(.caption)
                        }
                    }
                    .padding(.top, 5.0)

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
                    .contextMenu {
                        ActionContextMenu(
                            label: itemWrapper.isDone ? "Mark As Unread" : "Mark As Read",
                            systemName: "circle.fill\(itemWrapper.isDone ? "" : "circle")",
                            onAction: {
                                self.contextMenuAction?(self.itemWrapper)
                            }
                        )
                    }
            }
        }
//.SwiperizeItem(closureL: { print("click left") }, closureR: { print("click right") })
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

struct RowContent : View {
    let text : String
    let index : Int
    @Binding var indices : [Int]
    @State var offset = CGSize.zero
    @State var offsetY : CGFloat = 0
    @State var scale : CGFloat = 0.5
    
    
    
    var body : some View {
        GeometryReader { geo in
            HStack (spacing : 0){
                Text(text)
//                pureTextView
                    .padding()
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
                    //.frame(width : geo.size.width, alignment: .leading)
                
                ZStack {
                    Image("unread-action")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .font(.system(size: 20))
                        .scaleEffect(scale)
                }
                .frame(width: 60, height: geo.size.height)
                .background(Color.purple.opacity(0.15))
                .onTapGesture {
//                    indices.append(index)
                }
                ZStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .overlay(
                        Image(systemName: "star.circle")
                            .font(.system(size: 10))
                            .offset(y: self.offsetY)
                    )
            }
                .frame(width: 60, height: geo.size.height)
                .background(Color.red.opacity(0.15))
                .onTapGesture {
                    // Do Something
                }
            }
            .background(Color.secondary.opacity(0.1))
            .offset(self.offset)
            .animation(.spring())
            .gesture(DragGesture()
                        .onChanged { gestrue in
                            self.offset.width = gestrue.translation.width
                        }
                        .onEnded { _ in
                            if self.offset.width < -50 {
                                    self.scale = 1
                                self.offset.width = -120
                                self.offsetY = -20
                            } else {
                                    self.scale = 0.5
                                self.offset = .zero
                                self.offsetY = 0

                            }
                        }
            )
        }
    }
}
struct RowContentView: View {
    @State var array = ["First Text", "Second Text", "Third Text"]
    @State var indices : [Int] = []
    var body: some View {
        GeometryReader { geo in
            VStack {
                Text("Feeds")
                    .font(.system(size: 40))
                    .bold()
                    .frame(width: geo.size.width * 0.95, alignment: .leading)
                    .padding(.top, 50)
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach (0..<array.count, id: \.self) { index in
                            if !indices.contains(index) {
                                RowContent(text: array[index], index: index, indices : $indices)
                                    .frame(height: 60)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct RowContentView_Previews: PreviewProvider {
    static let rssFeedViewModel = RSSFeedViewModel(rss: RSS.simple(), dataSource: DataSourceService.current.rssItem)
    static var previews: some View {
        RowContentView()
    }
}



struct CustomScrollView<Content>: View where Content: View {
    var axes: Axis.Set = .vertical
    var reversed: Bool = false
    var scrollToEnd: Bool = false
    var content: () -> Content

    @State private var contentHeight: CGFloat = .zero
    @State private var contentOffset: CGFloat = .zero
    @State private var scrollOffset: CGFloat = .zero

    var body: some View {
        GeometryReader { geometry in
            if self.axes == .vertical {
                self.vertical(geometry: geometry)
            } else {
                // implement same for horizontal orientation
            }
        }
        .clipped()
    }

    private func vertical(geometry: GeometryProxy) -> some View {
        VStack {
            content()
        }
        .modifier(ViewHeightKey())
        .onPreferenceChange(ViewHeightKey.self) {
            self.updateHeight(with: $0, outerHeight: geometry.size.height)
        }
        .frame(height: geometry.size.height, alignment: (reversed ? .bottom : .top))
        .offset(y: contentOffset + scrollOffset)
        .animation(.easeInOut)
        .background(Color.white)
        .gesture(DragGesture()
            .onChanged { self.onDragChanged($0) }
            .onEnded { self.onDragEnded($0, outerHeight: geometry.size.height) }
        )
    }

    private func onDragChanged(_ value: DragGesture.Value) {
        self.scrollOffset = value.location.y - value.startLocation.y
    }

    private func onDragEnded(_ value: DragGesture.Value, outerHeight: CGFloat) {
        let scrollOffset = value.predictedEndLocation.y - value.startLocation.y

        self.updateOffset(with: scrollOffset, outerHeight: outerHeight)
        self.scrollOffset = 0
    }

    private func updateHeight(with height: CGFloat, outerHeight: CGFloat) {
        let delta = self.contentHeight - height
        self.contentHeight = height
        if scrollToEnd {
            self.contentOffset = self.reversed ? height - outerHeight - delta : outerHeight - height
        }
        if abs(self.contentOffset) > .zero {
            self.updateOffset(with: delta, outerHeight: outerHeight)
        }
    }

    private func updateOffset(with delta: CGFloat, outerHeight: CGFloat) {
        let topLimit = self.contentHeight - outerHeight

        if topLimit < .zero {
             self.contentOffset = .zero
        } else {
            var proposedOffset = self.contentOffset + delta
            if (self.reversed ? proposedOffset : -proposedOffset) < .zero {
                proposedOffset = 0
            } else if (self.reversed ? proposedOffset : -proposedOffset) > topLimit {
                proposedOffset = (self.reversed ? topLimit : -topLimit)
            }
            self.contentOffset = proposedOffset
        }
    }
}



struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

extension ViewHeightKey: ViewModifier {
    func body(content: Content) -> some View {
        return content.background(GeometryReader { proxy in
            Color.clear.preference(key: Self.self, value: proxy.size.height)
        })
    }
}
