//
//  HomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import FeedKit
import ModalView
import Foundation

struct ContentView: View {

    init(){
        UITableView.appearance().backgroundColor = .clear
//        //.secondarySystemGroupedBackground
//        //.clear
//
    }
    
    enum FeatureItem {
        case remove
        case move
    }
    
    enum FeaureItem {
        case add
    }
    
//    @ObservedObject var itemWrapper: RSSItem
//
//    var contextMenuAction: ((RSSItem) -> Void)?
//
//    init(wrapper: RSSItem, menu action: ((RSSItem) -> Void)? = nil) {
//        itemWrapper = wrapper
//        contextMenuAction = action
//    }
    
    @State private var showDetails = false
    @State private var revealDetails = false
    @State private var selectedFeaureItem = FeaureItem.add
    @State private var selectedFeatureItem = FeatureItem.remove
    @State private var isAddFormPresented = false
    @State private var isSheetPresented = false
    @State private var addRSSProgressValue = 0.0
    @State var sources: [RSS] = []
    @State var isEditing = false

    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab = 0

    let numTabs = 3
    let minDragTranslationForSwipe: CGFloat = 50

    @State var size = UIScreen.main.bounds.width / 1.6
    @State private var selection = 0
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

    
    var body: some View {
        NavigationView {
            ModalPresenter() {
                VStack{
                    Image("launch")
                        .resizable()
                        .frame(width: 125, height: 130, alignment: .center)
                        .opacity(0.8)
                }
                Form {
                    Section(header: Text("")) {
                        ModalLink(destination: homeListView) {
                            
                        HStack{
                            VStack{
                                Image(systemName: "text.alignleft")
                                    .font(.system(size: 24, weight: .black))
                            }
                            VStack(alignment: .leading) {
                                Text("All Feeds")
                                    .font(.headline)
                                    .fontWeight(.heavy)
                                Text("Updated Today")
                                    .font(.subheadline)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color.gray)
                                    
                                    
                            }
                        }
                    }
                        ModalLink(destination: archiveListView) {
                        HStack{
                            VStack{
                                Image(systemName: "tag")
                                    .font(.system(size: 24, weight: .black))
                            }
                            VStack(alignment: .leading) {
                                Text("Tagged Articles")
                                    .font(.headline)
                                    .fontWeight(.heavy)
                                    //.opacity(0.8)
//                                    .font(.system(size: 18, weight: .black))
//                                    .fontWeight(.regular)

                                Text("Updated Today")
                                    .font(.subheadline)
                                    .fontWeight(.heavy)
                                    //.opacity(0.8)
//                                    .font(.system(size: 16, weight: .black))
//                                    .fontWeight(.regular)
                                    .foregroundColor(Color.gray)
                            }
                        }
                    }
                }
                    Section(header: Text("")) {
                        ModalLink(destination: settingListView) {
                            
                            HStack{
                            Image("settingtoggle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24, alignment: .center)
                            Text("Settings")
                                .font(.headline)
                                .fontWeight(.heavy)
                                //.foregroundColor(.gray)
                                //.opacity(0.8)
                            }
                        }
                    }
//                        ModalLink(destination: Text("🥑")) {
//                            Text("Show 🥑")
//                        }
//                        ModalLink(destination: Text("🥦")) {
//                            Text("Show 🥦")
//                        }
//                    }
                }
            }
            .font(.subheadline)
            .foregroundColor(.primary)
            .opacity(0.8)
//            .navigationBarItems(trailing:
//
//                //HStack {
//
//                    Button(action: {
//                        //settingListView
//                    }) {
//
//                        Image("settingtoggle")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 24, height: 24, alignment: .center)
//                }
//            )
        }
    }
}

//    var body: some View{
//
//        TabView (selection: $selectedTab){
//            homeListView
//                .tabItem {
//                    VStack() {
//                        Image(systemName:"text.alignleft")
////                            .imageScale(.small)
//                    }
//                    .tag(0)
////                    .highPriorityGesture(DragGesture().onEnded({
////                        self.handleSwipe(translation: $0.translation.width)
////                    }))
//                }
//
//            archiveListView
//                .tabItem {
//                    VStack() {
//                        Image(systemName:"bookmark")
////                            .imageScale(.small)
//                    }
//                    .tag(1)
//                    .highPriorityGesture(DragGesture().onEnded({
//                        self.handleSwipe(translation: $0.translation.width)
//                    }))
//                }
//
//            settingListView
//                .tabItem {
//                    VStack() {
//                        //Image("mark")
//                        Image(systemName: "gear")
////                            .imageScale(.small)
//                    }
//                    .tag(2)
//                    .highPriorityGesture(DragGesture().onEnded({
//                        self.handleSwipe(translation: $0.translation.width)
//                    }))
//                }
//                .onAppear() {
//                    UITabBar.appearance().backgroundColor = .secondaryLabel
//                }
//            }
//        .navigationBarColor(backgroundColor: .secondarySystemGroupedBackground, tintColor: .secondaryLabel)
//        .environment(\.sizeCategory, .extraSmall)
//        }

//private func handleSwipe(translation: CGFloat) {
//    if translation > minDragTranslationForSwipe && selectedTab > 0 {
//        selectedTab -= 1
//    } else  if translation < -minDragTranslationForSwipe && selectedTab < numTabs-1 {
//        selectedTab += 1
//        }
//    }
//}
//
//extension UITabBarController {
//    override public func viewDidLoad() {
//
//        super.viewDidLoad()
//
//        let standardAppearance = UITabBarAppearance()
//
//        standardAppearance.stackedItemPositioning = .centered
//        standardAppearance.stackedItemSpacing = 30 //30
//        standardAppearance.stackedItemWidth = 30 //30
//
//        standardAppearance.configureWithOpaqueBackground()
//
//        //standardAppearance.configureWithTransparentBackground()
//
//        standardAppearance.backgroundColor = .secondarySystemBackground
//            //secondarySystemGroupedBackground
//
//        tabBar.standardAppearance = standardAppearance
//
//    }
//}

extension Date {
    func string(format: String = "MMM d, h:mm a") -> String {
        let f = DateFormatter()
        f.dateFormat = format
        return f.string(from: self)
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
