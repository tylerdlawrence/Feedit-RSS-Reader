//
//  Feeditapp.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import UIKit
import SwiftUI

@main
struct FeeditApp: App {
    @Environment(\.scenePhase) private var scenePhase
//    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
//
//    window.rootViewController = UIHostingController(rootView: ContentView().environment(\.managedObjectContext, context))
    
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)

    static let settingViewModel = SettingViewModel()

    var body: some Scene {
        WindowGroup{
            HomeView(viewModel: FeeditApp.viewModel, archiveListViewModel: FeeditApp.archiveListViewModel)
        }
        //(viewModel: FeeditApp.viewModel, archiveListViewModel: FeeditApp.archiveListViewModel)
        .onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase {
            case .active:
                print("scene is now active!")
            case .inactive:
                print("scene is now inactive!")
            case .background:
                print("scene is now in the background!")
            @unknown default:
                print("Apple must have added something new!")
            }
        }
    }
}

//
//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//
//    var window: UIWindow?
//
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
////    init(viewModel:sources:isEditing:showingContent:)
//        let contentView = ContentView()
//
////            .tabViewStyle(PageTabViewStyle())
////            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
//
//        // Use a UIHostingController as window root view controller.
//        if let windowScene = scene as? UIWindowScene {
//            let window = UIWindow(windowScene: windowScene)
//            window.rootViewController = UIHostingController(rootView: contentView)
//            self.window = window
//            window.makeKeyAndVisible()
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
//    func sceneDidBecomeActive(_ scene: UIScene) {
//        // Called when the scene has moved from an inactive state to an active state.
//        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
//    }
//
//    func sceneWillResignActive(_ scene: UIScene) {
//        // Called when the scene will move from an active state to an inactive state.
//        // This may occur due to temporary interruptions (ex. an incoming phone call).
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
//        // Save changes in the application's managed object context when the application transitions to the background.
//        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
//    }
//
//}
