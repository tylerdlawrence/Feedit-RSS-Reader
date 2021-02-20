//
//  RSS+CoreDataClass.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation
import CoreData
import SwiftUI
import FeedKit
import FaviconFinder
import Combine
import BackgroundTasks

@objc(RSS)
class RSS: NSManagedObject, Identifiable {
}

extension Sequence {
    func sum<T: Numeric>(for keyPath: KeyPath<Element, T>) -> T {
        return reduce(0) { sum, element in
            sum + element[keyPath: keyPath]
        }
    }
}
