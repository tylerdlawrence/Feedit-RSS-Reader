//
//  AppearenceView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 10/8/20.
//

import SwiftUI

struct AppearenceView: View {
    @Binding var isToggled: Bool
    
    var body: some View {
        Section(header: Text("Appearance")) {
            VStack {
                HStack {
                    Image("AppIcon")
                    Text("test")
                }
                HStack(alignment: .center) {
                    Toggle("Automatic", isOn: $isToggled)
                }
            }
        }
    }
}

struct AppearenceView_Previews: PreviewProvider {
    static var previews: some View {
        AppearenceView(isToggled: .constant(true))
    }
}
