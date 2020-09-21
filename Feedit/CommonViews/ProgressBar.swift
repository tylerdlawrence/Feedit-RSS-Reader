//
//  RSProgressView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI

struct ProgressBar: View {
    
    var boardWidth: CGFloat = 20
    var font: Font = Font.system(size: 18)
    var color: Color = .blue
    var content: Bool = true
    
    @Binding var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: boardWidth)
                .opacity(0.3)
                .foregroundColor(color)
            Circle()
                .trim(from: 0, to: CGFloat(min(1.0, self.progress)))
                .stroke(style: StrokeStyle(lineWidth: boardWidth, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: 270.0))
                .foregroundColor(color)
            if content {
                Text(String(format: "%.1lf", min(self.progress, 1.0)))
                    .font(font)
                    .bold()
            }
        }
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            VStack {
                ProgressBar(font: Font.system(size: 20), color: .blue, content: false, progress: .constant(0.5))
                    .frame(width: 100, height: 100)
                    .padding(40.0)
                
                Spacer()
            }
        }
    }
}
