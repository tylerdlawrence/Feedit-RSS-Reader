//
//  ItemList.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 10/16/20.
//

import SwiftUI

extension Item {
    
    static var stubs: [Item] {
        [
            Item(title: "Smart Feeds", children: [
                Item(title: "Today", children: nil),
                Item(title: "Unread", children: nil),
                Item(title: "Bookmarked", children: nil),
            ]),
            Item(title: "Folders", children: [
                Item(title: "Default Feeds", children: nil),
                Item(title: "On My iPhone", children: nil),
            ]),
        ]
    }
}



struct ItemList_Previews: PreviewProvider {
    static var previews: some View {
        ItemList(items: Item.stubs)
            .preferredColorScheme(.dark)
    }
}
