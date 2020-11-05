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

//    init(){
//        UITableView.appearance().backgroundColor = .clear
//        //.secondarySystemGroupedBackground
//        //.clear
//
//    }
    
    enum FeatureItem {
        case remove
        case move
    }
    
    enum FeaureItem {
        case add
    }
    
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
    
    private var addSourceButton: some View {
        Button(action: {
            self.isSheetPresented = true
            self.selectedFeaureItem = .add
        }) {
            Image(systemName: "plus")
                .padding(.trailing, 0)
                .imageScale(.large)
        }
    }
    
    private var ListView: some View {
        HStack(alignment: .top, spacing: 24) {
            addSourceButton
        }
    }
    
    var body: some View {
        NavigationView {
            ModalPresenter() {
                VStack{
                    Image("launch")
                        .resizable()
                        .frame(width: 125, height: 125, alignment: .center)
                }
                Form {
                    Section(header: Text("Smart Feeds")) {
                        ModalLink(destination: homeListView) {
                            Text("All Articles")
                        }
                        ModalLink(destination: archiveListView) {
                            Text("Tags")
                        }
//                        ModalLink(destination: ListView) {
//                            Text("Add Feed")
//                        }
                    }
//                    Section(header: Text("Plants")) {
//                        ModalLink(destination: Text("🍎")) {
//                            Text("Show 🍏")
//                        }
//                        ModalLink(destination: Text("🥑")) {
//                            Text("Show 🥑")
//                        }
//                        ModalLink(destination: Text("🥦")) {
//                            Text("Show 🥦")
//                        }
//                    }
                }
            }
            //.navigationBarTitle("Feedit")
            .listStyle(SidebarListStyle())
            .navigationBarItems(trailing:
                HStack {
                    
                    Button(action: {
                        print("Reload button pressed...")
                        
                    }) {
                        
                        Image(systemName: "arrow.clockwise")
                    }
                    .padding(.trailing)
                    
                    Button(action: {
                        print("Setting button pressed")
                        
                    }) {
                        
                        Image("settingtoggle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24, alignment: .center)
                    }
                    //Image("settingtoggle")
                    
                    //addSourceButton
                }
            )
//            .navigationBarItems(leading: settingListView, trailing: Image(systemName: "plus")
//                                    .resizable()
//                                    .frame(width: 15, height: 15)
//        )
            
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
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
        ContentView()
            .environment(\.sizeCategory, .extraSmall)
    }
}
