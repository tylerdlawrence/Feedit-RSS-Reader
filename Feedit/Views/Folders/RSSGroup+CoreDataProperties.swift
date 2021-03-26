//
//  RSSGroup+CoreDataProperties.swift
//  
//
//  Created by Tyler D Lawrence on 3/25/21.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension RSSGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RSSGroup> {
        return NSFetchRequest<RSSGroup>(entityName: "RSSGroup")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var itemCount: Int64
    @NSManaged public var name: String?
    @NSManaged public var url: String?
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension RSSGroup {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: RSS)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: RSS)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension RSSGroup : Identifiable {

}
