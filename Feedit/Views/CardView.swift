//
//  CardView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 12/3/20.
//

import SwiftUI

struct CardView: View {
    let width = 5 ..< 30
    
    var body: some View {
        LazyHStack {
            Image(systemName: "text.justifyleft")
                .frame(width: 30, height: 30)
            Image(systemName: "circle.fill")
                .frame(width: 30, height: 30)
            Image(systemName: "bookmark.fill")
                .frame(width: 30, height: 30)
            Image(systemName: "chevron.up")
                .frame(width: 30, height: 30)
        }
        .frame(width: 170, height: 50, alignment: .center)
        //Spacer()
        //.padding()
        //.foregroundColor(Color("bg"))
        //.background(.clear) //(Color("accent"))
        .cornerRadius(7)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView()
        CardView()
            .preferredColorScheme(.dark)
    }
}
