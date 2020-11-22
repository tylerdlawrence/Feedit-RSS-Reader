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

//    // ❇️ Core Data property wrappers
//    @Environment(\.managedObjectContext) var managedObjectContext
//
//    // ❇️ The BlogIdea class has an `allIdeasFetchRequest` static function that can be used here
//    @FetchRequest(fetchRequest: RSSFolderList.allRSSFoldersFetchRequest()) var rssFolderLists: FetchedResults<RSSFolderList>
//
//    // ℹ️ Temporary in-memory storage for adding new blog ideas
//    @State private var newFolderTitle = ""
//    @State private var newFolderDescription = ""
//
//    // ℹ️ Two sections: Add Blog Idea at the top, followed by a listing of the ideas in the persistent store



    @ObservedObject var archiveListViewModel: ArchiveListViewModel
    @ObservedObject var settingViewModel: SettingViewModel
    @ObservedObject var viewModel: RSSListViewModel

    @State private var selectedTab = 0

    private var homeListView: some View {
        HomeView(viewModel: self.viewModel, archiveListViewModel: self.archiveListViewModel)
      }

    var body: some View {
        HomeView(viewModel: self.viewModel, archiveListViewModel: self.archiveListViewModel)
        //RSSFolderView()
    }
}


struct ContentView_Previews: PreviewProvider {

    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)

    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

    static let settingViewModel = SettingViewModel()

    static var previews: some View {
        ContentView(archiveListViewModel: self.archiveListViewModel, settingViewModel: self.settingViewModel, viewModel: self.viewModel)

    }
}

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
