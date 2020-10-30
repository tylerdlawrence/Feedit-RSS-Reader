//
//  FeedsList.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 10/21/20.
//

import SwiftUI

struct FeedsList: View {

    var body: some View {
        List {
            Section(header: Text("Discover")
                        .font(.title3)) {
                Label("Hot Links", systemImage: "flame")
                Label("Linked List", systemImage: "link")
                Label("Calm Feeds", systemImage: "chevron.right")
            }
        }
        .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Feeds", displayMode: .automatic)
        .preferredColorScheme(.dark)
    }
}

struct FeedsList_Previews: PreviewProvider {
    static var previews: some View {
        FeedsList()
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Feeds", displayMode: .automatic)
            .preferredColorScheme(.dark)
    }
}
