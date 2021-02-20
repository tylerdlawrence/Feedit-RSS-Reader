//
//  Feeditapp.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.

import UIKit
import SwiftUI
import BackgroundTasks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
//    static let db = DataSourceService.current
//    static var dataViewModel = DataNStorageViewModel(rss: db.rss, rssItem: db.rssItem)
    
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
//    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
//    static let settingViewModel = SettingViewModel()
//    static let rssFeedViewModel = RSSFeedViewModel(rss: RSS(context: Persistence.current.context), dataSource: DataSourceService.current.rssItem)
//    static let unreadListViewModel = UnreadListViewModel(dataSource: DataSourceService.current.rssItem)
//    static let rss = RSS()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
//        UITableView.appearance().separatorColor = UIColor(Color("Color")) //accent
//        UITableView.appearance().backgroundColor = UIColor(Color("Color")) //accent
        
        let contentView = HomeView(viewModel: SceneDelegate.viewModel)//.environmentObject(SceneDelegate.viewModel)
        //viewModel: SceneDelegate.viewModel,
        //unreadListViewModel: SceneDelegate.unreadListViewModel
        
//        let onboardingViewModel = OnboardingViewModel()
//        let onboarding = Onboarding(viewModel: onboardingViewModel)
//        let onboardingHost = UIHostingController(rootView: onboarding)

//        onboardingViewModel.finishedOnboarding = {
//            UserDefaults.showOnboarding = false
//            onboardingHost.dismiss(animated: false, completion: nil)
//        }


        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
            
//            if UserDefaults.showOnboarding {
//                onboardingHost.view.backgroundColor = .clear
//                onboardingHost.modalPresentationStyle = .fullScreen
//                window.rootViewController?.present(onboardingHost, animated: true, completion: nil)
//            }

        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    var autoReloadTimer: Timer?
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
//        startReloadTimer()
//        RSSStore.instance.refreshExtensionFeeds()
//        ReadItLaterStore.instance.refreshExtensionItems()
//        RSSStore.instance.reloadAllPosts()
    }
    
//    func startReloadTimer() {
//        guard RSSStore.instance.notificationsEnabled else { return }
//
//        let currentReloadTime = RSSStore.instance.fetchContentType.seconds
//
//        // TODO: make this work with Rx
//        autoReloadTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(currentReloadTime), repeats: true) { timer in
//            if currentReloadTime != RSSStore.instance.fetchContentType.seconds {
//                timer.invalidate()
//                self.startReloadTimer()
//            }
//            RSSStore.instance.reloadAllPosts()
//        }
//    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        autoReloadTimer?.invalidate()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        (UIApplication.shared.delegate as! AppDelegate).scheduleAppRefresh()
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()

    }


}

