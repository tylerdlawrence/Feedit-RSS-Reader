//
//  HomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    init() {
        UITableView.appearance(whenContainedInInstancesOf: [UIHostingController<ContentView>.self]).separatorColor = .clear
        
        UIToolbar.appearance().barTintColor = UIColor(Color("accent"))
        UIToolbar.appearance().isTranslucent = false
    }
    var body: some View {
        ContentView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static let rssViewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
    static var previews: some View {
        ContentView()
    }
}
