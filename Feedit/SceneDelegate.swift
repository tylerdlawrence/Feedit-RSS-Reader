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

//    override init() {
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color("tab"))]
//        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color("tab"))]
//    }
    @EnvironmentObject var iconSettings: IconNames

    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var persistence: Persistence
    @Environment(\.managedObjectContext) private var context

    let unread = Unread(dataSource: DataSourceService.current.rssItem)
    let articles = AllArticles(dataSource: DataSourceService.current.rssItem)
    let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    let rss = RSS()
    let rssItem = RSSItem()
    
    private(set) static var shared: SceneDelegate?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//
//            if let url = URLContexts.first?.url {
//                let urlStr = url.absoluteString
//                if let productID = urlStr.replacingOccurences(of: "feeditrssreader://", with: "") as String? {
//                    self.pushToDetailScreen(detail: productID)
//                }
//            }
//            
//            guard let _ = (scene as? UIWindowScene) else { return }
//            self.scene(scene, openURLContexts: connectionOptions.urlContexts)
        let homeView =
//            ContentView(rssFeedViewModel: RSSFeedViewModel(rss: self.rss, dataSource: DataSourceService.current.rssItem), archiveListViewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
            HomeView(articles: self.articles, unread: self.unread, rssItem: self.rssItem, viewModel: self.viewModel, rssFeedViewModel: RSSFeedViewModel(rss: self.rss, dataSource: DataSourceService.current.rssItem), archiveListViewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem), persistence: Persistence.current)
            
            .environmentObject(iconSettings)
                .environmentObject(DataSourceService.current.rssItem)
                .environmentObject(Persistence.current)


        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: homeView) //.environmentObject(IconNames()))
            self.window = window
            window.makeKeyAndVisible()
        }
    }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

//    func sceneDidEnterBackground(_ scene: UIScene) {
//        // Called as the scene transitions from the foreground to the background.
//        // Use this method to save data, release shared resources, and store enough scene-specific state information
//        // to restore the scene back to its current state.
//
//        // Save changes in the application's managed object context when the application transitions to the background.
//        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
//    }
}

class IconNames: ObservableObject {
    var iconNames: [String?] = [nil]
    @Published var currentIndex = 0
    
    init() {
        getAlternateIcons()
        
        if let currentIcon = UIApplication.shared.alternateIconName {
            self.currentIndex = iconNames.firstIndex(of: currentIcon) ?? 0
        }
    }
    
    func getAlternateIcons() {
        if let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
           let alternateIcons = icons["CFBundleAlternativeIcons"] as? [String: Any] {
            
            for(_, value) in alternateIcons {
                guard let iconList = value as? Dictionary<String, Any> else { return }
                guard let iconFiles = iconList["CFBundleIconFiles"] as? [String] else { return }
                
                guard let icon = iconFiles.first else { return }
                
                iconNames.append(icon)
            }
        }
    }
}

struct ToggleModel {
    var isDark: Bool = true {
        didSet {
            SceneDelegate.shared?.window!.overrideUserInterfaceStyle = isDark ? .dark : .light
        }
    }
}
