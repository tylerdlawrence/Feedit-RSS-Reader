//
//  SelectGroupView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/14/21.
//

import SwiftUI
import CoreData

struct SelectGroupView: View {
    @AppStorage("darkMode") var darkMode = false
    static var fetchRequest: NSFetchRequest<RSSGroup> {
      let request: NSFetchRequest<RSSGroup> = RSSGroup.fetchRequest()
      request.sortDescriptors = [NSSortDescriptor(keyPath: \RSSGroup.name, ascending: true)]
      return request
    }
    @EnvironmentObject private var persistence: Persistence
    @EnvironmentObject var rssDataSource: RSSDataSource
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
      fetchRequest: RSSGroupListView.fetchRequest,
      animation: .default)
    private var groups: FetchedResults<RSSGroup>

    @State var selectedGroups: Set<RSSGroup>
    let onComplete: (Set<RSSGroup>) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    var onDoneAction: (() -> Void)?
    
    var body: some View {
        
        NavigationView {
            List(groups, id: \.id, selection: $selectedGroups) { group in
                SelectRSSGroupRow(group: group, selection: $selectedGroups.projectedValue)
            }
            .navigationBarTitle("Add To Folder")
//            .navigationBarItems(trailing: Button("Done") {
//                formAction()
//                self.onDoneAction?()
//                self.presentationMode.wrappedValue.dismiss()
//            })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {Text("")}
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        formAction()
                        self.onDoneAction?()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }.environmentObject(Persistence.current)
    }

    private func formAction() {
      onComplete(selectedGroups)
    }
  }

struct SelectGroupView_Previews: PreviewProvider {
    static var previews: some View {
        SelectGroupView(selectedGroups: []) { _ in }
            .environment(\.managedObjectContext, Persistence.current.context)
            .environmentObject(Persistence.current)
    }
}
