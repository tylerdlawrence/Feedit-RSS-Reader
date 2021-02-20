//
//  RFC3339DateFormatter.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/26/20.
//

import Foundation

/// Converts date and time textual representations within the RFC3339
/// date specification into `Date` objects
class RFC3339DateFormatter: DateFormatter {
    
    let dateFormats = [
        "MMM d, h:mm a"
        //"yyyy-MM-dd'T'HH:mm:ssZZZZZ",
        //"yyyy-MM-dd'T'HH:mm:ss.SSZZZZZ",
        //"yyyy-MM-dd'T'HH:mm:ss-SS:ZZ",
        //"yyyy-MM-dd'T'HH:mm:ss"
    ]
    
    override init() {
        super.init()
        self.timeZone = TimeZone(secondsFromGMT: 0)
        self.locale = Locale(identifier: "en_US_POSIX")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    override func date(from string: String) -> Date? {
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        for dateFormat in self.dateFormats {
            self.dateFormat = dateFormat
            if let date = super.date(from: string) {
                return date
            }
        }
        return nil
    }
    
}
