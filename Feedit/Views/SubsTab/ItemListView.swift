//
//  ItemListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 9/5/20.
//

import SwiftUI
import CoreData

struct ItemListView: View {
    
    @StateObject private var dataSource = RSSDataSource(parentContext: <#NSManagedObjectContext#>)
    @State private var sortAscending: Bool = true
    
    @State private var showingItemAddView: Bool = false
    @State private var editMode: EditMode = .inactive

    var body: some View {
        
        NavigationView {
            VStack {
                List() {
                    
                    Section(header:
                        HStack {
                            Text("All Items ".uppercased() )
                            Spacer()
                            Image(systemName: (sortAscending ? "arrow.down" : "arrow.up"))
                                .foregroundColor(.blue)
                                .onTapGesture(perform: self.onToggleSort )
                        }
                        )
                    {
                        
                        ForEach(self.dataSource
                            .sortAscending1(self.sortAscending)
                            .objects) { item in
                            
                            if self.editMode == .active {
                                ItemListCell(name: item.name, order: item.order, check: item.selected)
                            } else {
                                NavigationLink(destination: ItemEditView(item: item))
                                { ItemListCell(name: item.name, order: item.order, check: item.selected) }
                            }
                        }
                            .onMove(perform: (self.sortAscending ? self.dataSource.move : nil))    // Move only allowed if ascending sort
                            .onDelete(perform: self.dataSource.delete)
                    }
                }
                HiddenNavigationLink(destination: ItemAddView(), isActive: self.$showingItemAddView)
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Items"), displayMode: .large)
            .navigationBarItems(trailing:
                HStack {
                    ActivateButton(activates: self.$showingItemAddView) { Image(systemName: "plus") }
                    EditButton()
                } )
            .environment(\.editMode, self.$editMode)
         }
    }
        
    public func onToggleSort() {
        
        self.sortAscending.toggle()
    }
    
}

#if DEBUG
struct ItemListView_Previews : PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            ItemListView()
        }
    }
}
#endif
