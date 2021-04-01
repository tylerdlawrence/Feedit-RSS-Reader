//
//  SelectRSSGroupRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/14/21.
//

import SwiftUI

struct SelectRSSGroupRow: View {
    @EnvironmentObject private var persistence: Persistence
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var rssDataSource: RSSDataSource
    var group: RSSGroup
    @Binding var selection: Set<RSSGroup>
    
    var isSelected: Bool {
      selection.contains(group)
    }

    var body: some View {
      HStack {
        group.name.map(Text.init)
        Spacer()
        if isSelected {
          Image(systemName: "checkmark")
        }
      }.frame(maxWidth: .infinity)
      .onTapGesture {
        if isSelected {
          selection.remove(group)
        } else {
          selection.insert(group)
        }
      }
    }
  }

struct SelectRSSGroupRow_Previews: PreviewProvider {
//    static var group: RSSGroup = {
//        let controller = Persistence.current
//      return controller.makeRandomFolder(context: controller.context)
//    }()
    static var group = RSSGroup()
    @State static var selection: Set<RSSGroup> = [group]

    static var previews: some View {
        SelectRSSGroupRow(group: group, selection: $selection)
    }
}
