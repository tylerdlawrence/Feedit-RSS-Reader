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

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let defaultImage = "https://images.unsplash.com/photo-1579273166152-d725a4e2b755?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=905&q=80"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if ProcessInfo.processInfo.arguments.contains("UI-Testing"), let bundleName = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleName)
        }
        
        UNUserNotificationCenter.current().delegate = self
        registerBackgroundTasks()
        
        return true
    }
        
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "RSS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //MARK: This function will be called right after user tap on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //MARK: tell the app that we have finished processing the user’s action / response
        RSSStore.instance.shouldSelectFeedURL = response.notification.request.content.userInfo["feedURL"] as? String
        completionHandler()
    }
}

//MARK: macOS
extension AppDelegate {
    override func buildMenu(with builder: UIMenuBuilder) {
        let reloadCommand =
            UIKeyCommand(title: NSLocalizedString("Reload", comment: ""),
                         image: nil,
                         action: #selector(reloadAllPosts),
                         input: "R",
                         modifierFlags: .command,
                         propertyList: nil)
        
        let settingsCommand =
            UIKeyCommand(title: NSLocalizedString("Settings", comment: ""),
                         image: nil,
                         action: #selector(openSettings),
                         input: "S",
                         modifierFlags: .command,
                         propertyList: nil)
        let openSettings =
            UIMenu(title: "",
                   image: nil,
                   identifier: UIMenu.Identifier("io.lucasfarah.Update.menu"),
                   options: .displayInline,
                   children: [reloadCommand, settingsCommand])
        
        builder.insertChild(openSettings, atStartOfMenu: .file)
    }
    
    @objc func openSettings() {
        RSSStore.instance.shouldOpenSettings = true
    }
    
    @objc func reloadAllPosts() {
        RSSStore.instance.reloadAllPosts()
    }
}

//MARK: Background app refresh
extension AppDelegate {
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "io.lucasfarah.update.fetchposts", using: DispatchQueue.global()) { task in
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
        
        let request = BGAppRefreshTaskRequest(identifier: "io.lucasfarah.update.fetchposts")
        request.earliestBeginDate = Date(timeIntervalSinceNow: TimeInterval(RSSStore.instance.fetchContentType.seconds))
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch let error {
            print("Could not schedule app refresh: \(error)")
        }
    }
}
