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
    
    var isDone: (() -> Void)?
    
    //var onTag: (() -> Tag)?
    
    init(label: String, systemName: String, isRead: (() -> Void)? = nil, onAction: (() -> Void)? = nil) {
        self.label = "Tag Article"
        self.label = "Toggle Starred"
        self.label = "Mark as Read"
        self.systemName = systemName
        self.onAction = onAction
        self.isDone = isRead
    }
    
    var body: some View {
        VStack {
            Button(action: {
                self.isDone?()
            }, label: {
                HStack {
                    Text("Mark As Read")
                    Image("smartFeedUnread")
                        .foregroundColor(.gray)
                    //Image("Symbol")

                }
                //.opacity((isDone != nil) ? 0.2 : 1.0)

            })
            
            Button(action: {
                self.onAction?()
            }, label: {
                HStack{
                    Text("Toggle Starred")
                    Image("star") //"star") //
                        .imageScale(.small)
                }
            })
        }

    }
}
