//
//  Feeditapp.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.

import UIKit
import SwiftUI
import BackgroundTasks
import WidgetKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
//    override init() {
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color("tab"))]
//        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color("tab"))]
//    }
    @EnvironmentObject var iconSettings: IconNames
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.managedObjectContext) private var moc

    @StateObject private var unread = Unread(dataSource: DataSourceService.current.rssItem)
    @StateObject private var articles = AllArticles(dataSource: DataSourceService.current.rssItem)
    @StateObject private var viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    @StateObject private var rss = RSS()
    @StateObject private var rssItem = RSSItem()
    
    private(set) static var shared: SceneDelegate?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let homeView =
            HomeView(articles: articles, unread: unread, rssItem: rssItem, viewModel: viewModel, selectedFilter: FilterType.all)
                .environmentObject(iconSettings)
                .environmentObject(viewModel)
                .environmentObject(articles)
                .environmentObject(unread)
                .environmentObject(rss)
                .environmentObject(rssItem)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: homeView)
            self.window = window
            window.makeKeyAndVisible()
        }
        if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                    WidgetCenter.shared.reloadAllTimelines()
                } catch let error {
                    print("Error Save Oppty: \(error.localizedDescription)")
                }

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
