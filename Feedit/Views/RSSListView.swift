////
////  RSSListView.swift
////  Feedit
////
////  Created by Tyler Lawrence on 10/22/20
////
////
////
//import SwiftUI
//
//struct RSSListView: View {
//
//    enum InfoAction {
//        case info
//    }
//
//    @Environment(\.presentationMode) var presentationMode
//    @Environment(\.managedObjectContext) var managedObjectContext
////    @EnvironmentObject var rssDataSource: RSSDataSource
//    @ObservedObject var rss: RSS
//    @ObservedObject var viewModel: RSSListViewModel
//    @State private var isSheetPresented = false
//    @State private var selectedInfoItem = InfoAction.info
//    @State private var revealFeeds = true
//
//    private func destinationView(rss: RSS) -> some View {
//        RSSFeedListView(rssViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
//            .environmentObject(DataSourceService.current.rss)
//    }
//
//    private var feedsAll: some View {
//        HStack{
////            Image(systemName: "plus").font(.system(size: 10, weight: .black, design: .rounded)).foregroundColor(Color("bg"))
//            Text("Feeds")
//                .font(.system(size: 18, weight: .bold, design: .rounded))
//            Spacer()
//            unreadCount
//        }
//    } // "Feeds" section header
//
//    private var feedView: some View {
//        HStack{
//            Text("All Items")
//                .font(.system(size: 18, weight: .bold, design: .rounded))
//            Spacer()
//            //unreadCount
//            //Text("\(viewModel.items.count)")
//        }
//    } // "All Items" section header
//    private var unreadCount: some View {
//        UnreadCountView(count: viewModel.items.count)
//    } // unread count format
//
//    var body: some View {
////        Section(header: feedsAll) {
////            ForEach(viewModel.items, id: \.self) { rss in
////                NavigationLink(destination: self.destinationView(rss: rss)) {
////                    RSSRow(rss: rss)
////                            .contextMenu {
////                                Button(action: {
////                                    NavigationLink(destination: InfoView(rss:rss))
////                                }) {
////                                    Text("Edit")
////                                    Image(systemName: "rectangle.and.pencil.and.ellipsis").font(.system(size: 16, weight: .medium))
////                                }
////
////                                Button(action: {
////                                    self.showInfoSheet = true
////                                }) {
////                                    Text("Detect Location")
////                                    Image(systemName: "location.circle")
////                                }
////                            }
////                            }
////                            .tag("RSS")
////                        }
////                        .onDelete { indexSet in
////                            if let index = indexSet.first {
////                                self.viewModel.delete(at: index)
////                                }
////                            }
//        ZStack{
//            DisclosureGroup(
//                isExpanded: $revealFeeds,
//                content: {
//                    ForEach(viewModel.items, id: \.self) { rss in
//                        NavigationLink(destination: self.destinationView(rss: rss)) {
//                            RSSRow(rss: rss)
//                        }
//                        .tag("RSS")
//                    }
//                    .onDelete { indexSet in
//                        if let index = indexSet.first {
//                            self.viewModel.delete(at: index)
//                            }
//                        }
//                },
//                label: {
//                    HStack {
//                        feedsAll
//                    }
//                })
//                .textCase(nil)
//                .listRowBackground(Color("accent"))
//                .accentColor(Color("darkShadow"))
//                .foregroundColor(Color("darkerAccent"))
//                .edgesIgnoringSafeArea(.all)
//        }
//        .sheet(isPresented: $isSheetPresented, content: {
//            if InfoAction.info == self.selectedInfoItem {
//                InfoView(rss: self.rss)
//            }
//        })
//    }
//}
//
//struct RSSListView_Previews: PreviewProvider {
//    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
//    static let rss = RSS()
//    static var previews: some View {
//        RSSListView(rss: self.rss, viewModel: self.viewModel)
//            .preferredColorScheme(.dark)
//            .environment(\.sizeCategory, .small)
//    }
//}
//
////extension DisclosureGroup where Label == Text {
////  public init<V: Hashable, S: StringProtocol>(
////    _ label: S,
////    tag: V,
////    selection: Binding<V?>,
////    content: @escaping () -> Content) {
////    let boolBinding: Binding<Bool> = Binding(
////      get: { selection.wrappedValue == tag },
////      set: { newValue in
////        if newValue {
////          selection.wrappedValue = tag
////        } else {
////          selection.wrappedValue = nil
////        }
////      }
////    )
////
////    self.init(
////      label,
////      isExpanded: boolBinding,
////      content: content
////    )
////  }
////}
