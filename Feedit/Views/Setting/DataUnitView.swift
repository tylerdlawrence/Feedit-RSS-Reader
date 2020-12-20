//
//  DataUnitView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/15/20.
//

import SwiftUI
import WidgetKit

struct DataUnitView: View {
    
    enum ColorType {
        case blue
        case orange
        
        var gradient: Gradient {
            switch self {
            case .blue:
                return Gradient(colors: [Color(0x262628), Color(0x4c4d51)])
            case .orange:
                return Gradient(colors: [Color(0x262628), Color(0x4c4d51)])
                //(0xF1C300)
                //(0xF37102)
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
                        .foregroundColor(.white)
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
                        .foregroundColor(.white)
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


