//
//  ManagedObjectContext.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import CoreData

extension NSManagedObjectContext {
    
    /// Create a child context and set itself as the parent.
    func newChildContext(type: NSManagedObjectContextConcurrencyType = .mainQueueConcurrencyType, mergesChangesFromParent: Bool = true) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: type)
        context.parent = self
        context.automaticallyMergesChangesFromParent = mergesChangesFromParent
        return context
    }
    
    /// Quickly save the context by assuming that the throw will not happen.
    func quickSave() {
        guard hasChanges else { return }
        do {
            try save()
        } catch {
            fatalError("failed to save context")
        }
    }
}
