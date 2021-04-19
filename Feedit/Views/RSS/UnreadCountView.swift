//
//  UnreadCountView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/27/21.
//

import SwiftUI

struct UnreadCountView: View, Equatable, Identifiable {
    static func == (lhs: UnreadCountView, rhs: UnreadCountView) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID()
    let count: Int
//    let count: String?
    
    var body: some View {
        Text(verbatim: String(count))
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 7)
            .padding(.vertical, 1)
            .background(Color.gray.opacity(0.5))
            .opacity(0.4)
            .foregroundColor(Color("text"))
            .cornerRadius(8)
    }
}

struct UnreadCountView_Previews: PreviewProvider {
    static var previews: some View {
        UnreadCountView(count: 123)
    }
}

struct UnreadPreferenceKey: PreferenceKey {
    static var defaultValue: UnreadCountView?

    static func reduce(value: inout UnreadCountView?, nextValue: () -> UnreadCountView?) {
        value = nextValue()
    }
}
