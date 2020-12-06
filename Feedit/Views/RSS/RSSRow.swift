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


struct RSSRow: View {

    @ObservedObject var imageLoader: ImageLoader
    @ObservedObject var rss: RSS
    
    var contextMenuAction: ((RSS) -> Void)?

    init(rss: RSS, menu action: ((RSS) -> Void)? = nil) {
        self.rss = rss
        contextMenuAction = action
        self.imageLoader = ImageLoader(path: rss.image)
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
        VStack(spacing: 0.0) {
            Text(rss.title)
                .font(.custom("Gotham", size: 16))
                .multilineTextAlignment(.leading)
                .lineLimit(1)
//            Text(rss.desc)
//                .font(.subheadline)
//                .lineLimit(1)
//            Text(rss.createTimeStr)
//                .font(.custom("Gotham", size: 12))
//                .multilineTextAlignment(.leading)
//                .lineLimit(1)
                }
    }
    var body: some View {
        HStack() {
            VStack(alignment: .center) {
                HStack {
                    if
                        self.imageLoader.image != nil {
                        iconImageView(self.imageLoader.image!)
                            .frame(width: 25, height: 25,alignment: .center)
                            .layoutPriority(10)
                        pureTextView
                        
                    } else {
                        
                        Image("3icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(.body)
                            .frame(width: 25, height: 25,alignment: .center)
                            .cornerRadius(5)
                            .border(Color.clear, width: 1)
                            .layoutPriority(10)
                            .animation(.easeInOut)
                            
                        pureTextView
                    }
                }
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
