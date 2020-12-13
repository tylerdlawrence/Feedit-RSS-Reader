//
//  NavigationTitleView.swift
//  CustomNavigationTitle
//
//  Created by g01dt00th on 16.09.2020.
//  Copyright © 2020 Denis Roenko. All rights reserved.
//

import SwiftUI

struct NavigationTitleView: View {
    var title: [String]
    var colors: [Color]
    var font: Font
    var fontWeight: Font.Weight
    var spacing: CGFloat
    

    
    init(title: String, colors: [Color], font: Font, fontWeight: Font.Weight, spacing: CGFloat = 2) {
        if colors.count < title.count {
            let miss = title.count - colors.count
            var newColors = colors
            for _ in 1...miss {
                newColors.append(colors.randomElement() ?? Color.primary)
            }
            self.colors = newColors
            self.title = title.map{String($0)}
            self.font = font
            self.fontWeight = fontWeight
            self.spacing = spacing
        } else {
            self.colors = colors
            self.title = title.map{String($0)}
            self.font = font
            self.fontWeight = fontWeight
            self.spacing = spacing
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: self.spacing) {
//                Spacer(minLength: 20)
                ForEach(0..<self.title.count, id: \.self) { index in
                    Text(self.title[index])
                        .foregroundColor(self.colors[index])
                        .font(self.font)
                        .fontWeight(self.fontWeight)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
            
            Text("Today at 10:53 AM")
            Divider()
        }
        .padding(.leading)
    }
}

struct NavigationTitleView_Previews: PreviewProvider {
    static var title = "Hello"
    static var colors: [Color] = [.gray]
    
    static var previews: some View {
        NavigationTitleView(title: title, colors: colors, font: .largeTitle, fontWeight: .bold)
    }
}
