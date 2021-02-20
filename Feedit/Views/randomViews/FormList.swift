//
//  FormList.swift
//  Outlines&Disclosures
//
//  Created by Alfian Losari on 19/07/20.
//

import SwiftUI

struct FormList: View {
    
    @State var isProfileExpanded = true
    var body: some View {
        Form {
            Section {
                DisclosureGroup(isExpanded: $isProfileExpanded) {
                    TextField("First Name", text: .constant(""))
                    TextField("Last Name", text: .constant(""))
                    TextField("Email", text: .constant(""))
                    DatePicker("Birthday", selection: .constant(Date()))
                } label: {
                    Text("Profile")
                        .font(.headline)
                }
            }
            
            Section {
                DisclosureGroup {
                    TextField("Address", text: .constant(""))
                    TextField("City", text: .constant(""))
                    TextField("State", text: .constant(""))
                    TextField("Country", text: .constant(""))
                    TextField("Mobile Phone", text: .constant(""))
                } label: {
                    Text("Contact Information")
                        .font(.headline)
                }
            }
            
            Section {
                DisclosureGroup {
                    Toggle("Push", isOn: .constant(true))
                    Toggle("Email", isOn: .constant(true))
                    Toggle("SMS", isOn: .constant(false))
                } label: {
                    Text("Preferences")
                        .font(.headline)
                }
            }
        }
    }
}

struct FormList_Previews: PreviewProvider {
    static var previews: some View {
        FormList()
    }
}
