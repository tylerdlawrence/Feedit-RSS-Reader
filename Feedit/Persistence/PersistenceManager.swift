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

class Persistence: ObservableObject {
    static let shared = Persistence(version: 1)
    
    static private(set) var current = Persistence(version: 1)
    
    private static let authorName = "Author"
    private static let remoteDataImportAuthorName = "Data Import"

    var context: NSManagedObjectContext {
      return container.viewContext
    }

    private let container: NSPersistentContainer
    private var subscriptions: Set<AnyCancellable> = []
        
//    var context: NSManagedObjectContext {
//        let c = container.viewContext
//        c.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        return c
//    }
//    var container: NSPersistentContainer
    
    private let isStoreLoaded = CurrentValueSubject<Bool, Error>(false)
    
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

//class Persistence: ObservableObject {
//    private let persistence = Persistence.current
//
//    lazy var managedObjectContext: NSManagedObjectContext = {
//        let context = self.persistentContainer.viewContext
//        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        return context
//    }()
//
//    lazy var persistentContainer: NSPersistentContainer  = {
//        let container = NSPersistentContainer(name: "RSS")
//        container.loadPersistentStores { (persistentStoreDescription, error) in
//            if let error = error {
//                fatalError(error.localizedDescription)
//            }
//        }
//        return container
//    }()
//
//    var context: NSManagedObjectContext {
//        return persistence.context
//    }
//}

extension Persistence {
  static var preview: Persistence = {
    let controller = Persistence(version: 1)
    controller.context.perform {
      for i in 0..<100 {
        controller.makeRandomFolder(context: controller.context)
      }
      for i in 0..<5 {
        controller.makeRandomFolder(context: controller.context)
      }
    }
    return controller
  }()
    
    @discardableResult
    func makeRandomFolder(context: NSManagedObjectContext) -> RSSGroup {
        let group = RSSGroup(context: context)
        group.id = UUID()
        group.name = "Default Folder"
        group.items = [
            makeRandomFolder(context: context),
            makeRandomFolder(context: context),
            makeRandomFolder(context: context)
        ]
      return group
    }
}
