//
//  SourceListRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//
import SwiftUI
import UIKit
import Intents
import FeedKit
import Combine

struct RSSRow: View {
//    @ private var viewModel: RSSListViewModel
    @ObservedObject var imageLoader: ImageLoader
    @ObservedObject var rss: RSS

    var contextMenuAction: ((RSS) -> Void)?

    init(rss: RSS, menu action: ((RSS) -> Void)? = nil) {
        self.rss = rss
        self.imageLoader = ImageLoader(path: rss.imageURL)
//works^
        contextMenuAction = action
//        self.viewModel = viewModel

    }

    private func iconImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
        .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25,alignment: .center)
            .cornerRadius(5)
            .animation(.easeInOut)
            .border(Color.clear, width: 1)
        
    }

    private var pureTextView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(rss.title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                //.font(.headline)
                .lineLimit(1)
            Text(rss.desc)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                //.font(.subheadline)
                .foregroundColor(Color.gray)
                .lineLimit(3)
        }
    }
    //    let text : String
    //    let index : Int
        let width : CGFloat = 60
    //    @Binding var indices : [Int]
        @State var offset = CGSize.zero
        @State var offsetY : CGFloat = 0
        @State var scale : CGFloat = 0.5
    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
//                HStack {
                if
                    self.imageLoader.image != nil {
                    iconImageView(self.imageLoader.image!)
                        .frame(width: 25, height: 25,alignment: .center)
                        .layoutPriority(10)
                    pureTextView

//                    Spacer()
//                    UnreadCountView(count: RSSRow.viewModel.items.count)
                    } else {
                        
                        Image("Thumbnail") //3icon
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(.body)
                            .frame(width: 25, height: 25,alignment: .center)
                            .cornerRadius(5)
                            .opacity(0.8)
                            .border(Color.clear, width: 1)
                            .layoutPriority(10)
                            .animation(.easeInOut)
                            
                        pureTextView

//                        Spacer()
//                        UnreadCountView(count: RSSRow.viewModel.items.count)
                    }
//                }
            }
        }
    }
}

struct RSSRow_Previews: PreviewProvider {
    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static var previews: some View {
        ContentView()
    }
}
