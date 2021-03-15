//
//  RSSGroupDetailsView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/14/21.
//

import SwiftUI

struct RSSGroupDetailsView: View {
    @AppStorage("darkMode") var darkMode = false
    let rssGroup: RSSGroup

    var body: some View {
      VStack(alignment: .leading, spacing: 8) {
        Text("Feeds: \(rssGroup.itemCount)")
          .padding()
      }
      .navigationBarTitle(Text(rssGroup.name ?? "Folders"))
      .preferredColorScheme(darkMode ? .dark : .light)
    }
}

//#if DEBUG
//struct RSSGroupDetailsView_Previews: PreviewProvider {
//    static var group: RSSGroup {
//      let controller = Persistence.preview
//      return controller.makeRandomFolder(context: controller.context)
//    }
//    static var previews: some View {
//        RSSGroupDetailsView(rssGroup: group)
//    }
//}
//#endif

struct DemoDisclosureGroups: View {
    let items: [Bookmark] = [.example1, .example2, .example3]
    @State private var flags: [Bool] = [false, false, false]

    var body: some View {
        List {
            ForEach(Array(items.enumerated()), id: \.1.id) { i, group in
                DisclosureGroup(isExpanded: $flags[i]) {
                    ForEach(group.items ?? []) { item in
                        Label(item.name, systemImage: item.icon)
                    }
                } label: {
                    Label(group.name, systemImage: group.icon)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                self.flags[i].toggle()
                            }
                        }
                }
            }
        }
    }
}

struct DemoDisclosureGroups_Previews: PreviewProvider {
    static var previews: some View {
        DemoDisclosureGroups()
    }
}

struct Bookmark: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    var items: [Bookmark]?

    // some example websites
    static let apple = Bookmark(name: "Apple", icon: "1.circle")
    static let bbc = Bookmark(name: "BBC", icon: "square.and.pencil")
    static let swift = Bookmark(name: "Swift", icon: "bolt.fill")
    static let twitter = Bookmark(name: "Twitter", icon: "mic")

    // some example groups
    static let example1 = Bookmark(name: "Favorites", icon: "star", items: [Bookmark.apple, Bookmark.bbc, Bookmark.swift, Bookmark.twitter])
    static let example2 = Bookmark(name: "Recent", icon: "timer", items: [Bookmark.apple, Bookmark.bbc, Bookmark.swift, Bookmark.twitter])
    static let example3 = Bookmark(name: "Recommended", icon: "hand.thumbsup", items: [Bookmark.apple, Bookmark.bbc, Bookmark.swift, Bookmark.twitter])
}
