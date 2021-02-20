//
//  AppDelegate.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import CoreData
import UIKit
import UserNotifications
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if ProcessInfo.processInfo.arguments.contains("UI-Testing"), let bundleName = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleName)
        }
        
        UNUserNotificationCenter.current().delegate = self
        registerBackgroundTasks()
        
        return true
    }
        
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "RSS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate{
    
    // This function will be called right after user tap on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // tell the app that we have finished processing the user’s action / response
        RSSStore.instance.shouldSelectFeedURL = response.notification.request.content.userInfo["feedURL"] as? String
        completionHandler()
    }
}

// macOS Menu
//extension AppDelegate {
//    override func buildMenu(with builder: UIMenuBuilder) {
//        let reloadCommand =
//            UIKeyCommand(title: NSLocalizedString("Reload", comment: ""),
//                         image: nil,
//                         action: #selector(reloadAllPosts),
//                         input: "R",
//                         modifierFlags: .command,
//                         propertyList: nil)
//
//        let settingsCommand =
//            UIKeyCommand(title: NSLocalizedString("Settings", comment: ""),
//                         image: nil,
//                         action: #selector(openSettings),
//                         input: "S",
//                         modifierFlags: .command,
//                         propertyList: nil)
//        let openSettings =
//            UIMenu(title: "",
//                   image: nil,
//                   identifier: UIMenu.Identifier("com.tylerdlawrence.Continuum.menu"),
//                   options: .displayInline,
//                   children: [reloadCommand, settingsCommand])
//        builder.insertChild(openSettings, atStartOfMenu: .file)
//    }
//
//    @objc func openSettings() {
//        RSSStore.instance.shouldOpenSettings = true
//    }
//
////    @objc func reloadAllPosts() {
////        RSSStore.instance.reloadAllPosts()
////    }
//}

// Background app refresh
extension AppDelegate {
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.tylerdlawrence.Feedit.fetchposts", using: DispatchQueue.global()) { task in
            self.handleAppRefreshTask(task: task as! BGAppRefreshTask)
        }
    }
    
    func handleAppRefreshTask(task: BGAppRefreshTask) {
        task.expirationHandler = {
            print("Task expired")
        }
        print("BACKGROUND REFRESH")

        RSSStore.instance.reloadAllPosts() {
            print("RELOADED ALL POSTS")
            task.setTaskCompleted(success: true)
            self.scheduleAppRefresh()
        }
        
        scheduleAppRefresh()
        
    }
    
    func scheduleAppRefresh() {
        guard RSSStore.instance.notificationsEnabled else { return }
        
        let request = BGAppRefreshTaskRequest(identifier: "com.tylerdlawrence.Feedit.fetchposts")
        request.earliestBeginDate = Date(timeIntervalSinceNow: TimeInterval(RSSStore.instance.fetchContentType.seconds)) // App Refresh after 1 hour.
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch let error {
            print("Could not schedule app refresh: \(error)")
        }
        
    }
    
}
//@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate {
//
//
//
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//
//
//        return true
//    }
//
//    // MARK: UISceneSession Lifecycle
//
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
//
//    // MARK: - Core Data stack
//
//    lazy var persistentContainer: NSPersistentCloudKitContainer = {
//        /*
//         The persistent container for the application. This implementation
//         creates and returns a container, having loaded the store for the
//         application to it. This property is optional since there are legitimate
//         error conditions that could cause the creation of the store to fail.
//        */
//        let container = NSPersistentCloudKitContainer(name: "RSS")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//
//                /*
//                 Typical reasons for an error here include:
//                 * The parent directory does not exist, cannot be created, or disallows writing.
//                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
//                 * The device is out of space.
//                 * The store could not be migrated to the current model version.
//                 Check the error message to determine what the actual problem was.
//                 */
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()
//
//    // MARK: - Core Data Saving support
//
//    func saveContext () {
//        let context = persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }
//
//}
