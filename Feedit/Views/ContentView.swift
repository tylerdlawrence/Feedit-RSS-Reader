//
//  HomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//
import SwiftUI
import CoreData
import Foundation
import FeedKit

struct ContentView: View {

    init() {
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.109796904, green: 0.1098076925, blue: 0.113863565, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false

        // Use expanded view's color as the ScrollView background color to make it look better when the cell expands/collapses
        UIScrollView.appearance().backgroundColor = UIColor(Color(#colorLiteral(red: 0.1097864285, green: 0.1058807895, blue: 0.1140159145, alpha: 1)))
    }
    
//    @ObservedObject var archiveListViewModel: ArchiveListViewModel
//    //@ObservedObject var settingViewModel: SettingViewModel
//    @ObservedObject var viewModel: RSSListViewModel

    //@State private var selectedTab = 0

//    private var homeListView: some View {
//        HomeView(viewModel: self.viewModel, archiveListViewModel: self.archiveListViewModel)
//      }
//

    var body: some View {
        ContentView()
//        HomeView(viewModel: self.viewModel, archiveListViewModel: self.archiveListViewModel)

    }
}

struct ContentView_Previews: PreviewProvider {

    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)

    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

    //static let settingViewModel = SettingViewModel()

    static var previews: some View {
        ContentView()
    }
}
//(archiveListViewModel: self.archiveListViewModel, settingViewModel: self.settingViewModel, viewModel: self.viewModel)

//init() {
//        UITableView.appearance().separatorColor = .clear
//    }
//            .listSeparatorStyleNone()
//public struct ListSeparatorStyleNoneModifier: ViewModifier {
//    public func body(content: Content) -> some View {
//        content.onAppear {
//            UITableView.appearance().separatorStyle = .none
//        }.onDisappear {
//            UITableView.appearance().separatorStyle = .singleLine
//        }
//    }
//}
//
//extension View {
//    public func listSeparatorStyleNone() -> some View {
//        modifier(ListSeparatorStyleNoneModifier())
//    }
//}


//#if DEBUG
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//        let folderList = FolderList.init(context: context)
//        folderList.folderTitle = "Idea 1"
//        folderList.folderDescription = "The first idea."
//
//        return ContentView()
//            .environment(\.managedObjectContext, (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
//    }
//}
//#endif
