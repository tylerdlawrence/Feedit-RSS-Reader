//
//  HomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import FeedKit

struct HomeView: View {

    @State private var archiveScale: Image.Scale = .medium
    
    private var homeListView: some View {
        RSSListView(viewModel: RSSListViewModel(dataSource: DataSourceService.current.rss))
            
    }
    private var settingListView: some View {
        SettingListView()
    }
    
    private var archiveListView: some View {
        ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
    }
    
//    private var itemListView: some View {
//        ItemListView()
    
    var body: some View {
        TabView {
            homeListView
                .tabItem {
                    VStack {
                        Image(systemName:"square.3.stack.3d.top.fill") //"square.stack.3d.up.fill","rectangle.grid.1x2","mail.stack.fill",")
                            .imageScale(.large)
                        Text("")
                    }
                }
            archiveListView
                .tabItem {
                    VStack {
                        Image(systemName: "bookmark.circle.fill")
                            .imageScale(.large)
                        Text("")
                    }
                }
            
//            itemListView
//                .tabItem {
//                    VStack {
//                        Image(systemName: "list.bullet")
//                            .imageScale(.large)
//                        Text("Subscriptions")
                        
            settingListView
                .tabItem {
                    VStack{
                        Image(systemName: "gearshape.fill")
                            .imageScale(.large)
                        Text("")
                    }
                }
        }
        
        
        
    }
}

extension HomeView {
}

#if DEBUG

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .medium)
            .previewDevice("iPhone 11 Pro Max")
            
    }
}

#endif

