//
//  Notifier.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 1/18/21.
//

import Foundation
import UserNotifications

struct Notifier {
    static func notify(title: String, body: String, info: [AnyHashable: Any]? = nil) {
        Notifier.requestAuthorization { _ in
            let center = UNUserNotificationCenter.current()
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body

            if let info = info {
                content.userInfo = info
            }
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }

    }
    
    static func requestAuthorization(handler: @escaping (_ isAccepted: Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (isAccepted, error) in
            handler(isAccepted)
        }
    }
}
