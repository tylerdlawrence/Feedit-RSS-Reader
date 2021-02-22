//
//  PersistenceManager.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation
import CoreData
import Combine

//class Persistence {
//
//    static private(set) var current = Persistence(version: 1)
//
//    var context: NSManagedObjectContext {
//        let c = container.viewContext
//        c.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        return c
//    }
//    var container: NSPersistentContainer
//
//    private let isStoreLoaded = CurrentValueSubject<Bool, Error>(false)
//
//    init(directory: FileManager.SearchPathDirectory = .documentDirectory,
//         domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
//         version vNumber: UInt) {
//        let version = Version(vNumber)
//        container = NSPersistentContainer(name: version.modelName)
//        if let url = version.dbFileURL(directory, domainMask) {
//            let store = NSPersistentStoreDescription(url: url)
//            container.persistentStoreDescriptions = [store]
//        }
//        container.loadPersistentStores { [weak isStoreLoaded] (storeDescription, error) in
//            if let error = error {
//                isStoreLoaded?.send(completion: .failure(error))
//            } else {
//                isStoreLoaded?.value = true
//            }
//        }
//    }
//}
//
//extension Persistence {
//    struct Version {
//        private let number: UInt
//
//        init(_ number: UInt) {
//            self.number = number
//        }
//
//        var modelName: String {
//            return "RSS"
//        }
//
//        func dbFileURL(_ directory: FileManager.SearchPathDirectory,
//                       _ domainMask: FileManager.SearchPathDomainMask) -> URL? {
//            return FileManager.default
//                .urls(for: directory, in: domainMask).first?
//                .appendingPathComponent(subpathToDB)
//        }
//
//        private var subpathToDB: String {
//            return "\(modelName).sql"
//        }
//    }
//}
class CoreData: NSObject {
    
    static let stack = CoreData()   // Singleton
    
    // MARK: - Core Data stack
    
    private lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "RSS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let nserror = error as NSError? {
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        })
        return container
    }()
    
    public var context: NSManagedObjectContext {
        
        get {
            return self.persistentContainer.viewContext
        }
    }
    
    // MARK: - Core Data Saving support
    
    public func save() {
        
        if self.context.hasChanges {
            do {
                try self.context.save()
                print("In CoreData.stack.save()")
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Managed Object Helpers
    
    class func executeBlockAndCommit(_ block: @escaping () -> Void) {
        
        block()
        CoreData.stack.save()
    }
    
}
