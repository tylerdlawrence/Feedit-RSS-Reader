//
//  ActionContextMenu.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI

struct ActionContextMenu: View {
    
    private var label: String
    private var systemName: String
    
    var onAction: (() -> Void)?
    
    init(label: String, systemName: String, onAction: (() -> Void)? = nil) {
        self.label = "Bookmark Article"
        self.systemName = systemName
        self.onAction = onAction
    }
    
    var body: some View {
        VStack {
            Button(action: {
                self.onAction?()
            }) {
                HStack() {
                    Text(self.label)
                    Image(systemName: "bookmark.circle")
                        .imageScale(.small)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct ActionContextMenu_Previews: PreviewProvider {
    static var previews: some View {
        ActionContextMenu(label: "Bookmark Article", systemName: "bookmark.circle")
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 11 Pro Max")
    }
}
