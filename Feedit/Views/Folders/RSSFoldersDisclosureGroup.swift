//
//  RSSFoldersDisclosureGroup.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/14/21.
//

import SwiftUI
import CoreData
import Foundation
import os.log

struct RSSFoldersDisclosureGroup: View {
    static var fetchRequest: NSFetchRequest<RSSGroup> {
      let request: NSFetchRequest<RSSGroup> = RSSGroup.fetchRequest()
      request.sortDescriptors = [NSSortDescriptor(keyPath: \RSSGroup.name, ascending: true)]
      return request
    }
    @ObservedObject var persistence: Persistence
    @FetchRequest(
      fetchRequest: RSSGroupListView.fetchRequest,
      animation: .default)
    var groups: FetchedResults<RSSGroup>
    @AppStorage("darkMode") var darkMode = false
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var viewModel: RSSListViewModel
    let rss: [RSS] = []
    
    @State var revealFoldersDisclosureGroup = true
    @StateObject private var expansionHandler = ExpansionHandler<ExpandableSection>()
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $revealFoldersDisclosureGroup, content: {
            ForEach(groups, id: \.id) { group in
                DisclosureGroup {
                    ForEach(viewModel.items, id: \.self) { rss in
                        ZStack {
                            NavigationLink(destination: self.destinationView(rss: rss)) {
                                EmptyView()
                            }
                            .opacity(0.0)
                            .buttonStyle(PlainButtonStyle())
                            HStack {
                                RSSRow(rss: rss)
                                Spacer()
                                Text("\(viewModel.items.count)")
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
                    }.listRowBackground(Color("accent"))
                } label: {
                    HStack {
                        Image(systemName: "folder").foregroundColor(Color("tab"))
                        Text("\(group.name ?? "Untitled")")
                        Spacer()
                        Text("\(group.itemCount)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 1)
                            .background(Color.gray.opacity(0.5))
                            .opacity(0.4)
                            .foregroundColor(Color("text"))
                            .cornerRadius(8)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation { self.expansionHandler.toggleExpanded(for: .section) }
                            }
                        }
                }
//                ZStack {
//                    NavigationLink(destination: RSSGroupDetailsView(viewModel: self.viewModel, rssGroup: group, groups: groups)) {
//                        EmptyView()
//                    }
//                    .opacity(0.0)
//                    .buttonStyle(PlainButtonStyle())
//                    HStack {
//                        Label("\(group.name ?? "Untitled")", systemImage: "folder").accentColor(Color("tab"))
//                        Spacer()
//                        Text("\(group.itemCount)")
//                            .font(.caption)
//                            .fontWeight(.bold)
//                            .padding(.horizontal, 7)
//                            .padding(.vertical, 1)
//                            .background(Color.gray.opacity(0.5))
//                            .opacity(0.4)
//                            .foregroundColor(Color("text"))
//                            .cornerRadius(8)
//                        }
//                    }
//                    .listRowBackground(Color("accent"))
                }
                .onDelete(perform: deleteObjects)
            .listRowBackground(Color("accent"))
                },
                label: {
                    HStack {
                        Text("Folders")
                            .font(.system(size: 18, weight: .medium, design: .rounded)).listRowBackground(Color("accent"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    self.revealFoldersDisclosureGroup.toggle()
                                }
                            }
                    }
                    
                })
            .listRowBackground(Color("darkerAccent"))
            .accentColor(Color("tab"))
            }
//    }
    private func deleteObjects(offsets: IndexSet) {
      withAnimation {
        persistence.deleteManagedObjects(offsets.map { groups[$0] })
      }
    }
    private func destinationView(rss: RSS) -> some View {
        let item = RSSItem()
        return RSSFeedListView(viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), wrapper: item, filter: .all)
            .environmentObject(DataSourceService.current.rss)
    }
}

#if DEBUG
struct RSSFoldersDisclosureGroup_Previews: PreviewProvider {
    static let rss = RSS()
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static var previews: some View {
        RSSFoldersDisclosureGroup(persistence: Persistence.current, viewModel: self.viewModel)
          .environment(\.managedObjectContext, Persistence.current.context)
          .environmentObject(Persistence.current)
            .preferredColorScheme(.dark)
    }
}
#endif
