//
//  FolderList.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/22/20.
//
// ❇️ Alerts you to Core Data pieces
// ℹ️ Alerts you to general info about what my brain was thinking when I wrote the code
//

import Foundation
import CoreData

// ❇️ FolderList code generation is turned OFF in the xcdatamodeld file
public class RSSFolderList: NSManagedObject, Identifiable {
    @NSManaged public var folderTitle: String?
    @NSManaged public var folderDescription: String?
}

extension RSSFolderList {
    // ❇️ The @FetchRequest property wrapper in the ContentView will call this function
    static func allRSSFoldersFetchRequest() -> NSFetchRequest<RSSFolderList> {
        let request: NSFetchRequest<RSSFolderList> = RSSFolderList.fetchRequest() as! NSFetchRequest<RSSFolderList>
        
        // ❇️ The @FetchRequest property wrapper in the ContentView requires a sort descriptor
        request.sortDescriptors = [NSSortDescriptor(key: "folderTitle", ascending: true)]
          
        return request
    }
}
