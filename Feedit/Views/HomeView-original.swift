//
//  HomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import UIKit
import SwiftUI
import FeedKit
import CoreData
import Foundation

struct HomeView: View {

    @State private var archiveScale: Image.Scale = .medium
    
    private var homeListView: some View
    //homeListView
    {
        RSSListView(viewModel: RSSListViewModel(dataSource: DataSourceService.current.rss))
            
            

            
    }
    private var settingListView: some View {
        SettingListView()
    }
    
    private var archiveTableView: some View {
        ArchiveTableView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
    }
    
//    private var itemListView: some View {
//        ItemListView()
    
    var body: some View {
        TabView {
            homeListView
                //homeListView
                .tabItem {
                    VStack {
                        Image(systemName:"square.3.stack.3d") //"square.stack.3d.up.fill","rectangle.grid.1x2","mail.stack.fill",")
                            .imageScale(.small)
                        Text("")
                    }
                }
                .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
                
                
                
                
            archiveTableView
                .tabItem {
                    VStack {
                        Image(systemName: "bookmark")
                            .imageScale(.small)
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
                        Image(systemName: "gearshape")
                            .imageScale(.small)
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
            .previewDevice("iPhone 11")
            
    }
}

#endif

