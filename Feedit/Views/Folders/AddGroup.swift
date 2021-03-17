//
//  AddGroup.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/14/21.
//

import SwiftUI

struct AddGroup: View {
    @AppStorage("darkMode") var darkMode = false
    @State var name = ""
    let onComplete: (String) -> Void

    var body: some View {
      NavigationView {
        Form {
          Section(header: Text("")) {
            TextField("Folder name", text: $name)
          }
          Section {
            Button(action: formAction) {
              Text("Add New Folder")
            }
          }
        }
        .navigationBarTitle(Text("New Folder"))
        .preferredColorScheme(darkMode ? .dark : .light)
      }
    }

    private func formAction() {
      onComplete(name.isEmpty ? "Untitled Folder" : name)
    }
  }

struct AddGroup_Previews: PreviewProvider {
    static var previews: some View {
        AddGroup{ _ in }
    }
}
