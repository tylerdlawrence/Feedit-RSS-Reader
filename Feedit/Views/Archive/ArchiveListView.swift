//
//  ArchiveListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//  BOOKMARKS Screen
//  TODO: correct issue w/ action button only viewing 'Bookmark' - not showing 'Removing Bookmark'

import SwiftUI
import WidgetKit
import Intents

struct ArchiveListView: View {
    
    @ObservedObject var viewModel: ArchiveListViewModel
    
    @State private var selectedItem: RSSItem?
    @State var footer = "Refresh"
    
    init(viewModel: ArchiveListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.viewModel.items, id: \.self) { item in
                    RSSItemRow(wrapper: item)
                        .onTapGesture {
                            self.selectedItem = item

                    }
                    
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        let item = self.viewModel.items[index]
                        self.viewModel.unarchive(item)
                    }
                }
                VStack(alignment: .center) {
                    Button(action: self.viewModel.loadMore) {
                        Text(self.footer)
                            .font(.custom("Gotham", size: 16))
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
                            self.viewModel.archiveOrCancel(item)
                    })
                }
            })
            .onAppear {
                self.viewModel.fecthResults()
            }
            .listStyle(InsetGroupedListStyle()
                        )
            .navigationBarTitle("Bookmarked", displayMode: .automatic)
            .font(.custom("Gotham", size: 20))
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarItems(trailing: EditButton())
        }
    }
}

extension ArchiveListView {
    
}

struct ArchiveListView_Previews: PreviewProvider {
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static var previews: some View {
        RSSListView(viewModel: self.viewModel)
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 12 mini")
            
    }
}

