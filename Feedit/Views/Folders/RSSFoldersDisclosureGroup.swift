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

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        sorted { a, b in
            a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}

extension Sequence {
    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        using comparator: (T, T) -> Bool = (<)
    ) -> [Element] {
        sorted { a, b in
            comparator(a[keyPath: keyPath], b[keyPath: keyPath])
        }
    }
}

enum SortOrder {
    case ascending
    case descending
}

struct SortDescriptor<Value> {
    var comparator: (Value, Value) -> ComparisonResult
}

extension SortDescriptor {
    static func keyPath<T: Comparable>(_ keyPath: KeyPath<Value, T>) -> Self {
        Self { rootA, rootB in
            let valueA = rootA[keyPath: keyPath]
            let valueB = rootB[keyPath: keyPath]

            guard valueA != valueB else {
                return .orderedSame
            }

            return valueA < valueB ? .orderedAscending : .orderedDescending
        }
    }
}

extension Sequence {
    func sorted(using descriptors: [SortDescriptor<Element>],
                order: SortOrder) -> [Element] {
        sorted { valueA, valueB in
            for descriptor in descriptors {
                let result = descriptor.comparator(valueA, valueB)

                switch result {
                case .orderedSame:
                    // Keep iterating if the two elements are equal,
                    // since that'll let the next descriptor determine
                    // the sort order:
                    break
                case .orderedAscending:
                    return order == .ascending
                case .orderedDescending:
                    return order == .descending
                }
            }

            // If no descriptor was able to determine the sort
            // order, we'll default to false (similar to when
            // using the '<' operator with the built-in API):
            return false
        }
    }
}

extension Sequence {
    func sorted(using descriptors: SortDescriptor<Element>...) -> [Element] {
        sorted(using: descriptors, order: .ascending)
    }
}


struct RSSFoldersDisclosureGroup: View {
    @AppStorage("darkMode") var darkMode = false
    
