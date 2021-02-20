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
    
    @State private var archiveScale: Image.Scale = .small
    
    private var homeListView: some View
    
    {
        RSSListView(viewModel: RSSListViewModel(dataSource: DataSourceService.current.rss))
            
    }
    
    private var settingListView: some View {
        SettingListView()
        
    }
    
    private var archiveListView: some View {
        ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
        
    }
    
    var body: some View {
        TabView {
            homeListView
                .tabItem {
                    VStack() {
                        Image(systemName:"square.3.stack.3d")
                            .imageScale(.small)
                        Text("")
                    }
                }
                
                //.preferredColorScheme(.dark)
            archiveListView
                .tabItem {
                    VStack {
                        Image(systemName: "bookmark")
                            .imageScale(.small)
                        Text("")
                    }
                }
                        
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
            .previewDevice("iPhone X")
            
    }
}

#endif

