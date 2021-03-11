//
//  String+Ext.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation

extension String {
    var trimHTMLTag: String {
        return replacingOccurrences(of:"<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    var trimWhiteAndSpace: String {
        return replacingOccurrences(of: "\n", with: "")
    }
    
    func toPermissiveDate() -> Date? {
        return RFC822DateFormatter().date(from: self) ??
            (RFC3339DateFormatter().date(from: self) ??
            ISO8601DateFormatter().date(from: self))
    }
}

public extension Bool {
    /// SwifterSwift: Return 1 if true, or 0 if false.
    ///
    ///        false.int -> 0
    ///        true.int -> 1
    ///
    var int: Int {
        return self ? 1 : 0
    }

    /// SwifterSwift: Return "true" if true, or "false" if false.
    ///
    ///        false.string -> "false"
    ///        true.string -> "true"
    ///
    var string: String {
        return self ? "true" : "false"
    }
}
