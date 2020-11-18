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
/////////////////////////////////////////////////
//    NavigationView{
//        List {
//            Text("On My iPhone")
//                .font(.headline)
//                .fontWeight(.heavy)
//                .multilineTextAlignment(.leading)
//
//            DisclosureGroup(
//            "○   All Sources", //》 ♨ ☑ ○ ⌘ ❝ ❞ ∞  ↺  ❯ 􀣎 ⚲ 🏷 🔖
//            tag: .RSS,
//            selection: $showingContent) {
//                ForEach(viewModel.items, id: \.self) { rss in
//                    NavigationLink(destination: self.destinationView(rss)) {
//                        RSSRow(rss: rss)
//                    }
//                    .tag("RSS")
//                }
//
//                .onMove { (indexSet, index) in
//                    self.items.move(fromOffsets: indexSet,
//                toOffset: index)
//                }
//                .onDelete { indexSet in
//                    if let index = indexSet.first {
//                        self.viewModel.delete(at: index)
//                    }
//                }
//              }
//            VStack {
//                NavigationLink(destination: archiveListView) {
//                    ButtonView()
//                }
//             }
//            Spacer()
//
//            Text("Folders")
//                .font(.headline)
//                .fontWeight(.heavy)
//                .multilineTextAlignment(.leading)
//                NavigationLink(destination: Text("News")) {
//                    VStack{
//                        HStack{
//                            Image(systemName:"folder.badge.gear")
//                                    .imageScale(.small)
//                            Text("News")
//                        }
//                    }
//                }
//                NavigationLink(destination: Text("Blogs")) {
//                    VStack{
//                        HStack{
//                            Image(systemName:"folder.badge.gear")
//                                .imageScale(.small)
//                            Text("Blogs")
//
//                        }
//                    }
//                }
//                NavigationLink(destination: Text("Technology")) {
//                    VStack{
//                        HStack{
//                            Image(systemName:"folder.badge.gear")
//                                .imageScale(.small)
//                            Text("Technology")
//
//                        }
//                    }
//                }
//                NavigationLink(destination: Text("Entertainment")) {
//                    VStack{
//                        HStack{
//                            Image(systemName:"folder.badge.gear")
//                                .imageScale(.small)
//                            Text("Entertainment")
//
//                    //}
//                }
//            }
//        }
//        .font(.headline)
//        .listStyle(PlainListStyle())
//        .navigationTitle("Account") //On My iPhone
//        .navigationBarItems(trailing: trailingView)
//
////          DisclosureGroup(
////            "Tagged Articles",
////            tag: .tag,
////            selection: $showingContent) {
////                Label(
////                    title: { Text("Tags") },
////                    icon: { Image(systemName: "tag")
////
////                })
////          }
////          DisclosureGroup(
////            "Unread",
////            tag: .unread,
////            selection: $showingContent) {
////            Label(
////                title: { Text("View All Unread") },
////                icon: { Image(systemName: "circle.fill")
////
////            })
////          }
////        if addRSSProgressValue > 0 && addRSSProgressValue < 1.0 {
////            LinerProgressBar(lineWidth: 3, color: .blue, progress: $addRSSProgressValue)
////                .padding(.top, 2)
////        }
//
////        .onReceive(addRSSPublisher, perform: { output in
////            guard
////                let userInfo = output.userInfo,
////                let total = userInfo["total"] as? Double else { return }
////            self.addRSSProgressValue += 1.0/total
////        })
//        .onReceive(rssRefreshPublisher, perform: { output in
//            self.viewModel.fecthResults()
//        })
//        .sheet(isPresented: $isSheetPresented, content: {
//            if FeaureItem.add == self.selectedFeatureItem {
//                AddRSSView(
//                    viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss),
//                    onDoneAction: self.onDoneAction)
//            } else if FeaureItem.setting == self.selectedFeatureItem {
//                SettingView()
//            }
//        })
//        .onAppear {
//            self.viewModel.fecthResults()
//        }
//      }
//        .frame(maxWidth: .infinity, alignment: .leading)
//
//        }
