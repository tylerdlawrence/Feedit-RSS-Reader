//
//  RSSListView.swift
//  Feedit
//
//  Created by Tyler Lawrence on 10/22/20
//
//
//
//import SwiftUI
//
//struct RSSListView: View {
//
//    enum FilterType {
//        case none, starred, unstarred
//    }
//    
//    @EnvironmentObject var viewModel: RSS
//    let filter: FilterType
//    
//    var title: String {
//        switch filter {
//        case .none:
//            return "All"
//        case .starred:
//            return "Starred"
//        case .unstarred:
//            return "Unstarred"
//        }
//    }
//    
//    var filteredViewModel: [RSS] {
//        switch filter {
//        case .none:
//            return viewModel.items
//        case .starred:
//            return viewModel.items.filter { $0.isStarred }
//        case .unstarred:
//            return viewModel.items.filter { !$0.isUnStarred}
//        }
//    }
//    
//    var body: some View {
//        NavigationView{
//            List {
//                ForEach(filteredViewModel) { rss in
//                    VStack(alignment: .leading) {
//                        Text(rss.title)
//                            .font(.headline)
//                        Text(rss.desc)
//                            .foregroundColor(.secondary)
//                    }
//                }
//            }
//                .navigationBarTitle(title)
//                .navigationBarItems(trailing: Button(action: {
//                    let rss = RSSSource()
//                    rss.title = "Tyler Lawrence"
//                    rss.desc = "test desc"
//                    self.viewModel.items.append(rss)
//                }) {
//                    Image(systemName: "arrow.up.and.down.square")
//                    Text("Filter")
//                })
//        }
//    }
////    (viewModel.items, id: \.self) { rss in
////        NavigationLink(destination: self.destinationView(rss)) {
////            RSSRow(rss: rss)
////struct RSSListView_Previews: PreviewProvider {
////    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
//
//    static var previews: some View {
//        RSSListView(viewModel: self.viewModel)
//            .preferredColorScheme(.dark)
//            .environment(\.sizeCategory, .small)
//    }
//}
