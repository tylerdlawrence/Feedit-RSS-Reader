//
//  ManagedObjectContext.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import CoreData
import Foundation

extension NSManagedObjectContext {

    /// Describes a child managed object context.
    public typealias ChildContext = NSManagedObjectContext

    /// Describes the result type for saving a managed object context.
    public typealias SaveResult = Result<NSManagedObjectContext, Error>

    /// Attempts to **asynchronously** commit unsaved changes to registered objects in the context.
    /// This function is performed in a block on the context's queue. If the context has no changes,
    /// then this function returns immediately and the completion block is not called.
    ///
    /// - Parameter completion: The closure to be executed when the save operation completes.
    public func saveAsync(completion: ((SaveResult) -> Void)? = nil) {
        _save(wait: false, completion: completion)
    }

    /// Attempts to **synchronously** commit unsaved changes to registered objects in the context.
    /// This function is performed in a block on the context's queue. If the context has no changes,
    /// then this function returns immediately and the completion block is not called.
    ///
    /// - Parameter completion: The closure to be executed when the save operation completes.
    public func saveSync(completion: ((SaveResult) -> Void)? = nil) {
        _save(wait: true, completion: completion)
    }

    /// Attempts to commit unsaved changes to registered objects in the context.
    ///
    /// - Parameter wait: If `true`, saves synchronously. If `false`, saves asynchronously.
    /// - Parameter completion: The closure to be executed when the save operation completes.
    private func _save(wait: Bool, completion: ((SaveResult) -> Void)? = nil) {

        let block = {
            guard self.hasChanges else { return }
            do {
                try self.save()
                completion?(.success(self))
            } catch {
                completion?(.failure(error))
            }
        }
        wait ? performAndWait(block) : perform(block)
    }
    /// Quickly save the context by assuming that the throw will not happen.
    @objc func quickSave() {
        guard hasChanges else { return }
        do {
            try save()
        } catch {
            fatalError("failed to save context with error: \(error)")
        }
    }
}

extension NSManagedObjectContext {

    /// Create a child context and set itself as the parent.
    func newChildContext(type: NSManagedObjectContextConcurrencyType = .mainQueueConcurrencyType, mergesChangesFromParent: Bool = true) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: type)
        context.parent = self
        context.automaticallyMergesChangesFromParent = mergesChangesFromParent
        return context
    }
}

extension NSManagedObjectContext {

    func configureAsReadOnlyContext() {
        automaticallyMergesChangesFromParent = true
        mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        undoManager = nil
        shouldDeleteInaccessibleFaults = true
    }

    func configureAsUpdateContext() {
        mergePolicy = NSOverwriteMergePolicy
        undoManager = nil
    }
}

extension NSManagedObjectContext {
    public func delete<Objects: RandomAccessCollection>(_ objects: Objects) where Objects.Element: NSManagedObject {
        for object in objects {
            delete(object)
        }
    }
}

extension NSManagedObject {
    
    /// Get the object from another context using it `objectID`.
    func get(from context: NSManagedObjectContext) -> Self {
        context.object(with: objectID) as! Self
    }
}
