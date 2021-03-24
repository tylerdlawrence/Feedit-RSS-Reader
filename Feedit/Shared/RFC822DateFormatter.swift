//
//  RFC822DateFormatter.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/26/20.
//

import Foundation

/// Converts date and time textual representations within the RFC822
/// date specification into `Date` objects
class RFC822DateFormatter: DateFormatter {
    
    let dateFormats = [
        "MMM d, h:mm a"
        //"EEE, d MMM yyyy HH:mm:ss zzz",
        //"EEE, d MMM yyyy HH:mm zzz",
        //"d MMM yyyy HH:mm:ss Z",
        //"yyyy-MM-dd HH:mm:ss Z"
    ]
    
    let backupFormats = [
        "MMM d, h:mm a"
        //"d MMM yyyy HH:mm:ss zzz",
        //"d MMM yyyy HH:mm zzz"
    ]

    override init() {
        super.init()
        self.timeZone = TimeZone(secondsFromGMT: 0)
        self.locale = Locale(identifier: "en_US_POSIX")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    private func attemptParsing(from string: String, formats: [String]) -> Date? {
        for dateFormat in formats {
            self.dateFormat = dateFormat
            if let date = super.date(from: string) {
                return date
            }
        }
        return nil
    }
    
    override func date(from string: String) -> Date? {
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if let parsedDate = attemptParsing(from: string, formats: dateFormats) {
            return parsedDate
        }
        // See if we can lop off a text weekday, as DateFormatter does not
        // handle these in full compliance with Unicode tr35-31. For example,
        // "Tues, 6 November 2007 12:00:00 GMT" is rejected because of the "Tues",
        // even though "Tues" is used as an example for EEE in tr35-31.
        let trimRegEx = try! NSRegularExpression(pattern: "^[a-zA-Z]+, ([\\w :+-]+)$")
        let trimmed = trimRegEx.stringByReplacingMatches(in: string, options: [],
            range: NSMakeRange(0, string.count), withTemplate: "$1")
        return attemptParsing(from: trimmed, formats: backupFormats)
    }
    
}

