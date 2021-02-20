//
//  RSSFolderView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/22/20.
//
//import SwiftUI
//import CoreData
//import Foundation
//
//struct RSSFolderView: View {
//
//    // ❇️ Core Data property wrappers
//    @Environment(\.managedObjectContext) var managedObjectContext
//
//    // ❇️ The BlogIdea class has an `allIdeasFetchRequest` static function that can be used here
//    @FetchRequest(fetchRequest: RSSFolderList.allRSSFoldersFetchRequest()) var rssFolderLists: FetchedResults<RSSFolderList>
//
//    // ℹ️ Temporary in-memory storage for adding new blog ideas
//    @State private var newFolderTitle = ""
//    @State private var newFolderDescription = ""
//
//    // ℹ️ Two sections: Add Blog Idea at the top, followed by a listing of the ideas in the persistent store
//
//    var body: some View {
//            Section(header: Text("Add Blog Idea")) {
//            VStack {
//                VStack {
//                    TextField("Idea title", text: self.$newFolderTitle)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    TextField("Idea description", text: self.$newFolderDescription)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                }
//            }
//
//
//                VStack {
//                    Button(action: ({
//                        // ❇️ Initializes new BlogIdea and saves using the @Environment's managedObjectContext
//                        let folder = RSSFolderList(context: self.managedObjectContext)
//                        folder.folderTitle = self.newFolderTitle
//                        folder.folderDescription = self.newFolderDescription
//
//                        do {
//                            try self.managedObjectContext.save()
//                        } catch {
//                            print(error)
//                        }
//
//                        // ℹ️ Reset the temporary in-memory storage variables for the next new blog idea!
//                        self.newFolderTitle = ""
//                        self.newFolderDescription = ""
//                    })) {
//                        HStack {
//                            Image(systemName: "plus.circle.fill")
//                                .foregroundColor(.green)
//                                .imageScale(.large)
//                            Text("Add Idea")
//                        }
//                    }
//                }
//            }
//        }
//    Section(header: Text,("Blog Ideas")) {
//            ForEach(self.folderLists) { rssFolderList in
//                NavigationLink(destination: EditView(rssFolderList: rssFolderList)) {
//                    VStack(alignment: .leading) {
//                        Text(rssFolderList.folderTitle ?? "")
//                            .font(.headline)
//                        Text(rssFolderList.folderDescription ?? "")
//                            .font(.subheadline)
//                    }
//                }
//            }
//            .onDelete { (indexSet) in // Delete gets triggered by swiping left on a row
//                // ❇️ Gets the BlogIdea instance out of the blogIdeas array
//                // ❇️ and deletes it using the @Environment's managedObjectContext
//                let folderListToDelete = self.folderLists[indexSet.first!]
//                self.managedObjectContext.delete(folderListToDelete)
//
//                do {
//                    try self.managedObjectContext.save()
//                } catch {
//                    print(error)
//                }
//            }
//       }
//    }
//}

//#if DEBUG
//struct RSSFolderView_Previews: PreviewProvider {
//    static var previews: some View {
//
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//        let folderList = FolderList.init(context: context)
//        folderList.folderTitle = "Idea 1"
//        folderList.folderDescription = "The first idea."
//
//        return RSSFolderView()
//            .environment(\.managedObjectContext, (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
//    }
//}
//#endif
