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
    
    var onRead: (() -> UnreadCountProvider)?
    
    var onTag: (() -> Tag)?
    
    init(label: String, systemName: String, onAction: (() -> Void)? = nil) {
        //onRead: (() -> UnreadCountProvider)?, onTag: (() -> Tag)?
        self.label = "Tag Article"
        self.label = "Toggle Starred"
        self.label = "Mark as Read"
        self.systemName = systemName
        self.onAction = onAction
    }
    
    var body: some View {
        VStack {
//            Button(action: {
//                self.onRead?()
//            }, label: {
//                HStack{
//                    Text("Toggle Read")
//                    Image(systemName: "circle")
//                        .imageScale(.small)
//                }
//            })
            Button(action: {
                self.onAction?()
            }, label: {
                HStack{
                    Text("Toggle Starred")
                    Image(systemName: "star.fill") //"star") //
                        .imageScale(.small)
                }
            })
//            Button(action: {
//                self.onTag?()
//            }, label: {
//                HStack{
//                    Text("Tag Article")
//                    Image(systemName: "circlebadge.2")
//                        .imageScale(.small)
//                    //Image("smartFeedUnread")
//                }
//            })
        }

    }
}

//struct ActionContextMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        ActionContextMenu(label: "Toggle Starred", systemName: "star.fill")
////        ActionContextMenu(read: "Mark As Read", systemName: "circle.fill")
//    }
//}
