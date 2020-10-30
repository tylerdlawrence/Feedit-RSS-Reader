//
//  SettingRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI

struct SettingRow: View {
    
    @Binding var isToggled: Bool
    
    var body: some View {
        Section(header: Text("APPEARANCE")) {
            VStack {
                HStack {
                    Image("default_image")
                    Text("test")
                }
                HStack(alignment: .center) {
                    Toggle("Automatic", isOn: $isToggled)
                }
            }
        }
    }
}

struct SettingRow_Previews: PreviewProvider {
    static var previews: some View {
        SettingRow(isToggled: .constant(true))
    }
}
