//
//  DateSpec.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/26/20.
//

import Foundation

/// Date specifications
///
/// - rfc822: The `Standard for the format of arpa internet text messages`.
/// See https://www.ietf.org/rfc/rfc0822.txt
/// - rfc3999: The `Date and Time on the Internet: Timestamps`.
/// See https://www.ietf.org/rfc/rfc3339.txt
/// - iso8601: The `W3CDTF` date time format specification
/// See http://www.w3.org/TR/NOTE-datetime
enum DateSpec {
    case rfc822
    case rfc3999
    case iso8601
}

