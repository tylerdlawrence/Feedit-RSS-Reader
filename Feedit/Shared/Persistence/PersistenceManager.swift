//
//  PersistenceManager.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation
import CoreData
import Combine
import os.log
import SwiftUI
import UIKit

public extension URL {

    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

class Persistence: ObservableObject {

    static private(set) var current = Persistence(version: 1)
    private var subscriptions: Set<AnyCancellable> = []
    let appTransactionAuthorName = "app"
    private let isStoreLoaded = CurrentValueSubject<Bool, Error>(false)
    
    lazy var persistentContainer: NSPersistentContainer = {
        // Create a container that can load CloudKit-backed stores
        let container = NSPersistentCloudKitContainer(name: "feeditrssreader")
        
        // Enable history tracking and remote notifications
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("###\(#function): Failed to retrieve a persistent store description.")
        }
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else { return }
            fatalError("###\(#function): Failed to load persistent stores:\(error)")
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            container.viewContext.transactionAuthor = appTransactionAuthorName
               container.viewContext.automaticallyMergesChangesFromParent = true
            do {
                try container.viewContext.setQueryGenerationFrom(.current)
            } catch {
                assertionFailure("###\(#function): Failed to pin viewContext to the current generation:\(error)")
            }
        
        // Observe Core Data remote change notifications.
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).storeRemoteChange(_:)),
            name: .NSPersistentStoreRemoteChange, object: container)
        
        NotificationCenter.default
              .publisher(for: .NSPersistentStoreRemoteChange)
              .sink {
                self.storeRemoteChange($0)
              }
              .store(in: &subscriptions)
        
        return container
    }()

    /**
     Track the last history token processed for a store, and write its value to file.
     
     The historyQueue reads the token when executing operations, and updates it after processing is complete.
     */
    private var lastHistoryToken: NSPersistentHistoryToken? = nil {
        didSet {
            guard let token = lastHistoryToken,
                let data = try? NSKeyedArchiver.archivedData( withRootObject: token, requiringSecureCoding: true) else { return }
            
            do {
                try data.write(to: tokenFile)
            } catch {
                print("###\(#function): Failed to write token data. Error = \(error)")
            }
        }
    }
    
    /**
     The file URL for persisting the persistent history token.
    */
    private lazy var tokenFile: URL = {
        let url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("CoreDataCloudKitDemo", isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("###\(#function): Failed to create persistent container URL. Error = \(error)")
            }
        }
        return url.appendingPathComponent("token.data", isDirectory: false)
    }()
    
    /**
     An operation queue for handling history processing tasks: watching changes, deduplicating tags, and triggering UI updates if needed.
     */
    private lazy var historyQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    init(directory: FileManager.SearchPathDirectory = .documentDirectory,
         domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
         version vNumber: UInt) {
        let version = Version(vNumber)
        container = NSPersistentContainer(name: version.modelName)
        if let url = version.dbFileURL(directory, domainMask) {
            let store = NSPersistentStoreDescription(url: url)
            container.persistentStoreDescriptions = [store]
        }
        container.loadPersistentStores { [weak isStoreLoaded] (storeDescription, error) in
            if let error = error {
                isStoreLoaded?.send(completion: .failure(error))
            } else {
                isStoreLoaded?.value = true
            }
        }
        // Load the last token from the token file.
        if let tokenData = try? Data(contentsOf: tokenFile) {
            do {
                lastHistoryToken = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSPersistentHistoryToken.self, from: tokenData)
            } catch {
                print("###\(#function): Failed to unarchive NSPersistentHistoryToken. Error = \(error)")
            }
        }
    }
    
    let container: NSPersistentContainer
    
//    var context: NSManagedObjectContext {
//      return container.viewContext
//    }
    
    var context: NSManagedObjectContext {
        let c = container.viewContext
        c.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return c
    }
    
    func saveChanges() {
      guard context.hasChanges else { return }

      do {
        try context.save()
      } catch {
        let nsError = error as NSError
        os_log(.error, log: .default, "Error saving changes %@", nsError)
      }
    }
    
    func deleteManagedObjects(_ objects: [NSManagedObject]) {
      context.perform { [context = context] in
        objects.forEach(context.delete)
        self.saveChanges()
      }
    }

    func addNewGroup(name: String) {
      context.perform { [context = context] in
        let group = RSSGroup(context: context)
        group.id = UUID()
        group.name = name
        self.saveChanges()
      }
    }
}

extension NSPersistentContainer {
    func backgroundContext() -> NSManagedObjectContext {
        let appTransactionAuthorName = "app"
        let context = newBackgroundContext()
        context.transactionAuthor = appTransactionAuthorName
        return context
    }
}

extension Persistence {
    func processPersistentHistory() {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.performAndWait {

            // Fetch history received from outside the app since the last token
            let historyFetchRequest = NSPersistentHistoryTransaction.fetchRequest!
            historyFetchRequest.predicate = NSPredicate(format: "author != %@", appTransactionAuthorName)
            let request = NSPersistentHistoryChangeRequest.fetchHistory(after: lastHistoryToken)
            request.fetchRequest = historyFetchRequest

            let result = (try? backgroundContext.execute(request)) as? NSPersistentHistoryResult
            guard let transactions = result?.result as? [NSPersistentHistoryTransaction],
                  !transactions.isEmpty
                else { return }

            print("transactions = \(transactions)")
            self.mergeChanges(from: transactions)

            // Update the history token using the last transaction.
            lastHistoryToken = transactions.last!.token
        }
    }
}

extension Persistence {
    private func mergeChanges(from transactions: [NSPersistentHistoryTransaction]) {
        
            context.perform {
                transactions.forEach { [weak self] transaction in
                    guard let self = self, let userInfo = transaction.objectIDNotification().userInfo else { return }
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: userInfo, into: [self.context])
            }
        }
    }
}

