//
//  AppEnvironment.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import UIKit
import SwiftUI
import CoreData
import Foundation
import MessageUI
import CoreMotion

class UserEnvironment: NSObject, ObservableObject {
    
    static let prefix = "com.tylerdlawrence.feedit.app.environment"
    
    static let current = UserEnvironment()
    
    @UserDefault(key: "\(prefix).light", default: false)
    var lightMode: Bool

    @UserDefault(key: "\(prefix).dark", default: true)
    var darkMode: Bool
    
    @UserDefault(key: "\(prefix).useSafari", default: true)
    var useSafari: Bool
}

enum Vibration {
    case error
    case success
    case light
    case selection
    
    func vibrat(){
        switch self {
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
}

class MotionManager: ObservableObject {
    let motionManager = CMMotionManager()
    
    @Published var x: CGFloat = 0
    @Published var y: CGFloat = 0
    @Published var z: CGFloat = 0
    
    init() {
        motionManager.startDeviceMotionUpdates(to: .main){ data, _ in
            guard let tilt = data?.gravity else { return }
            
            self.x = CGFloat(tilt.x)
            self.y = CGFloat(tilt.y)
            self.z = CGFloat(tilt.z)
        }
    }
}

struct DarkmModeSettingView: View {
    
    @Binding var darkMode: Bool
    
    var body: some View {
        Button(action:{
            Vibration.selection.vibrat()
            darkMode.toggle()
        }){
            Image(systemName: darkMode ? "sun.max.fill" : "moon.fill")
                .imageScale(.medium)
                .foregroundColor(Color("tab"))
                .font(.system(size: 20, weight: .regular, design: .default))
        }
    }
}
