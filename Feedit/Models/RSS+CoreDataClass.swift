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
    var context: [RSSItem] = [] {
        didSet {
            objectWillChange.send()
        }
    }
    
}

