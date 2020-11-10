//
//  Item.swift
//  continuum
//
//  Created by Tyler D Lawrence on 10/12/20.
//

import Foundation
import SwiftUI

struct Item: Identifiable {
    let id = UUID()
    let title: String
    let children: [Item]?
}

extension Item {
    static var stubs: [Item] {
        
        [
            Item(title: "Today", children: [
                Item(title: "today feeds", children: nil)

                ]),
            
            Item(title: "Unread", children: [
                Item(title: "unread feeds", children: nil),
                
                ]),
            
            Item(title: "Bookmarks", children: [
                Item(title: "bookmarked feeds", children: nil),

            ])
        ]
    }
}
