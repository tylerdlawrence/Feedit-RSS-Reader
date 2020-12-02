//
//  HomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//
import SwiftUI

struct ContentView: View {
    
//    @ObservedObject var archiveListViewModel: ArchiveListViewModel
//    @ObservedObject var settingViewModel: SettingViewModel
//    @ObservedObject var viewModel: RSSListViewModel
    
//    private var homeListView: some View {
//        HomeView(viewModel: self.viewModel, archiveListViewModel: self.archiveListViewModel)
//      }
//

    var body: some View {
        ContentView()
//        HomeView(viewModel: self.viewModel, archiveListViewModel:
    }
}

struct ContentView_Previews: PreviewProvider {

    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)

    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

    static var previews: some View {
        ContentView()
    }
}
