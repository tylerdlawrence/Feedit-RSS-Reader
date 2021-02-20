//
//  ItemSelectionManager.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/7/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import Foundation

class ItemSelectionManager: ListSelectionManager<RSSItem> {
    
    override func select(_ value: RSSItem) {
        super.select(value)
        
        value.update(selected: true, commit: true)
    }
    
    override func deselect(_ value: RSSItem) {
        super.deselect(value)
        
        value.update(selected: false, commit: true)
    }
}
