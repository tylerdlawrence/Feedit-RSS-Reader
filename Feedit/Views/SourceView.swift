//
//  SourceView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/16/20.
//

//import SwiftUI
//import UserNotifications
//
//struct SourceView: View {
//    enum FilterType {
//        case all, starred, unstarred
//    }
//
//    @EnvironmentObject var sources: Sources
//    let filter: FilterType
//
//    var title: String {
//        switch filter {
//        case .all:
//            return "All"
//        case .starred:
//            return "Starred"
//        case .unstarred:
//            return "Unstarred"
//        }
//    }
//
//    var filteredSources: [Source] {
//        switch filter {
//        case .all:
//            return sources.sources
//        case .starred:
//            return sources.sources.filter { $0.isStarred }
//        case .unstarred:
//            return sources.sources.filter { !$0.isStarred }
//        }
//    }
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(filteredSources) { source in
//                    VStack(alignment: .leading) {
//                        Text(source.title)
//                            .font(.headline)
//                        Text(source.desc)
//                            .foregroundColor(.secondary)
//                    }
//                    .contextMenu {
//                        Button(source.isStarred ? "Mark Unstarred" : "Mark Starred" ) {
//                            self.sources.toggle(source)
//                        }
//                    }
//                }
//            }
//            .navigationBarTitle(title)
//            .navigationBarItems(trailing: Button(action: {
////                self.isShowingScanner = true
//            }) {
//                Image(systemName: "arrow.down.app")
//                Text("Star")
//            })
//        }
//        .environmentObject(sources)
//    }
//}
//