extension Persistence {
    /**
     Handle remote store change notifications (.NSPersistentStoreRemoteChange).
     */
    @objc
    func storeRemoteChange(_ notification: Notification) {
        print("###\(#function): Merging changes from the other persistent store coordinator.")
        
        // Process persistent history to merge changes from other coordinators.
        historyQueue.addOperation {
            self.processPersistentHistory()
        }
    }
}

extension Persistence {
    struct Version {
        private let number: UInt

        init(_ number: UInt) {
            self.number = number
        }

        var modelName: String {
            return "RSS"
        }

        func dbFileURL(_ directory: FileManager.SearchPathDirectory,
                       _ domainMask: FileManager.SearchPathDomainMask) -> URL? {
            return FileManager.default
                .urls(for: directory, in: domainMask).first?
                .appendingPathComponent(subpathToDB)
        }

        private var subpathToDB: String {
            return "\(modelName).sql"
        }
    }
}


struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController()
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Settings(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "feeditrssreader")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
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
    }
}

//extension Persistence {
//  static var random: Persistence = {
//    let controller = Persistence(version: 1)
//    controller.context.perform {
//      for i in 0..<1 {
//        controller.makeRandomFolder(context: controller.context)      }
//      for i in 0..<1 {
//        controller.makeRandomFolder(context: controller.context)
//      }
//    }
//    return controller
//  }()
//
//    func makeRandomFolder(context: NSManagedObjectContext) -> RSSGroup {
//        let group = RSSGroup()
//        group.id = UUID()
//        group.name = "Default Folder"
//        group.items = [
//            makeRandomFolder(context: context),
//            makeRandomFolder(context: context),
//            makeRandomFolder(context: context)
//        ]
//        return group
//    }
//}

public class Settings: NSManagedObject, Identifiable {
    @NSManaged public var layoutValue: Double
    @NSManaged public var timestamp: Date
    @NSManaged public var alternateIconName: String?
    @NSManaged public var accentColorData: Data?
    @NSManaged public var textSizeModifier: Double

    convenience init(context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Settings", in: context) else {
            fatalError("No entity named Settings")
        }
        self.init(entity: entity, insertInto: context)
        self.layoutValue = Settings.Layout.Default.rawValue
        self.timestamp = Date()
        self.alternateIconName = nil
        self.accentColorData = UIColor(Color("tab")).data
//            UIColor.init(red: 158.0/255.0, green: 38.0/255.0, blue: 27.0/255.0, alpha: 1.0).data
        self.textSizeModifier = 0.0
    }

    enum Layout: Double, Equatable, Comparable {
        static func < (lhs: Settings.Layout, rhs: Settings.Layout) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }

        case compact = 0.0
        case comfortable = 1.0
        case Default = 2.0
    }

    var layout: Layout {
        return Layout(rawValue: self.layoutValue) ?? Layout.Default
    }

    var defaultAccentColor: UIColor {
        return UIColor(Color("tab"))
//            UIColor.init(red: 158.0/255.0, green: 38.0/255.0, blue: 27.0/255.0, alpha: 1.0)
    }

    var accentUIColor: UIColor {
        get {
            guard let data = self.accentColorData  else {
                return defaultAccentColor
            }
            guard let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
                return defaultAccentColor
            }
            return color
        } set {
            self.accentColorData = newValue.data
            try? self.managedObjectContext?.save()
        }

    }

    var accentColor: Color {
        return Color(accentUIColor)
    }
}

extension Settings {
    // ❇️ The @FetchRequest property wrapper in the ContentView will call this function
    static func fetchAllRequest() -> NSFetchRequest<Settings> {
        let request: NSFetchRequest<Settings> = Settings.fetchRequest() as! NSFetchRequest<Settings>

        // ❇️ The @FetchRequest property wrapper in the ContentView requires a sort descriptor
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        return request
    }
}

//https://stackoverflow.com/a/63003757/193772
extension UIColor {
    func mix(with color: UIColor, amount: CGFloat) -> Self {
        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        var alpha1: CGFloat = 0

        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        var alpha2: CGFloat = 0

        getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

        return Self(
            red: red1 * CGFloat(1.0 - amount) + red2 * amount,
            green: green1 * CGFloat(1.0 - amount) + green2 * amount,
            blue: blue1 * CGFloat(1.0 - amount) + blue2 * amount,
            alpha: alpha1
        )
    }

    func lighter(by amount: CGFloat = 0.2) -> Self { mix(with: .white, amount: amount) }
    func darker(by amount: CGFloat = 0.2) -> Self { mix(with: .black, amount: amount) }
}

extension UIColor {
    var data: Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}

extension UIColor {
    
    static var feeditBlue = UIColor(Color("tab"))
//        UIColor.init(red: 158.0/255.0, green: 38.0/255.0, blue: 27.0/255.0, alpha: 1.0)
    
    var name: String? {
        if #available(iOS 13.0, *) {
            switch self {
                case .systemIndigo:
                    return "System Indigo"
            default:
                break
            }
        }
        switch self {
        case .feeditBlue:
            return "Feedit Blue"
        case .systemPurple:
            return "System Purple"
        case .systemOrange:
            return "System Orange"
        case .systemTeal:
            return "System Teal"
        case .systemPink:
            return "System Pink"
        case .systemBlue:
            return "System Blue"
        case .systemRed:
            return "System Red"
        case .systemGray:
            return "System Gray"
        case .systemGreen:
            return "System Green"
        case .systemYellow:
            return "System Yellow"
        case .white:
            return "White"
        case .black:
            return "Black"
        default:
            return nil
        }
    }
}
