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
    private(set) static var shared: SceneDelegate?
    var window: UIWindow?
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject var iconSettings: IconNames
    @StateObject private var viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let homeView =
            HomeView(container: DIContainer.defaultValue)
            .environmentObject(iconSettings)
            .environmentObject(self.viewModel.store)
            .environmentObject(DataSourceService.current.rss)
            .environmentObject(DataSourceService.current.rssItem)
            .environment(\.managedObjectContext, Persistence.current.context)

        //MARK: Use a UIHostingController as window root view controller.
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

    }

    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
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

struct ToggleDarkModeModel {
    var isDark: Bool = true {
        didSet {
            SceneDelegate.shared?.window!.overrideUserInterfaceStyle = isDark ? .dark : .light
        }
    }
}
