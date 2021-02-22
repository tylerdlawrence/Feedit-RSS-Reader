//
//  ArchiveListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//
//

import SwiftUI
import UIKit
import KingfisherSwiftUI
import Intents
import SwipeCell

struct ArchiveListView: View {
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var archiveListViewModel: ArchiveListViewModel
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    @State private var selectedItem: RSSItem?
    @State var footer = "Load More Articles"
    
    @State private var sortAscending: Bool = true
    @State var isRead: Bool = false
    
    init(viewModel: ArchiveListViewModel) {
        self.archiveListViewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color("accent")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            List {
                ForEach(self.archiveListViewModel.items, id: \.self) { item in
                    ZStack{
                        NavigationLink(destination: WebView(rssItem: item, onCloseClosure: {})) {
                            EmptyView()
                        }
                        .opacity(0.0)
                        .buttonStyle(PlainButtonStyle())
                        
                        HStack{
                            RSSItemRow(wrapper: item)
                                .onTapGesture {
                                    self.selectedItem = item
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            let item = self.archiveListViewModel.items[index]
                            self.archiveListViewModel.unarchive(item)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("", displayMode: .inline)
            .add(self.searchBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack{
                        HStack{
                            Text("Starred")
                                .font(.system(.body))
                                .fontWeight(.bold)
                            Text("\(archiveListViewModel.items.count)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 1)
                                .background(Color.gray.opacity(0.5))
                                .opacity(0.4)
                                .foregroundColor(Color("text"))
                                .cornerRadius(8)
                        }
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Image(systemName: (sortAscending ? "arrow.down" : "arrow.up"))
                        .foregroundColor(Color("tab"))
                        .onTapGesture(perform: self.onToggleSort )
                                    
                    }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                                    
                    }
                ToolbarItem(placement: .bottomBar) {
                            
                    Toggle("", isOn: $isRead)
                        .toggleStyle(CheckboxStyle())
                }
            }
            .sheet(item: $selectedItem, content: { item in
                if UserEnvironment.current.useSafari {
                    SafariView(url: URL(string: item.url)!)
                } else {
                    WebView(
                        rssItem: item,
                        onCloseClosure: {

                        },
                        onArchiveClosure: {
                            self.archiveListViewModel.archiveOrCancel(item)
                    })
                }
            })
            .onAppear {
                self.archiveListViewModel.fecthResults()
        }
    }
}

extension ArchiveListView {
    public func onToggleSort() {
        self.sortAscending.toggle()
    }
}

struct ArchiveListView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
    }
}

