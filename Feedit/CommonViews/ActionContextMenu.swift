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
        self.label = "Archive"
        self.label = "Toggle Starred"
        self.label = "Mark as Read"
        self.systemName = systemName
        self.onAction = onAction
        self.isDone = isRead
    }
    
    var body: some View {
//        VStack {
//            Button(action: {
//                self.onAction?()
//            }) {
//                HStack {
//                    Text(self.label)
//                    Image(systemName: self.systemName)
//                        .imageScale(.small)
//                        .foregroundColor(.primary)
//                }
//            }
//        }
        VStack {
            Button(action: {
                self.isDone?()
            }, label: {
                HStack {
                    Text("Mark As Read")
                    Image("unread-action") //systemName: self.systemName) //"unread-action")
                        .imageScale(.small)

                }

            })
            
            Button(action: {
                self.onAction?()
            }, label: {
                HStack{
                    Text("Toggle Starred") //self.label) //"Toggle Starred")
                    Image(systemName: "star.fill") //self.systemName) //systemName: "star.fill")
                        .imageScale(.small)
                }
            })
            
        }

    }
}
