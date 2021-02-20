//
//  Item.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 10/16/20.
//

import SwiftUI

struct Item: Identifiable {
    let id = UUID()
    let title: String
    let children: [Item]?
}

struct ItemList: View {
    
    let items: [Item]
    
    var body: some View {
        NavigationView {
            List(items, children: \.children) {
            Text($0.title)
                
            }
        }.navigationBarTitle("Feeds")
    }
}
