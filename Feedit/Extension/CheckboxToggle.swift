//
//  CheckboxToggle.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 2/3/21.
//

import SwiftUI

struct CheckboxStyle: ToggleStyle {
    @State private var disabled = false
    func makeBody(configuration: Self.Configuration) -> some View {
        return HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle")
                .imageScale(.medium)
                .foregroundColor(Color("tab"))
                .font(.system(size: 20, weight: .regular, design: .default))
                .onTapGesture {
                    configuration.isOn.toggle()
            }
                .disabled(self.disabled)
        }
    }
}

struct StarStyle: ToggleStyle {
    @State private var disabled = false
    func makeBody(configuration: Self.Configuration) -> some View {
        return HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "star.fill" : "star")
                .imageScale(.medium)
                .foregroundColor(Color("tab"))
                .font(.system(size: 18, weight: .regular, design: .default))
                .onTapGesture {
                    configuration.isOn.toggle()
            }
                .disabled(self.disabled)
        }
    }
}
