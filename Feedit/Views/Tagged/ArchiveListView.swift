//
//  ArchiveListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//  BOOKMARKS Screen
//

import SwiftUI
import Intents

struct ArchiveListView: View {
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var archiveListViewModel: ArchiveListViewModel
    
    @State private var selectedItem: RSSItem?
    @State var footer = "Refresh more articles"
    
    init(viewModel: ArchiveListViewModel, rssFeedViewModel: RSSFeedViewModel) {
        self.archiveListViewModel = viewModel
        self.rssFeedViewModel = rssFeedViewModel
    }
    
    
    var body: some View {
            List {
                ForEach(self.archiveListViewModel.items, id: \.self) { item in
                    RSSItemRow(wrapper: item)
                        .onTapGesture {
                            self.selectedItem = item

                    }
                    
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        let item = self.archiveListViewModel.items[index]
                        self.archiveListViewModel.unarchive(item)
                    }
                }
                //VStack(alignment: .center) {
                    Button(action: self.archiveListViewModel.loadMore) {
                        HStack(alignment: .center){
                            //Spacer()
                            Image(systemName: "arrow.counterclockwise")
                                .imageScale(.small)
                            Text(self.footer)
                                .font(.subheadline)
                                .fontWeight(.bold)

                        }
                    }
                    .padding(.leading)
                //}
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Starred", displayMode: .automatic) //☆
            .navigationBarItems(trailing: EditButton())

            .sheet(item: $selectedItem, content: { item in
                if AppEnvironment.current.useSafari {
                    SafariView(url: URL(string: item.url)!)
                } else {
                    WebView(
                        rssViewModel: rssFeedViewModel, wrapper: item, rss: RSS.simple(), rssItem: item,
                        onArchiveAction: {
                            self.archiveListViewModel.archiveOrCancel(item)
                    })
                }
            })
            
            .onAppear {
                 UITableView.appearance().separatorStyle = .none
                
                self.archiveListViewModel.fecthResults()
        }
    }
}

extension ArchiveListView {
    
}

//struct ArchiveListView_Previews: PreviewProvider {
//
//    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
//
//    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
//
//    static let rssFeedViewModel = RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem)
//
//    static let settingViewModel = SettingViewModel()
//
//    static var previews: some View {
//
//    ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: self.rssFeedViewModel)
//    }
//}

