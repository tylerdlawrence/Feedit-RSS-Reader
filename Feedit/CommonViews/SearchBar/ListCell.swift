//
//  ListCell.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/28/20.
//

import SwiftUI
import Foundation

struct ListCell: View {
    var text: String
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                HStack {
                    Text(text)
                        .padding(.leading, 15)
                        .foregroundColor(.white)
                    Spacer()
                }
            }
            Spacer()
        }.background(Color(#colorLiteral(red: 0.1058652624, green: 0.1019589826, blue: 0.1100945398, alpha: 1))).ignoresSafeArea()
    }
}

struct ListCell_Previews: PreviewProvider {
    static var previews: some View {
        ListCell(text: "RSS List Cell")
    }
}
