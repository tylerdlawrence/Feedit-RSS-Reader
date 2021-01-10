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
    //var onStarAction: (() -> Void)?
    var isReadAction: (() -> Void)?

    init(label: String, systemName: String, onAction: (() -> Void)? = nil, isReadAction: (() -> Void)? = nil) {
        self.label = label
        self.systemName = systemName
        self.onAction = onAction
        self.isReadAction = isReadAction
    }
    
    var body: some View {
        VStack {
            Button(action: {
                self.isReadAction?()
            }) {
                HStack {
                    Text("Mark As Read")
                    Image("unread-action")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .opacity(0.7)
                }
            }
                Button(action: {
                    self.onAction?()
                }) {
                    HStack {
                        Text("Star Article")
                        Image(systemName: "star.fill")
                            .imageScale(.small)
                    }
                }
            
        }
    }
}
struct ActionContextMenu_Previews: PreviewProvider {
    static var previews: some View {
        ActionContextMenu(label: "Archive", systemName: "tray.and.arrow.down")
    }
}
//struct RedMenu: MenuStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        Menu(configuration)
//            .foregroundColor(.red)
//    }
//}
//struct MenuView: View{
//    var body: some View{
//        NavigationView{
//        Text("Hello")
//            .toolbar {
//                ToolbarItem(placement: .primaryAction) {
//                    Menu {
//                        Section {
//                            Button(action: {}) {
//                                Label("Add Feed", systemImage: "plus")
//                            }
//
//                            Button(action: {}) {
//                                Label("Add Folder", systemImage: "folder")
//                            }
//                        }
//
//                        Section(header: Text("Secondary actions")) {
//                            Button(action: {}) {
//                                Label("Remove old files", systemImage: "trash")
//                                    .foregroundColor(.red)
//                            }
//                        }
//                    }
//                    label: {
//                        Label("Add", systemImage: "plus")
//                    }
//                }
//            }
////            .toolbar {
////                ToolbarItem(placement: .primaryAction) {
////                    Menu("Add") {
////                        Button("File") {}
////                        Button("Folder") {}
////                    }.menuStyle(RedMenu())
////                }
////            }
//        }
//    }
//}
//
//struct ActionContextMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        ActionContextMenu(label: "Archive", systemName: "tray.and.arrow.down")
//        MenuView()
//    }
//}
