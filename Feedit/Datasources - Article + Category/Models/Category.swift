//
//  Category.swift
//  CoreDataBestPractices
//
//  Created by Antoine van der Lee on 26/10/2020.
//

import Foundation
import CoreData
import UIKit

final class Category: NSManagedObject, Identifiable {

    @NSManaged var name: String
    @NSManaged var articlesCount: Int
    @NSManaged var articles: Set<Article>!
    @NSManaged var color: UIColor
    @NSManaged var folder1: String
    @NSManaged var folder2: String
    @NSManaged var folder3: String
    @NSManaged var folder4: String
    @NSManaged var folder5: String

}
