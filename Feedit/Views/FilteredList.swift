//
//  ArticleList.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 12/19/20.
//

import SwiftUI
import CoreData

struct FilteredList<T: NSManagedObject, Content: View>: View {
  
  @Environment(\.managedObjectContext) var moc
  
  var fetchRequest: FetchRequest<T>
  
  var entityItems: FetchedResults<T> { fetchRequest.wrappedValue }
  
  // this is our content closure; we'll call this once for each item in the list
  let content: (T) -> Content
  
  init(filterKey: String,
       filterValue: String,
       @ViewBuilder content: @escaping (T) -> Content) {
    
    fetchRequest =
      FetchRequest<T>(
        entity: T.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "rssUUID = %@", filterKey, filterValue)) ////%K BEGINSWITH %@"
    
    self.content = content
  }//init
  
  var body: some View {
    List {
      ForEach(fetchRequest.wrappedValue, id: \.self) { entity in
        self.content(entity)
      }//ForEach
        .onDelete(perform: removeAccount)
    }//List
  }//body
  
  func removeAccount(at offsets: IndexSet) {
    for index in offsets {
      let oneEntity = entityItems[index]
      moc.delete(oneEntity)
    }//for
    try? moc.save()
  }//removeTransaction
}//FilteredList

struct FilteredList_Previews: PreviewProvider {
  static var previews: some View {
    FilteredList(filterKey: "createTime", filterValue: "A") { (entity: RSSItem) in
      Text("Hello, World!")
    }//FilteredList
  }//previews
}//FilteredList_Previews

