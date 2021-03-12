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
import MobileCoreServices

struct ArchiveListView: View {
    @ObservedObject var archiveListViewModel: ArchiveListViewModel
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    @State private var selectedItem: RSSItem?
    @State var footer = "Load More Articles"
    
    @State private var disabled = true
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
                
                VStack(alignment: .center) {
                    Button(action: self.archiveListViewModel.loadMore) {
                        HStack {
                            Text(self.footer).font(.system(size: 18, weight: .medium, design: .rounded))
                            Spacer()
                            Image(systemName: "arrow.down.circle").font(.system(size: 18, weight: .medium, design: .rounded))
                        }.foregroundColor(Color("bg"))
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
                        Toggle("", isOn: $isRead)
                            .toggleStyle(CheckboxStyle())
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Toggle(isOn: $archiveListViewModel.isArchive) { Text("") }
                            .toggleStyle(StarStyle())
                            .disabled(self.disabled)
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
        }.animation(.default)
            .onAppear {
                self.archiveListViewModel.fecthResults()
        }
    }
}

extension ArchiveListView {
}

//struct ArchiveListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
//    }
//}
