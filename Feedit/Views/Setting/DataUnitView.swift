//
//  DataUnitView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/15/20.
//

import SwiftUI

struct DataUnitView: View {
    
    enum ColorType {
        case blue
        case orange
        
        var gradient: Gradient {
            switch self {
            case .blue:
                return Gradient(colors: [Color(hex: 0x13ABD6), Color(hex: 0x0036FF)])
            case .orange:
                return Gradient(colors: [Color(hex: 0xF1C300), Color(hex: 0xF37102)])
            }
        }
    }
    
    let label: String
    @Binding var content: Int
    let colorType: ColorType
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack {
                    Text(label)
                }
                Spacer()
            }
            .padding(.top, 12)
            Spacer()
            HStack {
                Spacer()
                VStack {
                    Text("items: \(content)")
                        .font(.footnote)
                }
            }
            .padding(.bottom, 12)
        }
        .padding(.leading, 12)
        .padding(.trailing, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: colorType.gradient,
                        startPoint: .leading,
                        endPoint: .trailing
                )
            )
        )
    }
}

struct DataUnitView_Previews: PreviewProvider {
    static var previews: some View {
        DataUnitView(label: "RSS", content: .constant(12), colorType: .blue)
            .frame(height: 120)
    }
}
