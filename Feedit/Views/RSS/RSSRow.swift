//
//  SourceListRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//
import SwiftUI
import UIKit
import KingfisherSwiftUI
import Intents
import FeedKit
import Combine

struct RSSRow: View {
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var imageLoader: ImageLoader
    @ObservedObject var rss: RSS

    var contextMenuAction: ((RSS) -> Void)?
    var model: GroupModel

    init(rss: RSS, menu action: ((RSS) -> Void)? = nil) {
        self.rss = rss
        self.imageLoader = ImageLoader(path: rss.imageURL)
        self.model = GroupModel(icon: "text.justifyleft", title: "")
        contextMenuAction = action
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
            HStack(alignment: .center){
//                KFImage(URL(string: rss.imageURL))
//                    .placeholder({
//                    Image(systemName: model.icon)
//                        .imageScale(.medium)
//                        .font(.system(size: 16, weight: .heavy))
//                        .layoutPriority(10)
//                        .foregroundColor(.white)
//                        .background(
//                            Rectangle().fill(model.color)
//                                .opacity(0.6)
//                                .frame(width: 25, height: 25,alignment: .center)
//                                .cornerRadius(5)
//                        )})
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 25, height: 25,alignment: .center)
//                        .cornerRadius(2)
//                        .border(Color.clear, width: 1)
            Text(rss.title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                //.font(.headline)
                .lineLimit(1)
            }
//            Text(rss.desc)
//                .font(.system(size: 13, weight: .medium, design: .rounded))
//                //.font(.subheadline)
//                .foregroundColor(Color.gray)
//                .lineLimit(3)
        }
    }

//    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
//    static var viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
//                HStack {
                if
                    self.imageLoader.image != nil {
                    iconImageView(self.imageLoader.image!)
                        .frame(width: 25, height: 25,alignment: .center)
                        .layoutPriority(10)
                    pureTextView
                    } else {
                        KFImage(URL(string: rss.imageURL))
                            .placeholder({
                        Image(systemName: model.icon)
                            .imageScale(.medium)
                            .font(.system(size: 16, weight: .heavy))
                            .layoutPriority(10)
                            .foregroundColor(.white)
                            .background(
                                Rectangle().fill(model.color)
                                    .opacity(0.6)
                                    .frame(width: 25, height: 25,alignment: .center)
                                    .cornerRadius(5)
                            )})
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25,alignment: .center)
                            .cornerRadius(2)
                            .border(Color.clear, width: 1)
                        pureTextView
                    }
                }
            }
    }
}

//struct RSSRow_Previews: PreviewProvider {
//    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
//    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
//    static var previews: some View {
//        ContentView()
//    }
//}

