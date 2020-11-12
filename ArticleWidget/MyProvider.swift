//
//  MyProvider.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/11/20.
//

import SwiftUI
import Foundation

class MyProvider {
    
    //this function will get one random string
    static func getRandomString() -> String {
        let strings = [
            
            "https://blog.github.com/feed/",
            "https://initialcharge.net/feed/",
            "https://talk.macpowerusers.com/t/550-the-world-of-rss/18897.rss",
            "https://macstories.net/feed/",
            "https://ia.net/feed/",
            "https://www.wsj.com/news/rss-news-and-feeds?mod=wsjfooter",
            "https://feed.podbean.com/HRpreneur/feed.xml",
            "https://wwdcbysundell.com/rss",
            "https://swiftwithmajid.com/feed.xml",
            "http://developer.apple.com/news/rss/news.rss",
//            "one",
//            "two",
//            "three",
//            "four",
//            "five",
//            "six",
//            "seven",
//            "eight",
//            "nine",
//            "ten",
        ]
        return strings.randomElement()!
    }
    
}
//getRandomString
//trimHTMLTag
//trimWhiteAndSpace
//toPermissiveDate
