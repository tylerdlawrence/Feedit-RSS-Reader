//
//  RSSGroupListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/14/21.
//

import SwiftUI
import CoreData
import Foundation
import os.log

struct RSSGroupListView: View {
    static var fetchRequest: NSFetchRequest<RSSGroup> {
      let request: NSFetchRequest<RSSGroup> = RSSGroup.fetchRequest()
      request.sortDescriptors = [NSSortDescriptor(keyPath: \RSSGroup.name, ascending: true)]
      return request
    }
    @ObservedObject var persistence: Persistence
    @FetchRequest(
      fetchRequest: RSSGroupListView.fetchRequest,
      animation: .default)
    private var groups: FetchedResults<RSSGroup>
    
//    @AppStorage("darkMode") var darkMode = false
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var viewModel: RSSListViewModel
    @State var addGroupIsPresented = false
    
    var body: some View {
        VStack {
          List {
            ForEach(groups, id: \.id) { group in
                ZStack{
                    NavigationLink(destination: RSSGroupDetailsView(viewModel: self.viewModel, rssGroup: group, groups: groups)) {
                        EmptyView()
                    }
                    .opacity(0.0)
                    .buttonStyle(PlainButtonStyle())
                    
                    HStack {
                        Label("\(group.name ?? "Untitled")", systemImage: "folder").accentColor(Color("tab"))
                        Spacer()
                        Text("\(group.itemCount)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 1)
                            .background(Color.gray.opacity(0.5))
                            .opacity(0.4)
                            .cornerRadius(8)
                        }
                }
            }
            .onDelete(perform: deleteObjects)
          }
          .sheet(isPresented: $addGroupIsPresented) {
            AddGroup { name in
              addNewGroup(name: name)
              addGroupIsPresented = false
            }
          }
          .navigationBarTitle(Text("Folders"))
          .navigationBarItems(trailing:
            Button(action: { addGroupIsPresented.toggle() }) {
              Image(systemName: "plus")
            }
          )
//          .preferredColorScheme(darkMode ? .dark : .light)
        }
    }
        private func deleteObjects(offsets: IndexSet) {
          withAnimation {
            persistence.deleteManagedObjects(offsets.map { groups[$0] })
          }
        }

        private func addNewGroup(name: String) {
          withAnimation {
            persistence.addNewGroup(name: name)
          }
        }
}

#if DEBUG
struct RSSGroupListView_Previews: PreviewProvider {
    static let rss = RSS()
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static var previews: some View {
        RSSGroupListView(persistence: Persistence.current, viewModel: self.viewModel)
            .environment(\.managedObjectContext, Persistence.current.context)
            .environmentObject(Persistence.current)
            .preferredColorScheme(.dark)
    }
}
#endif