    static var fetchRequest: NSFetchRequest<RSSGroup> {
      let request: NSFetchRequest<RSSGroup> = RSSGroup.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RSSGroup.items, ascending: true)]
      return request
    }
    @ObservedObject var persistence: Persistence
    @FetchRequest(
      fetchRequest: RSSGroupListView.fetchRequest,
      animation: .default)
    var groups: FetchedResults<RSSGroup>
    @ObservedObject var unread: Unread
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var viewModel: RSSListViewModel
    let rss = RSS()
    
    @State var revealFoldersDisclosureGroup = false
    @StateObject private var expansionHandler = ExpansionHandler<ExpandableSection>()
    
    
    
    var body: some View {
//        DisclosureGroup(
//            isExpanded: $revealFoldersDisclosureGroup, content: {
        Section(header: Text("Folders").font(.system(size: 20, weight: .medium, design: .rounded)).textCase(nil).foregroundColor(Color("text"))) {
                ForEach(groups, id: \.id) { group in
                    DisclosureGroup {
//                    Section(header: Text("\(group.name ?? "Untitled")")){
                    ForEach(viewModel.items) { rss in
                        ZStack {
                            NavigationLink(destination: self.destinationView(rss: rss)) {
                                EmptyView()
                            }
                            .opacity(0.0)
                            .buttonStyle(PlainButtonStyle())
                            HStack {
                                FeedRow(rss: rss, viewModel: viewModel, unread: unread)
                                Spacer()
                                Text("\(unread.items.count)")
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
//                    .listRowBackground(Color("accent"))
                }
                    label: {
                    HStack {
                        Image(systemName: "folder")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 23, height: 23,alignment: .center)
                            .foregroundColor(Color("tab").opacity(0.9))
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
                    }.accentColor(Color.gray.opacity(0.8))

            }
            .onDelete(perform: deleteObjects)
//            .listRowBackground(Color("accent"))
//            },
//            label: {
//                HStack {
//                    Text("Folders")
//                        .font(.system(size: 14, weight: .regular, design: .rounded)).textCase(.uppercase)
////                        .font(.system(size: 20, weight: .semibold, design: .rounded)).listRowBackground(Color("accent"))
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            withAnimation {
//                                self.revealFoldersDisclosureGroup.toggle()
//                            }
//                        }
//                        .listRowBackground(Color("accent"))
//                    }.listRowBackground(Color("accent"))
//            })
//                .listRowBackground(Color("darkerAccent"))
            }
                .accentColor(Color("tab"))
        }
    
    private func deleteObjects(offsets: IndexSet) {
      withAnimation {
        persistence.deleteManagedObjects(offsets.map { groups[$0] })
      }
    }
    
    private func destinationView(rss: RSS) -> some View {
        let item = RSSItem()
        return RSSFeedListView(rss: rss, viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), rssItem: item, filter: .all)
            .environmentObject(DataSourceService.current.rss)
    }
    private var dropdownView: some View {
        ForEach(groups) { group in
            Section(header: Text(group.name ?? "No Feeds")) {
                ForEach(viewModel.items) { rss in
                    NavigationLink(destination: self.destinationView(rss: rss)) {
                        RSSRow(rss: rss, viewModel: viewModel)
                    }
                }
            }
        }
    }
}

//#if DEBUG
//struct RSSFoldersDisclosureGroup_Previews: PreviewProvider {
//    static let rss = RSS()
//    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
//    static let unread = Unread(dataSource: DataSourceService.current.rssItem)
//    static var previews: some View {
//        RSSFoldersDisclosureGroup(persistence: Persistence.current, unread: unread, viewModel: self.viewModel)
//          .environment(\.managedObjectContext, Persistence.current.context)
//          .environmentObject(Persistence.current)
//            .preferredColorScheme(.dark)
//    }
//}
//#endif


struct ContentCell: View {
    static var fetchRequest: NSFetchRequest<RSSGroup> {
      let request: NSFetchRequest<RSSGroup> = RSSGroup.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RSSGroup.items, ascending: true)]
      return request
    }
    @ObservedObject var persistence: Persistence
    @FetchRequest(
      fetchRequest: RSSGroupListView.fetchRequest,
      animation: .default)
    var groups: FetchedResults<RSSGroup>
    @ObservedObject var unread: Unread
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var viewModel: RSSListViewModel
    let rss = RSS()
    
//    let isExpanded: Bool
    @State var isExpanded = false
    
    
    var body: some View {
        
        Section(header: Text("Folders").font(.system(size: 20, weight: .medium, design: .rounded)).textCase(nil).foregroundColor(Color("text"))) {
//            ForEach(groups.indexed(), id: \.1.id) { index, group in
            ForEach(groups, id: \.id) { group in
                HStack {
                    VStack{
                        Image(systemName: isExpanded == true ? "chevron.down" : "chevron.right").font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.gray).opacity(0.9)
                    }
                    .animation(.easeOut(duration: 0.40))
                    .onTapGesture {
                        self.isExpanded.toggle()
                    }
                    .onReceive([self.isExpanded].publisher.first()) { (value) in
                            print("New value is: \(value)")
                       }
                    
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
                    }
                
//                if isExpanded {
                if isExpanded == true {
                    ForEach(viewModel.items, id: \.self) { rss in
                        ZStack {
                            NavigationLink(destination: self.destinationView(rss: rss)) {
                                EmptyView()
                            }
                            .opacity(0.0)
                            .buttonStyle(PlainButtonStyle())
                            HStack {
                                FeedRow(rss: rss, viewModel: viewModel, unread: unread)
                                Spacer()
                                Text("\(unread.items.count)")
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
            }.onDelete(perform: deleteObjects)
        }
    }
    private func deleteObjects(offsets: IndexSet) {
      withAnimation {
        persistence.deleteManagedObjects(offsets.map { groups[$0] })
        }
    }
    private func destinationView(rss: RSS) -> some View {
        let item = RSSItem()
        return RSSFeedListView(rss: rss, viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), rssItem: item, filter: .all)
            .environmentObject(DataSourceService.current.rss)
    }
}

#if DEBUG
struct ContentCell_Previews: PreviewProvider {
    static let rss = RSS()
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static let unread = Unread(dataSource: DataSourceService.current.rssItem)
    static var previews: some View {
        NavigationView {
            List {
                ContentCell(persistence: Persistence.current, unread: unread, viewModel: self.viewModel, isExpanded: false)
                    .environment(\.managedObjectContext, Persistence.current.context)
                    .environmentObject(Persistence.current)
                    .preferredColorScheme(.dark)
            }.listStyle(SidebarListStyle())
        }
    }
}
#endif

extension ForEach where Data.Element: Hashable, ID == Data.Element, Content: View {
    init(values: Data, content: @escaping (Data.Element) -> Content) {
        self.init(values, id: \.self, content: content)
    }
}

struct IndexedCollection<Base: RandomAccessCollection>: RandomAccessCollection {
    typealias Index = Base.Index
    typealias Element = (index: Index, element: Base.Element)

    let base: Base

    var startIndex: Index { base.startIndex }

    var endIndex: Index { base.endIndex }

    func index(after i: Index) -> Index {
        base.index(after: i)
    }

    func index(before i: Index) -> Index {
        base.index(before: i)
    }

    func index(_ i: Index, offsetBy distance: Int) -> Index {
        base.index(i, offsetBy: distance)
    }

    subscript(position: Index) -> Element {
        (index: position, element: base[position])
    }
}

extension RandomAccessCollection {
    func indexed() -> IndexedCollection<Self> {
        IndexedCollection(base: self)
    }
}
