//
//  Feeditapp.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.

import UIKit
import SwiftUI
import BackgroundTasks

//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//
//    var window: UIWindow?
//
//    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
//
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
//        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
//        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
//
////        let contentView = HomeView(viewModel: SceneDelegate.viewModel)
//
//        // Use a UIHostingController as window root view controller.
//        if let windowScene = scene as? UIWindowScene {
////            _ = RSSListViewModel(dataSource: DataSourceService.current.rss)
//            let context = CoreData.stack.context
//            let window = UIWindow(windowScene: windowScene)
//            window.rootViewController = UIHostingController(rootView: ContentView()
//                .environment(\.managedObjectContext, context)
//                .environmentObject(UserEnvironment())
//)
//
//            self.window = window
//            window.makeKeyAndVisible()
//
//        }
//    }
//
//    func sceneDidDisconnect(_ scene: UIScene) {
//        // Called as the scene is being released by the system.
//        // This occurs shortly after the scene enters the background, or when its session is discarded.
//        // Release any resources associated with this scene that can be re-created the next time the scene connects.
//        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
//    }
//
//    var autoReloadTimer: Timer?
//
//    func sceneDidBecomeActive(_ scene: UIScene) {
//        // Called when the scene has moved from an inactive state to an active state.
//        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
//        startReloadTimer()
////        RSSStore.instance.refreshExtensionFeeds()
////        ReadItLaterStore.instance.refreshExtensionItems()
//        RSSStore.instance.reloadAllPosts()
//    }
//
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
//
//    func sceneWillResignActive(_ scene: UIScene) {
//        // Called when the scene will move from an active state to an inactive state.
//        // This may occur due to temporary interruptions (ex. an incoming phone call).
//        autoReloadTimer?.invalidate()
//    }
//
//    func sceneWillEnterForeground(_ scene: UIScene) {
//        // Called as the scene transitions from the background to the foreground.
//        // Use this method to undo the changes made on entering the background.
//    }
//
//    func sceneDidEnterBackground(_ scene: UIScene) {
//        // Called as the scene transitions from the foreground to the background.
//        // Use this method to save data, release shared resources, and store enough scene-specific state information
//        // to restore the scene back to its current state.
//
//        CoreData.stack.save()
////        (UIApplication.shared.delegate as! AppDelegate).scheduleAppRefresh()
////        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
//
//    }
//
//
//}
//
//extension CATransition {
//    func fadeTransition() -> CATransition {
//        let transition = CATransition()
//        transition.duration = 0.4
//        transition.type = CATransitionType.fade
//        transition.subtype = CATransitionSubtype.fromRight
//
//        return transition
//    }
//}
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let homeView = HomeView(viewModel: self.viewModel)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: homeView)
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

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
