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
            fatalError("failed to save context with error: \(error)")
        }
    }
}

//extension NSManagedObjectContext {
//
//    /// Executes the given `NSBatchDeleteRequest` and directly merges the changes to bring the given managed object context up to date.
//    ///
//    /// - Parameter batchDeleteRequest: The `NSBatchDeleteRequest` to execute.
//    /// - Throws: An error if anything went wrong executing the batch deletion.
//    public func executeAndMergeChanges(using batchDeleteRequest: NSBatchDeleteRequest) throws {
//        batchDeleteRequest.resultType = .resultTypeObjectIDs
//        let result = try execute(batchDeleteRequest) as? NSBatchDeleteResult
//        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
//        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
//    }
//}
