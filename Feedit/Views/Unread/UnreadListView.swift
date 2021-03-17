//
//  UnreadListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/17/21.
//

import SwiftUI
import CoreData
import Foundation
import os.log

struct UnreadListView: View {
    @ObservedObject var unread: Unread
    
    @State private var selectedItem: RSSItem?
    @State var footer = "load more"
    
    init(unread: Unread) {
        self.unread = unread
    }
    
    var body: some View {
        List {
            ForEach(unread.items, id: \.self) { unread in
                RSSItemRow(wrapper: unread, rssFeedViewModel: RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem))
                    .onTapGesture {
                        self.selectedItem = unread
                }
            }
            VStack(alignment: .center) {
                Button(action: self.unread.loadMore) {
                    Text(self.footer)
                }
            }
        }
        .onAppear {
            self.unread.fecthResults()
        }
    }
}

struct UnreadListView_Previews: PreviewProvider {
    static var previews: some View {
        UnreadListView(unread: Unread(dataSource: DataSourceService.current.rssItem))
    }
}
