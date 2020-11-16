//
//  ActionContextMenu.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI

struct ActionContextMenu: View {
    
    private var label: String
    //private var mark: String
    private var systemName: String
    
    var onAction: (() -> Void)?
    
    init(label: String, systemName: String, onAction: (() -> Void)? = nil) {
        self.label = "Tag Article"
//        self.mark = "Mark as Read"
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
                    Image(systemName: "tag")
                        .imageScale(.small)
//                        .foregroundColor(Color("darkerAccent"))
                        .foregroundColor(.blue)
//                    Text(self.mark)
//                    Image("mark")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 20, height: 20)
                }
            }
        }
    }
}

struct ActionContextMenu_Previews: PreviewProvider {
    static var previews: some View {
        ActionContextMenu(label: "Tag Article", systemName: "tag")
                          //, mark: "mark")
            //.preferredColorScheme(.dark)
            //.previewDevice("iPhone 11 Pro Max")
    }
}
