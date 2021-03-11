//
//  RoundRectangleButton.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/15/20.
//

import SwiftUI

struct RoundRectangeButton: View {
    
    enum Status {
        case normal(String)
        case ok(String)
        case error(String)
        
        var backgroundColor: Color {
            switch self {
            case .normal:
                return .blue
            case .ok:
                return .green
            case .error:
                return .red
            }
        }
    }
    
    @Binding var status: Status
    let action: ((Status) -> Void)
    
    var text: String {
        switch status {
        case .normal(let msg):
            return msg
        case .ok(let msg):
            return msg
        case .error(let msg):
            return msg
        }
    }
    
    var body: some View {
        Button(action: {
            self.action(self.status)
        }) {
            Text(text)
                .foregroundColor(.white)
        }
        .frame(width: UIScreen.main.bounds.width - 40, height: 48)
        .background(status.backgroundColor)
        .cornerRadius(12)
    }
}

struct RoundRectangeButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundRectangeButton(status: .constant(.ok("Import"))) { _ in
            
        }
    }
}

struct RefreshFeedButton: View {
    
    var title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .frame(width: 280, height: 50)
            .background(Color("tab"))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct RefreshFeedButton_Previews: PreviewProvider {
    static var previews: some View {
        RefreshFeedButton(title: "Refresh")
    }
}
