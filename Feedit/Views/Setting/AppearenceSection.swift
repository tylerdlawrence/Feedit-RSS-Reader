//
//  AppearenceSection.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 10/8/20.
//

import SwiftUI

struct AppearenceSection: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
            return HStack {
                configuration.label
                Spacer()
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .onTapGesture { configuration.isOn.toggle() }
            }
        }

    @Binding var isToggled: Bool
    @Binding var isSelected: Bool
        
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 60) {
                VStack {
                    Image("AppIconBot")
                    Text("Light")
                    Image(systemName: "checkmark.circle\(!isSelected ? "": ".fill")")
                }
                .onTapGesture {
                    self.isSelected = false
                }
                VStack {
                    Image("AppIcon")
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

//struct AppearenceSection_Previews: PreviewProvider {
//    //typealias Previews = ToggleStyle
//
//        var previews: some ToggleStyle {
//            AppearenceSection(isToggled: .constant(true), isSelected: .constant(true))
//        }
//    }
