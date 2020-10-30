//
//  HomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import FeedKit
import ModalView
import iPages

struct ContentView: View {
    
    init(){
            UITableView.appearance().backgroundColor = .clear
    }
    
    @Environment(\.colorScheme) var colorScheme
    @State var size = UIScreen.main.bounds.width / 1.6
    @State private var selection = 0
    @State private var revealDetails = false
    @State private var isLoading = false
    @State private var archiveScale: Image.Scale = .small

    private var homeListView: some View {
        RSSListView(viewModel: RSSListViewModel(dataSource: DataSourceService.current.rss))
      }
    
    private var archiveListView: some View {
        ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
      }
    
    private var settingListView: some View {
        SettingView()
    }

    var body: some View{
        
        TabView (selection: $selection){
            homeListView
                .tabItem {
                    VStack() {
                        Image(systemName:"text.alignleft")
//                            .imageScale(.small)
                    }
                    .tag(0)
                }
            
            archiveListView
                .tabItem {
                    VStack() {
                        Image(systemName:"bookmark")
//                            .imageScale(.small)
                    }
                    .tag(1)
                }
            
            settingListView
                .tabItem {
                    VStack() {
                        //Image("mark")
                        Image(systemName: "gear")
//                            .imageScale(.small)
                    }
                    .tag(2)
                }
                .onAppear() {
                    UITabBar.appearance().backgroundColor = .systemGray6
                }
            }
        .navigationBarColor(backgroundColor: .systemGray6, tintColor: .systemGray)
        .environment(\.sizeCategory, .extraSmall)
        }
    }

extension UITabBarController {
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        let standardAppearance = UITabBarAppearance()

        standardAppearance.stackedItemPositioning = .centered
        standardAppearance.stackedItemSpacing = 30
        standardAppearance.stackedItemWidth = 30

        standardAppearance.configureWithOpaqueBackground()

        //standardAppearance.configureWithTransparentBackground()

        tabBar.standardAppearance = standardAppearance
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
        ContentView()
            .environment(\.sizeCategory, .extraSmall)
    }
}
