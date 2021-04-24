//
//  ArchiveListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//
//

import SwiftUI
import Introspect
import Combine
import WebKit
import CoreData
import UIKit
import KingfisherSwiftUI
import Intents
import MobileCoreServices

struct ArchiveListView: View {
    @ObservedObject var archiveListViewModel: ArchiveListViewModel
    @ObservedObject var searchBar: SearchBar = SearchBar()
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    
    @State private var selectedItem: RSSItem?
    @State var footer = "Load More Articles"
    
    @State private var disabled = true
    @State var isRead: Bool = false
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
        
    init(viewModel: ArchiveListViewModel, rssFeedViewModel: RSSFeedViewModel, selectedFilter: FilterType) {
        self.archiveListViewModel = viewModel
        self.rssFeedViewModel = rssFeedViewModel
        self.selectedFilter = selectedFilter
    }
    
    private var refreshButton: some View {
        Button(action: self.archiveListViewModel.loadMore) {
            Image(systemName: "arrow.clockwise").font(.system(size: 16, weight: .bold)).foregroundColor(Color("tab")).padding()
        }.buttonStyle(BorderlessButtonStyle())
    }
    
    @State var selectedFilter: FilterType
    @State var isShowing: Bool = false
    private var navButtons: some View {
        HStack(alignment: .center, spacing: 30) {
            Toggle(isOn: $rssFeedViewModel.unreadIsOn) { Text("") }
                .toggleStyle(CheckboxStyle()).padding(.leading)
//        }
            Spacer(minLength: 1)
            
            Picker("", selection: $selectedFilter, content: {
                ForEach(FilterType.allCases, id: \.self) {
                    Text($0.rawValue)
                }
//                SelectedFilterView(selectedFilter: selectedFilter)
            }).pickerStyle(SegmentedPickerStyle()).frame(width: 180, height: 20)
            .listRowBackground(Color("accent"))
            
            Spacer(minLength: 0)
            
            Toggle(isOn: $rssFeedViewModel.isOn) { Text("") }
                .toggleStyle(StarStyle()).padding(.trailing)
        }
    }
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ZStack {
                List {
                    ForEach(self.archiveListViewModel.items, id: \.self) { item in
                        ZStack {
                            NavigationLink(destination: WebView(rssItem: item, onCloseClosure: {})) {
                                
                                EmptyView()
                            }
                            .opacity(0.0)
                            .buttonStyle(PlainButtonStyle())
                            
                            HStack {
                                RSSItemRow(rssItem: item, rssFeedViewModel: rssFeedViewModel)
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
                .listStyle(PlainListStyle())
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarItems(trailing:
                                        Button(action: {
                                            archiveListViewModel.items.forEach { (item) in
                                                item.isRead = true
                                                archiveListViewModel.items.removeAll()
                                            }
                                        }) {
                                            Image(systemName: "checkmark.circle").font(.system(size: 18)).foregroundColor(Color("tab"))
                                        }
                )
            }
//            .pullToRefresh(isShowing: $isShowing) {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    self.isShowing = false
//                    archiveListViewModel.fecthResults()
//                }
//            }
            Spacer()
            navButtons
                .frame(width: UIScreen.main.bounds.width, height: 49)
                .add(self.searchBar)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack{
                            HStack{
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 18, height: 18,alignment: .center)
                                    .foregroundColor(Color("tab").opacity(0.9))
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
//            }
//            Spacer()
//            navButtons
//                .frame(width: UIScreen.main.bounds.width, height: 49)
        }
        .onAppear {
            self.archiveListViewModel.fecthResults()
        }
    }
}

extension ArchiveListView {
}

struct ArchiveListView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem), selectedFilter: .isArchive)
            .preferredColorScheme(.dark)
    }
}
