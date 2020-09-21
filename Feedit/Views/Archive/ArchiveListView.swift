//
//  ArchiveListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import WidgetKit
import Intents

struct ArchiveListView: View {
    
    @ObservedObject var viewModel: ArchiveListViewModel
    
    @State private var selectedItem: RSSItem?
    @State var footer = "more"
    
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
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Read Later", displayMode: .inline)
            .environment(\.horizontalSizeClass, .regular)
        }
    }
}


extension ArchiveListView {
}

struct ArchiveListView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
            .previewDevice("iPhone 11 Pro Max")
            .preferredColorScheme(.dark)
            
    }
}

