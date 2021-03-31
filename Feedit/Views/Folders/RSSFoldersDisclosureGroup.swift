//
//  RSSFoldersDisclosureGroup.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/14/21.
//

import SwiftUI
import CoreData
import Combine
import Foundation
import os.log

struct RSSFoldersDisclosureGroup: View {
    static var fetchRequest: NSFetchRequest<RSSGroup> {
      let request: NSFetchRequest<RSSGroup> = RSSGroup.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RSSGroup.items, ascending: true)]
      return request
    }
    
    @FetchRequest(
      fetchRequest: RSSGroupListView.fetchRequest,
      animation: .default)
    var groups: FetchedResults<RSSGroup>
    
    @ObservedObject var persistence: Persistence
    @ObservedObject var unread: Unread
    @EnvironmentObject var rssDataSource: RSSDataSource
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject var viewModel: RSSListViewModel
//    let rss = RSS()
    
    @State var isExpanded = false
    @State private var expandFolders = false
    var filteredArticles: [RSSItem] {
        return rssFeedViewModel.items.filter({ (item) -> Bool in
            return !((self.rssFeedViewModel.isOn && !item.isArchive) || (self.rssFeedViewModel.unreadIsOn && item.isRead))
        })
    }
    @ObservedObject var rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @FetchRequest(sortDescriptors: [])
    private var rss: FetchedResults<RSS>
    
    var body: some View {
        Section(header: Text("Folders").font(.system(size: 18, weight: .regular, design: .rounded)).textCase(nil).foregroundColor(Color("text"))) {
//        DisclosureGroup(
//            isExpanded: $expandFolders,
//            content: {
            ForEach(groups, id: \.id) { group in
                DisclosureGroup {
//                HStack {
//                    VStack{
//                        Image(systemName: isExpanded == true ? "chevron.down" : "chevron.right").font(.system(size: 16, weight: .semibold, design: .rounded))
//                            .foregroundColor(Color.gray).opacity(0.9)
//                    }
//                    .animation(.easeOut(duration: 0.40))
//                    .onTapGesture {
//                        self.isExpanded.toggle()
//                    }
//                    .onReceive([self.isExpanded].publisher.first()) { (value) in
//                            print("New value is: \(value)")
//                    }
//
//                    Text("\(group.name ?? "Untitled")")
//                    Spacer()
//                    UnreadCountView(count: group.itemCount)
//                        .contentShape(Rectangle())
//                    }
                
//                if isExpanded == true {
                    ForEach(viewModel.items, id: \.self) { rss in
                        ZStack {
                            NavigationLink(destination: self.destinationView(rss: rss)
                            ) {
                                EmptyView()
                            }
                            .opacity(0.0)
                            .buttonStyle(PlainButtonStyle())
                            HStack {
                                RSSRow(rss: rss, viewModel: viewModel)
                                    
                                Spacer()
                                if filteredArticles.filter { !$0.isRead }.count == 0 {
                                    Text("")
                                } else {
                                    UnreadCountView(count: filteredArticles.filter { !$0.isRead }.count)
                                }
//                                if viewModel.unreadCount > 0 {
//                                    UnreadCountView(count: viewModel.unreadCount)
//                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }//.listRowBackground(Color("accent"))
                    }.onDelete(perform: delete)
                    //.onDelete { indexSet in
//                        if let index = indexSet.first {
//                            self.viewModel.delete(at: index)
//                        }
//                    }
                } label: {
                    HStack {
                        if group.itemCount > 0 {
                            UnreadCountView(count: Int(group.itemCount))
                                .contentShape(Rectangle())
                        }
                        Text("\(group.name ?? "Untitled")")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    self.isExpanded.toggle()
                                }
                            }
                        
                    }
                }.accentColor(Color.gray.opacity(0.7))//.listRowBackground(Color("accent"))
            }.onDelete(perform: deleteObjects)
        }.accentColor(Color("tab"))
//        },
//            label: {
//                HStack {
//                    Text("Folders")
//                        .font(.system(size: 18, weight: .regular, design: .rounded)).textCase(nil)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            withAnimation {
//                                self.expandFolders.toggle()
//                            }
//                        }
//                }
//            })
//            .listRowBackground(Color("accent")) // MARK: - CLEAR BACKGROUND
//            .listRowBackground(Color("darkerAccent")) // MARK: - DARK SHADE
//        .accentColor(Color("tab"))
        .onAppear {
            self.viewModel.fecthResults()
        }
    }
    

    private func deleteObjects(offsets: IndexSet) {
        withAnimation {
            persistence.deleteManagedObjects(offsets.map { groups[$0] })
        }
    }
    private func delete(offsets: IndexSet) {
        withAnimation {
            offsets.map { viewModel.items[$0] }.forEach(Persistence.current.context.delete)
            saveContext()
        }
    }
    private func updateRSS(_ rss: FetchedResults<RSS>.Element) {
        withAnimation {
            rss.itemCount = Int64(rssFeedViewModel.items.count)
            saveContext()
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
    private func destinationView(rss: RSS) -> some View {
        let item = RSSItem()
        return RSSFeedListView(rss: rss, viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), rssItem: item, filter: .all)
            .environmentObject(DataSourceService.current.rss)
    }
}

#if DEBUG
struct RSSFoldersDisclosureGroup_Previews: PreviewProvider {
    static let rss = RSS()
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static let unread = Unread(dataSource: DataSourceService.current.rssItem)

    static var previews: some View {
        NavigationView {
            List {
                RSSFoldersDisclosureGroup(persistence: Persistence.current, unread: unread, viewModel: self.viewModel, isExpanded: false)
                    
                    .environment(\.managedObjectContext, Persistence.current.context)
                    .environmentObject(Persistence.current)
                    .preferredColorScheme(.dark)
            }.listStyle(SidebarListStyle())
        }
    }
}
#endif
