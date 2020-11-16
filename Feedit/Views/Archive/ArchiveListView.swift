//
//  ArchiveListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//  BOOKMARKS Screen
//

import SwiftUI
import WidgetKit
import Intents

struct ArchiveListView: View {
    
    @ObservedObject var archiveListViewModel: ArchiveListViewModel
    
    @State private var selectedItem: RSSItem?
    @State var footer = "Load more articles"
    
    init(viewModel: ArchiveListViewModel) {
        self.archiveListViewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
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
                VStack(alignment: .center) {
                    Button(action: self.archiveListViewModel.loadMore) {
                        Text(self.footer)
//                            .font(.custom("Gotham", size: 14))
                    }
                }
            }
            .sheet(item: $selectedItem, content: { item in
                if AppEnvironment.current.useSafari {
                    SafariView(url: URL(string: item.url)!)
                } else {
                    WebView(
                        rssItem: item,
                        onArchiveAction: {
                            self.archiveListViewModel.archiveOrCancel(item)
                    })
                }
            })
            .onAppear {
                self.archiveListViewModel.fecthResults()
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Tagged Articles", displayMode: .automatic)
//            .font(.custom("Gotham", size: 14))
            //.environment(\.horizontalSizeClass, .regular)
            .navigationBarItems(trailing: EditButton())
        }
    }
}

extension ArchiveListView {
    
}

struct ArchiveListView_Previews: PreviewProvider {
    
//    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    
static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

static let settingViewModel = SettingViewModel()

static var previews: some View {
    ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
    }
}
//archiveListViewModel: self.archiveListViewModel,

