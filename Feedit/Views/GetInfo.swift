//
//  GetInfo.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 1/3/21.
//

import SwiftUI
import UIKit
import NavigationStack
import SwipeCell
import SwiftUIGestures
import FeedKit
import Combine
import KingfisherSwiftUI
import SwiftUIRefresh
import SwipeCellKit

struct InfoView: View {
    
    enum InfoItem: CaseIterable {
        case webView
        case darkMode
        case batchImport
        
        var label: String {
            switch self {
            case .webView: return "Read Mode"
            case .darkMode: return "Outlook"
            case .batchImport: return "Import RSS Sources"
            }
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel

    @State private var feedUrl: String = ""
    @State private var feedTitle: String = ""
    
    @State private var hasFetchResult: Bool = false
    @State private var isSelected: Bool = false

    init(rssViewModel: RSSFeedViewModel) {
        self.rssFeedViewModel = rssViewModel
    }
    
    var body: some View {
        
        Form {
            Text(rssSource.title).font(.system(size: 18, weight: .medium, design: .rounded))
            HStack{
                KFImage(URL(string: rssSource.imageURL))
                    .placeholder({
                        Image("Thumbnail")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50,alignment: .center)
                            .cornerRadius(5)
                            .border(Color.clear, width: 1)
                            .multilineTextAlignment(.center)

                    })
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50,alignment: .center)
                    .cornerRadius(5)
                    .border(Color.clear, width: 1)
                    .multilineTextAlignment(.center)

            Text(rssSource.desc)
                    
            }

            Section(header: Text("date added")) {
                Text(rssSource.createTimeStr)
                }
            Section(header: Text("Feed URL")) {
                Text(rssSource.url)
                }
            Section(header: Text("Image URL")) {
                Text(rssSource.imageURL)
                }
            HStack {
                Image(systemName: "safari")
                    .fixedSize()
                ForEach([InfoItem.webView], id: \.self) { _ in
                        Toggle("Reader View", isOn: self.$isSelected)
                    }.toggleStyle(SwitchToggleStyle(tint: .blue))
                }
            }
            .navigationBarTitle(rssSource.title)
            .navigationBarItems(leading:
                Button(action: {
                print("dismisses form")
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
            })
        }
    }

struct InfoView_Previews: PreviewProvider {
    static let rssFeedViewModel = RSSFeedViewModel(rss: RSS.simple(), dataSource: DataSourceService.current.rssItem)
    static var previews: some View {
        InfoView(rssViewModel: self.rssFeedViewModel)
    }
}