extension CATransition {
    func fadeTransition() -> CATransition {
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromRight

        return transition
    }
}
//import UIKit
//import SwiftUI
//
//@main
//struct FeeditApp: App {
//
//    @Environment(\.scenePhase) private var scenePhase
////    static let articles = AllArticlesStorage(managedObjectContext: Persistence.current.context)
//    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
//    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
//    static let settingViewModel = SettingViewModel()
//    static let rssFeedViewModel = RSSFeedViewModel(rss: RSS(context: Persistence.current.context), dataSource: DataSourceService.current.rssItem)
//    static let rss = RSS()
//
//    var body: some Scene {
//        WindowGroup{
//            HomeView(viewModel: FeeditApp.viewModel, archiveListViewModel: FeeditApp.archiveListViewModel, rssFeedViewModel: FeeditApp.rssFeedViewModel)
//                //viewModel: FeeditApp.viewModel, archiveListViewModel: FeeditApp.archiveListViewModel, rssFeedViewModel: FeeditApp.rssFeedViewModel)
//        }//articles: FeeditApp.articles,
//        .onChange(of: scenePhase) { (newScenePhase) in
//            switch newScenePhase {
//            case .active:
//                print("scene is now active!")
//            case .inactive:
//                print("scene is now inactive!")
//            case .background:
//                print("scene is now in the background!")
//            @unknown default:
//                print("Apple must have added something new!")
//            }
//        }
//    }
//}
//
////extension List {
////    @ViewBuilder func noSeparators() -> some View {
////        #if swift(>=5.3) // Xcode 12
////        if #available(iOS 14.0, *) { // iOS 14
////            self
////            .accentColor(Color.secondary)
////            .listStyle(SidebarListStyle())
////            .onAppear {
////                UITableView.appearance().backgroundColor = UIColor.systemBackground
////            }
////        } else { // iOS 13
////            self
////                        .listStyle(PlainListStyle())
////            .onAppear {
////                UITableView.appearance().separatorStyle = .none
////            }
////        }
////        #else // Xcode 11.5
////        self
////                .listStyle(PlainListStyle())
////        .onAppear {
////            UITableView.appearance().separatorStyle = .none
////        }
////        #endif
////    }
////}
////struct ListSwipeActions: ViewModifier {
////
////    @ObservedObject var coordinator = Coordinator()
////
////    func body(content: Content) -> some View {
////
////        return content
////            .introspectTableView { tableView in
////                tableView.delegate = self.coordinator
////            }
////    }
////
//////    class Coordinator: NSObject, ObservableObject, UITableViewDelegate {
//////
//////        func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//////            return .delete
//////        }
//////
//////        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//////
//////            let archiveAction = UIContextualAction(style: .normal, title: "Title") { action, view, completionHandler in
//////                // update data source
//////                completionHandler(true)
//////            }
//////            archiveAction.image = UIImage(systemName: "archivebox")!
//////            archiveAction.backgroundColor = .systemYellow
//////
//////            let configuration = UISwipeActionsConfiguration(actions: [archiveAction])
//////
//////            return configuration
//////        }
//////    }
////}
//
////extension List {
////    func swipeActions() -> some View {
////        return self.modifier(ListSwipeActions())
////    }
////}
//extension UINavigationController {
//    override open func viewDidLoad() {
//        super.viewDidLoad()
//
//        UITabBar.appearance().shadowImage = UIImage()
//        UITabBar.appearance().backgroundImage = UIImage()
//        UITabBar.appearance().isTranslucent = false
//        UITabBar.appearance().backgroundColor = .black
//
//    let standard = UINavigationBarAppearance()
//        standard.backgroundColor = UIColor(Color("accent")) //UIColor(Color("accent"))//.black//UIColor(Color("tab")) //When you scroll or you have title (small one)
//
//    let compact = UINavigationBarAppearance()
//        compact.backgroundColor = UIColor(Color("accent")) //UIColor(Color("accent"))//.black//UIColor(Color("tab")) //compact-height
//
//    let scrollEdge = UINavigationBarAppearance()
//        scrollEdge.backgroundColor = UIColor(Color("accent")) //UIColor(Color("accent"))//.black//UIColor(Color("tab")) //.systemGray6 //When you have large title
//
//    navigationBar.standardAppearance = standard
//    navigationBar.compactAppearance = compact
//    navigationBar.scrollEdgeAppearance = scrollEdge
//
//
//
// }
//}
////
////class SceneDelegate: UIResponder, UIWindowSceneDelegate {
////
////    var window: UIWindow?
////
////    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//////    init(viewModel:sources:isEditing:showingContent:)
////        let contentView = ContentView()
////
//////            .tabViewStyle(PageTabViewStyle())
//////            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
////
////        // Use a UIHostingController as window root view controller.
////        if let windowScene = scene as? UIWindowScene {
////            let window = UIWindow(windowScene: windowScene)
////            window.rootViewController = UIHostingController(rootView: contentView)
////            self.window = window
////            window.makeKeyAndVisible()
////        }
////    }
////
////    func sceneDidDisconnect(_ scene: UIScene) {
////        // Called as the scene is being released by the system.
////        // This occurs shortly after the scene enters the background, or when its session is discarded.
////        // Release any resources associated with this scene that can be re-created the next time the scene connects.
////        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
////    }
////
////    func sceneDidBecomeActive(_ scene: UIScene) {
////        // Called when the scene has moved from an inactive state to an active state.
////        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
////    }
////
////    func sceneWillResignActive(_ scene: UIScene) {
////        // Called when the scene will move from an active state to an inactive state.
////        // This may occur due to temporary interruptions (ex. an incoming phone call).
////    }
////
////    func sceneWillEnterForeground(_ scene: UIScene) {
////        // Called as the scene transitions from the background to the foreground.
////        // Use this method to undo the changes made on entering the background.
////    }
////
////    func sceneDidEnterBackground(_ scene: UIScene) {
////        // Called as the scene transitions from the foreground to the background.
////        // Use this method to save data, release shared resources, and store enough scene-specific state information
////        // to restore the scene back to its current state.
////
////        // Save changes in the application's managed object context when the application transitions to the background.
////        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
////    }
////
////}
