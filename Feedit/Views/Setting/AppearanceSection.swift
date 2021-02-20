//
//  AppearacneSection.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI

struct AppearanceSection: View {

    @Binding var isToggled: Bool
    @Binding var isSelected: Bool
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 60) {
                VStack {
                    Image("default_image")
                    Text("Light")
                    Image(systemName: "checkmark.circle\(!isSelected ? "" : ".fill")")
                }
                .onTapGesture {
                    self.isSelected = false
                }
                VStack {
                    Image("default_image")
                    Text("Dark")
                    Image(systemName: "checkmark.circle\(isSelected ? "" : ".fill")")
                }
                .onTapGesture {
                    self.isSelected = true
                }
            }
            .padding(.top, 16)
            HStack(alignment: .center) {
                Toggle("Automatic", isOn: $isToggled)
            }
        }
    }
}

struct AppearacneSection_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSection(isToggled: .constant(true), isSelected: .constant(true))
    }
}
