//
//  RSSActions.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 2/6/21.
//

import Foundation
import Combine
import FeedKit

func fetchNewRSS(url: URL,
                 completionHandler: @escaping ((Result<Feed, Error>) -> Void)) {
//func fetchNewRSS(url: URL, completionHandler: (([RSSItem]) -> Void)?) {
    let parser = FeedParser(URL: url)
    parser.parseAsync(queue: DispatchQueue.global()) { result in
        DispatchQueue.main.async {
            switch result {
            case .success(let feed):
                completionHandler(.success(feed))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}

func fetchNewRSS(model: RSS) -> AnyPublisher<RSS?, Error> {
    return Future<RSS?, Error> { promise in
        guard let urlStr = model.rssURL?.absoluteString, let url = URL(string: urlStr) else {
            promise(.failure(RSSError.invalidURL))
            return
        }
        let rss = model
        let parser = FeedParser(URL: url)
        parser.parseAsync(queue: DispatchQueue.global()) { [weak rss] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let feed):
                    rss?.update(from: feed)
                    promise(.success(rss))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
    .eraseToAnyPublisher()
}

func updateNewRSS(url: URL,
                  for rss: RSS,
                  completionHandler: @escaping ((Result<RSS, Error>) -> Void)) {
    rss.url = url.absoluteString
    let parser = FeedParser(URL: url)
    parser.parseAsync(queue: DispatchQueue.global()) { result in
        DispatchQueue.main.async {
            switch result {
            case .success(let feed):
                switch feed {
                case .atom(let atomFeed):
                    rss.title = atomFeed.title ?? ""
                    if let id = atomFeed.id, var url = URL(string: id), let icon = atomFeed.icon {
                        url.appendPathComponent(icon)
                        rss.image = url.absoluteString
                    }
                case .json(let jsonFeed):
                    rss.title = jsonFeed.title ?? ""
                    rss.desc = jsonFeed.description?.trimWhiteAndSpace ?? ""
                    rss.image = jsonFeed.icon ?? ""
                case .rss(let rssFeed):
                    rss.title = rssFeed.title ?? ""
                    rss.desc = rssFeed.description?.trimWhiteAndSpace ?? ""
                    rss.image = rssFeed.image?.url ?? ""
                }
                completionHandler(.success(rss))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}

fileprivate func appendNewRSSItem(items: [RSSItem], lastDate: Date?) -> [RSSItem] {
    let savingItems = items.filter { model -> Bool in
        guard let lastDate = lastDate, let date = model.createTime else {
            return true
        }
        return date > lastDate
    }
    print("new: \(savingItems.map({ $0.title }))")
    return savingItems
}

func syncNewRSSItem(model: RSS, url: URL?, start: Int = 0, in store: RSSItemStore,
                    completionHandler: @escaping ((Result<[RSSItem], Error>) -> Void)) {
    guard let url = url else {
        completionHandler(.failure(RSSError.invalidURL))
        return
    }
    let context = store.context
    let rss = model
    let parser = FeedParser(URL: url)
    parser.parseAsync(queue: DispatchQueue.global()) { result in
        DispatchQueue.main.async {
            var items = [RSSItem]()
            switch result {
            case .success(let feed):
                rss.update(from: feed)
                switch feed {
                case .atom(let atomFeed):
                    items = atomFeed.entries?.map({ $0.asRSSItem(container: rss.uuid!, in: context) }) ?? []
                case .json(let jsonFeed):
                    items = jsonFeed.items?.map({ $0.asRSSItem(container: rss.uuid!, in: context) }) ?? []
                case .rss(let rssFeed):
                    items = rssFeed.items?.map({ $0.asRSSItem(container: rss.uuid!, in: context) }) ?? []
                }
                items.sort(by: {
                    guard let a = $0.createTime, let b = $1.createTime else {
                        return true
                    }
                    return a > b
                })
                let savingItems = appendNewRSSItem(items: items, lastDate: rss.lastFetchTime)
                if let recentItem = items.first {
                    rss.lastFetchTime = recentItem.createTime
                    RSSStore().update(rss)
                }
                do {
                    try context.save()
                } catch let error {
                    print("error = \(error)")
                }
                completionHandler(.success(savingItems))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}


func fetchNewRSSItem(model: RSS, url: URL?, start: Int = 0, in store: RSSItemStore,
                     completionHandler: @escaping ((Result<[RSSItem], Error>) -> Void)) {
    var rs = [RSSItem]()
    do {
        rs = try store.fetchRSSItem(RSS: model, start: start, limit: 10)
        completionHandler(.success(rs))
    } catch let errror {
        print("error = \(errror)")
    }
}

