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
    
    @State private var rss = [String]() 
    @State private var searchedRSSList = [String]()
    @State private var searching = false

    init() {
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.1097864285, green: 0.1058807895, blue: 0.1140159145, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
        UIScrollView.appearance().backgroundColor = UIColor(Color(#colorLiteral(red: 0.1097864285, green: 0.1058807895, blue: 0.1140159145, alpha: 1)))
    }
    
//    @ObservedObject var archiveListViewModel: ArchiveListViewModel
//    @ObservedObject var settingViewModel: SettingViewModel
//    @ObservedObject var viewModel: RSSListViewModel
    
//    private var homeListView: some View {
//        HomeView(viewModel: self.viewModel, archiveListViewModel: self.archiveListViewModel)
//      }
//

    var body: some View {
        ContentView()
//        HomeView(viewModel: self.viewModel, archiveListViewModel: self.archiveListViewModel)
        
        NavigationView {
                    VStack(spacing: 0) {
                        // SearchBar
                        SearchBar(searching: $searching, title: $rss, searchedList: $searchedRSSList)

                        // ...
                        
                    }

                }
                .onAppear(perform: {
                    listOfFeeds()
                })
            }

            func listOfFeeds() {
                for code in NSLocale.isoCountryCodes as [String] {
                    let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
                    let name = NSLocale(localeIdentifier: "en").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "No results for: \(code)"
                    rss.append(name + " ")
                    //rssList.append(name + " " + countryFlag(country: code))
                }
            }
        }

//    }
//}

struct ContentView_Previews: PreviewProvider {

    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)

    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

    static var previews: some View {
        ContentView()
    }
}
//(archiveListViewModel: self.archiveListViewModel, settingViewModel: self.settingViewModel, viewModel: self.viewModel)


// Highlight Color for Cell
struct ListButtonStyle: ButtonStyle {
    var highlightColor: Color

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label.overlay(configuration.isPressed ? highlightColor : Color.clear)
    }
}
