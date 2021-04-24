//
//  UnreadListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/17/21.
//

import SwiftUI
import CoreData
import Combine
import Foundation
import os.log
import Intents
import MobileCoreServices
import KingfisherSwiftUI

struct UnreadListView: View {
    @EnvironmentObject private var persistence: Persistence
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var rssDataSource: RSSDataSource
    
    @EnvironmentObject var rss: RSS
    @ObservedObject var unreads: Unread
    
    @ObservedObject var searchBar: SearchBar = SearchBar()
    @StateObject var rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    
    @State private var selectedItem: RSSItem?
    @State private var footer = "Load More Articles"
    @State private var disabled = true
    
    init(unreads: Unread, selectedFilter: FilterType) {
        self.unreads = unreads
        self.selectedFilter = selectedFilter
    }
    
    @State var selectedFilter: FilterType
    private var navButtons: some View {
        HStack(alignment: .center, spacing: 30) {
            Toggle(isOn: $rssFeedViewModel.unreadIsOn) { Text("") }
                .toggleStyle(CheckboxStyle()).padding(.leading)
            Spacer(minLength: 1)
            
            Picker("", selection: $selectedFilter, content: {
                ForEach(FilterType.allCases, id: \.self) {
                    Text($0.rawValue)
                }
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
//                    ForEach(unreads.filteredPosts.indices, id: \.self) { index in
//                        ZStack {
//                            Button(action: {
//                                self.unreads.showingDetail = true
//                                self.unreads.selectPost(index: index)
//                            })  {
//                                RSSItemRow(rssItem: self.unreads.filteredPosts[index], menu: self.contextmenuAction(_:), rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
//                            }
//                        }
//                    }
                    ForEach(unreads.items, id: \.self) { unread in
                        ZStack {
                            NavigationLink(destination: WebView(rssItem: unread, onCloseClosure: {})) {

                                EmptyView()
                            }
                            .opacity(0.0)
                            .buttonStyle(PlainButtonStyle())

                            HStack {
                                RSSItemRow(rssItem: unread, menu: self.contextmenuAction(_:), rssFeedViewModel: RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem))
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        self.selectedItem = unread
                                }
                            }
                        }
                    }
                }
                .animation(.default)
                .add(self.searchBar)
                .accentColor(Color("tab"))
                .listRowBackground(Color("accent"))
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarItems(trailing:
                                        Button(action: {
                                            unreads.items.forEach { (unread) in
                                                unread.isRead = true
                                                unreads.items.removeAll()
                                                saveContext()
                                            }
                                        }) {
                                            Image(systemName: "checkmark.circle").font(.system(size: 18)).foregroundColor(Color("tab"))
                                        }
                )
            }
            Spacer()
            navButtons
                .frame(width: UIScreen.main.bounds.width, height: 49)
                .toolbar{
                    ToolbarItem(placement: .principal) {
                        HStack{
                            Image(systemName: "largecircle.fill.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 21, height: 21,alignment: .center)
                                .foregroundColor(Color("tab").opacity(0.9))
                            Text("Unread")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                            Text("\(unreads.items.count)")
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
                .sheet(item: $selectedItem, content: { item in
                    if UserEnvironment.current.useSafari {
                        SafariView(url: URL(string: item.url)!)
                    } else {
                        WebView(
                            rssItem: item,
                            onCloseClosure: {
                                self.selectedItem = nil
                            },
                            onArchiveClosure: {
                                self.unreads.archiveOrCancel(item)
                            }
                        )
                    }
                })
                .onAppear {
                    self.unreads.fecthResults()
                }
        }
    }
    private func saveContext() {
        do {
            try Persistence.current.context.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved Error: \(error)")
        }
    }
    func contextmenuAction(_ item: RSSItem) {
        unreads.archiveOrCancel(item)
    }
}

struct UnreadListView_Previews: PreviewProvider {
    static let rss = RSS()
    static var previews: some View {
        NavigationView {
            UnreadListView(unreads: Unread(dataSource: DataSourceService.current.rssItem), selectedFilter: .unreadIsOn)
        }.preferredColorScheme(.dark)
    }
}
