//
//  CardView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 12/3/20.
//

import SwiftUI

struct CardView: View {
    let width = 80 ..< 100
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 18)
                .frame(width: 100, height: 100)
            VStack(alignment: .leading) {
                ForEach(0 ..< 6) { item in
                    RoundedRectangle(cornerRadius: 18)
                        .frame(width: CGFloat(width.randomElement()!), height: 8)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color("bg"))
        .cornerRadius(18)
        .padding()
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView()
    }
}
