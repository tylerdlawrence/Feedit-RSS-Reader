//
//  Date+Ext.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation

extension Date {
    func string(format: String = "MMM d, h:mm a") -> String {
        let f = DateFormatter()
        f.dateFormat = format
        return f.string(from: self)
    }
}

extension Date {
    func dateToString() -> String{
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strdt = dateFormatter.string(from: self as Date)
        if let dtDate = dateFormatter.date(from: strdt){
            return dateFormatter.string(from: dtDate)
        }
        return "--"
    }
}

