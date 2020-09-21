//
//  ItemListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 9/4/20.
//

import SwiftUI
import CoreData

struct ItemListView : View {
    
    @State private var sortAscending: Bool = true
    
    @State private var showingItemAddView: Bool = false
    @State private var editMode: EditMode = .inactive
    }


struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView()
    }
}
