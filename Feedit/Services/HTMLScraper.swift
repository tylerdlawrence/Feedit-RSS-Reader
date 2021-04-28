//
//  HTMLScraper.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 4/27/21.
//

import Foundation
import SwiftSoup
import CoreData
import Combine
import Reachability
import UIKit

// Phantom type placeholder for undefined methods
func undefined<T>(_ message:String="",file:String=#file,function:String=#function,line: Int=#line) -> T {
    fatalError("[File: \(file),Line: \(line),Function: \(function),]: Undefined: \(message)")
}

class Constants {
    
    class Endpoints {
        static let BASEURL = "https://"
    }
    
    static func create(uuid: UUID, title: String, desc: String, author: String, url: String, createTime: Date = Date(), image: String) -> RSSItem {
        let article = RSSItem(context: Persistence.current.context)
        article.title = title
        article.desc = desc
        article.author = author
        article.url = url
        article.createTime = createTime
        article.imageUrl = image
        
        return article
    }
    
}

class HTMLScraperUtility {
    
    func scrapArticle(from data:Data) -> Future<[RSSItem], Never> {
        Future { promise in
            let html = String(data: data, encoding: .utf8)!
            var articles = [RSSItem]()
            do {
                let elements = try SwiftSoup.parse(html, Constants.Endpoints.BASEURL)
                let documents = try elements.getElementById("stream-panel")?.select("div").select("ol").select("div").select("div").select("a")
                documents?.forEach({ (document) in
                    let imageUrl = try? document.select("div").select("figure").select("div").select("img").attr("src")
                    let title = try? document.select("h2").text()
                    let desc = try? document.select("p").text()
                    let author = try? document.select("div").select("p").select("span").text()
                    let url = try? document.attr("href")
                    
                    if let title = title,
                       let desc = desc,
                       let author = author,
                       let url = url,
                       let imageUrl = imageUrl,
                       !title.isEmpty,
                       !desc.isEmpty,
                       !author.isEmpty,
                       !url.isEmpty,
                       !imageUrl.isEmpty {

                        let article = RSSItem.create(uuid: UUID(), title: title, desc: desc, author: author, url: "https://\(url)", image: imageUrl, in: Persistence.current.context)
                        
                        articles.append(article)
                                                
                    }
                })
                promise(.success(articles))
            } catch let error {
                debugPrint(error)
                promise(.success([]))
                return
            }
        }
    }
}

class PlaceHolderData {
    
    static let articles = [
        RSSItem.create(
            uuid: UUID(),
            title: "How NASA Found the Ideal Hole on Mars to Land In",
            desc: "Jezero crater, the destination of the Perseverance rover, is a promising place to look for evidence of extinct Martian life.",
            author: "KENNETH CHANG",
            url: "https://www.nytimes.com/2020/07/28/science/nasa-jezero-perseverance.html",
            image: "https://static01.nyt.com/images/2020/07/28/science/28SCI-MARS-JEZERO1/28SCI-MARS-JEZERO1-jumbo.jpg",
            in: Persistence.previews.context
        ),
        RSSItem.create(
            uuid: UUID(),
            title: "Virgin Galactic Unveils Comfy Cabin for Jet-Setting to the Edge of Space",
            desc: "Passengers able to pay hundreds of thousands of dollars for a seat can escape gravity for a few minutes.",
            author: "KENNETH CHANG",
            url: "https://www.nytimes.com/2020/07/28/science/virgin-galactic-cabin.html",
            image: "https://static01.nyt.com/images/2020/07/28/science/28VIRGINGALACTIC2/28VIRGINGALACTIC2-videoLarge.jpg",
            in: Persistence.previews.context
        ),
        RSSItem.create(
            uuid: UUID(),
            title: "These Microbes May Have Survived 100 Million Years Beneath the Seafloor",
            desc: "Rescued from their cold, cramped and nutrient-poor homes, the bacteria awoke in the lab and grew.",
            author: "KATHERINE J. WU",
            url: "https://www.nytimes.com/2020/07/28/science/microbes-100-million-years-old.html",
            image: "https://static01.nyt.com/images/2020/07/28/science/28ANCIENT-MICROBES2/28ANCIENT-MICROBES2-videoLarge.jpg",
            in: Persistence.previews.context
        )
    ]
}


