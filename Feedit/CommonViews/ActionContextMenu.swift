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
        self.label = label
        self.systemName = systemName
        self.onAction = onAction
    }
    
    var body: some View {
        VStack {
            Button(action: {
                self.onAction?()
            }) {
                HStack {
                    Text(self.label)
                    Image(systemName: self.systemName)
                        .imageScale(.small)
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

struct ActionContextMenu_Previews: PreviewProvider {
    static var previews: some View {
        ActionContextMenu(label: "Archive", systemName: "tray.and.arrow.down")
        ActionContextMenu(label: "Star", systemName: "star.fill")
    }
}
