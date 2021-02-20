//
//  EditView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/22/20.
//

import SwiftUI
import CoreData

struct EditView: View {
    // ❇️ Core Data property wrappers
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // ℹ️ This is used to "go back" when 'Save' is tapped
    @Environment(\.presentationMode) var presentationMode

    var rssFolderList: RSSFolderList
//    var blogIdea: BlogIdea

    // ℹ️ Temporary in-memory storage for updating the title and description values of a Blog Idea
    @State var updatedFolderTitle: String = ""
    @State var updatedFolderDescription: String = ""
    
    var body: some View {
        VStack {
            VStack {
                TextField("Idea title", text: $updatedFolderTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onAppear {
                        // ℹ️ Set the text field's initial value when it appears
                        self.updatedFolderTitle = self.rssFolderList.folderTitle ?? ""
                }
        
                TextField("Idea description", text: $updatedFolderDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onAppear {
                        // ℹ️ Set the text field's initial value when it appears
                        self.updatedFolderDescription = self.rssFolderList.folderDescription ?? ""
                }
            }
            
            VStack {
                Button(action: ({
                    // ❇️ Set the folders' new values from the TextField's Binding and save
                    self.rssFolderList.folderTitle = self.updatedFolderTitle
                    self.rssFolderList.folderDescription = self.updatedFolderDescription
                    
                    do {
                        try self.managedObjectContext.save()
                    } catch {
                        print(error)
                    }
                    
                    self.presentationMode.wrappedValue.dismiss()
                })) {
                    Text("Save")
                }
            .padding()
            }
        }
    }
}
