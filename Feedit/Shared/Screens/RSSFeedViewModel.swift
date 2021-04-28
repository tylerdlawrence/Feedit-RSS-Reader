//
//  RSSFeedViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation
import CoreData
import SwiftUI
import Combine
import UIKit
import FeedKit
import FaviconFinder
import URLImage
import BackgroundTasks
import WidgetKit
import Alamofire
import SwiftyJSON

public extension UIView {
    func getImage(from imageUrl: String, to imageView: UIImageView) {
        guard let url = URL(string: imageUrl ) else { return }
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else { return }
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data)
            }
        }
    }
}

extension RSSFeedViewModel: Identifiable {

}

class RSSFeedViewModel: NSObject, ObservableObject {
    typealias Element = RSSItem
    typealias Context = RSSItem
    typealias Model = Post
    private(set) lazy var rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    
    @Published var isOn = false
    @Published var unreadIsOn = false
    @Published var items = [RSSItem]()
    @Published var filteredArticles: [RSSItem] = []
    @Published var selectedPost: RSSItem?
    @Published var shouldReload = false
    @ObservedObject var store = RSSStore.instance
    @Published var filteredPosts: [RSSItem] = []
    @Published var filterType = FilterType.unreadIsOn
    @Published var showingDetail = false
    @Published var showFilter = false
    @Published var rss: RSS
    @Published var rssItem = RSSItem()
    
    
    private var cancellable: AnyCancellable? = nil
    private var cancellable2: AnyCancellable? = nil
    
    let dataSource: RSSItemDataSource
    
    var start = 0
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    init(rss: RSS, dataSource: RSSItemDataSource) {
        self.dataSource = dataSource
        self.rss = rss
        super.init()
        
        self.filteredPosts = rss.posts.filter { self.filterType == .unreadIsOn ? !$0.isRead : true }
        cancellable = Publishers.CombineLatest3(self.$rss, self.$filterType, self.$shouldReload)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (newValue) in
                self.filteredPosts = newValue.0.posts.filter { newValue.1 == .unreadIsOn ? !$0.isRead : true }
        })
    }

    func archiveOrCancel(_ item: RSSItem) {
        let updatedItem = dataSource.readObject(item)
        updatedItem.isArchive = !item.isArchive
        updatedItem.updateTime = Date()
        dataSource.setUpdateObject(updatedItem)

        _ = dataSource.saveUpdateObject()
    }
    
    func unreadOrCancel(_ item: RSSItem) {
        let updatedItem = dataSource.readObject(item)
        updatedItem.isRead = !item.isRead
        updatedItem.updateTime = Date()
        dataSource.setUpdateObject(updatedItem)

        _ = dataSource.saveUpdateObject()
    }

    func loadMore() {
        start = items.count
        fecthResults(start: start)
    }

    func fecthResults(start: Int = 0) {
        if start == 0 {
            items.removeAll()
        }
        dataSource.performFetch(RSSItem.requestObjects(rssUUID: rss.uuid!, start: start))
        if let objects = dataSource.fetchedResult.fetchedObjects {
            items.append(contentsOf: objects)
        }
    }
    
    func markAllPostsRead() {
        self.store.markAllPostsRead(feed: self.rss)
        shouldReload = true
    }
    
    func markPostRead(index: Int) {
        self.store.setPostRead(post: self.filteredArticles[index], feed: self.rss)
        shouldReload = true
    }
    
    func reloadPosts() {
        store.reloadFeedPosts(feed: rss)
    }
    
    func selectPost(index: Int) {
        self.selectedPost = self.filteredArticles[index]
        self.showingDetail.toggle()
        self.markPostRead(index: index)
    }

    func fetchRemoteRSSItems() {
        guard let url = URL(string: rss.url) else {
            return
        }
        guard let uuid = self.rss.uuid else {
            return
        }
        fetchNewRSS(url: url) { result in
            switch result {
            case .success(let feed):
                var items = [RSSItem]()
                switch feed {
                    case .atom(let atomFeed):
                        for item in atomFeed.entries ?? [] {
                            if let fetchDate = self.rss.lastFetchTime, let pubDate = item.updated, pubDate < fetchDate {
                                continue
                            }
                            guard let title = item.title, items.filter({ $0.title == title }).count <= 0 else {
                                continue
                            }
                            items.append(item.asRSSItem(container: uuid, in: self.dataSource.createContext))
                        }
                        
                    case .json(let jsonFeed):
                        for item in jsonFeed.items ?? [] {
                            if let fetchDate = self.rss.lastFetchTime, let pubDate = item.datePublished, pubDate < fetchDate {
                                continue
                            }
                            guard let title = item.title, items.filter({ $0.title == title }).count <= 0 else {
                                continue
                            }
                            items.append(item.asRSSItem(container: uuid, in: self.dataSource.createContext))
                        }
                        
                    case .rss(let rssFeed):
                        for item in rssFeed.items ?? [] {
                            if let fetchDate = self.rss.lastFetchTime, let pubDate = item.pubDate, pubDate < fetchDate {
                                continue
                            }
                            guard let title = item.title, items.filter({ $0.title == title }).count <= 0 else {
                                continue
                            }
                            items.append(item.asRSSItem(container: uuid, in: self.dataSource.createContext))
                        }
                    }
                    self.rss.lastFetchTime = Date()
                    self.dataSource.saveCreateContext()

                    self.fecthResults()

                case .failure(let error):
                    print("feed error \(error)")
            }
        }
    }
}

class FeedObject: Codable, Identifiable, ObservableObject {
    var id = UUID()
    var name: String
    var url: URL
    var posts: [Post] {
        didSet {
            objectWillChange.send()
        }
    }
    
    var imageURL: URL?
    
    var lastUpdateDate: Date
    
    init?(feed: Feed, url: URL) {
        self.url = url
        lastUpdateDate = Date()
        
        switch feed {
        case .rss(let rssFeed):
            self.name =  rssFeed.title ?? ""
            
            let items = rssFeed.items ?? []
            self.posts = items
                .compactMap { Post(feedItem: $0) }
                .sorted(by: { (lhs, rhs) -> Bool in
                    return Calendar.current.compare(lhs.date, to: rhs.date, toGranularity: .minute) == ComparisonResult.orderedDescending
                })
            
            if let urlStr = rssFeed.image?.url, let url = URL(string: urlStr) {
                self.imageURL = url
            } else {
                FaviconFinder(url: URL(string: rssFeed.link ?? "")!).downloadFavicon { (_) in
                    self.imageURL = url
                }
            }
            
        case .atom(let atomFeed):
            self.name =  atomFeed.title ?? ""
            
            let items = atomFeed.entries ?? []
            self.posts = items
                .compactMap { Post(atomFeed: $0) }
                .sorted(by: { (lhs, rhs) -> Bool in
                    return Calendar.current.compare(lhs.date, to: rhs.date,     toGranularity: .minute) ==  ComparisonResult.orderedDescending
                })
            
            if let urlStr = atomFeed.logo, let url = URL(string: urlStr) {
                self.imageURL = url
            } else {
                FaviconFinder(url: URL(string: atomFeed.links?.first?.attributes?.href ?? "")!).downloadFavicon { (_) in
                    self.imageURL = url
                }
            }
        default:
            return nil
        }
        
    }
    
    init(name: String, url: URL, posts: [Post]) {
        self.name = name
        self.url = url
        self.posts = posts
        lastUpdateDate = Date()
    }
    
    static var testObject: FeedObject {
        return FeedObject(name: "Test feed",
        url: URL(string: "https://www.google.com")!,
        posts: [Post.testObject])
    }
}

class Post: Codable, Identifiable, ObservableObject {
    var id = UUID()
    var title: String
    var description: String
    var url: URL
    var date: Date

    var isRead: Bool
    {
        return readDate != nil
    }

    var readDate: Date? {
        didSet {
            objectWillChange.send()
        }
    }

    var lastUpdateDate: Date

    init?(feedItem: RSSFeedItem) {
        self.title =  feedItem.title ?? ""
        self.description = feedItem.description ?? ""

        if let link = feedItem.link, let url = URL(string: link) {
            self.url = url
        } else {
            return nil
        }
        self.date = feedItem.pubDate ?? Date()
        lastUpdateDate = Date()
    }

    init?(atomFeed: AtomFeedEntry) {
        self.title =  atomFeed.title ?? ""
        let description = atomFeed.content?.value ?? ""

        let attributed = try? NSAttributedString(data: description.data(using: .unicode)!, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        self.description = attributed?.string ?? ""

        if let link = atomFeed.links?.first?.attributes?.href, let url = URL(string: link) {
            self.url = url
        } else {
            return nil
        }
        self.date = atomFeed.updated ?? Date()
        lastUpdateDate = Date()
    }

    init(title: String, description: String, url: URL) {
        self.title = title
        self.description = description
        self.url = url
        self.date = Date()
        lastUpdateDate = Date()
    }

    static var testObject: Post {
        return Post(title: "This Is A Test Post Title",
        description: "This is a test post description",
        url: URL(string: "https://www.google.com")!)
    }
}


struct XMLElement {
    var value:String
    var attributes:[String:String]
}

typealias XMLDictionary = [String:Any]

class XMLHelper:NSObject {
    func parseXML(atURL url:URL,
                  completion:@escaping (XMLDictionary?) -> Void) {
        guard let data = try? Data(contentsOf: url) else {
            completion(nil)
            return
        }
        parseXML(data: data, completion: completion)
    }
    
    func parseXML(atURL url:URL,
                  elementName:String,
                  completion:@escaping (Array<XMLDictionary>?) -> Void) {
        guard let data = try? Data(contentsOf: url) else {
            completion(nil)
            return
        }
       parseXML(data: data, elementName: elementName, completion: completion)
    }
    
    func parseXML(data:Data,
                  completion:@escaping (XMLDictionary?) -> Void) {
        let parser = XMLParser(data: data)
        self.completion = completion
        let helperParser = ParserAllTags(completion: completion)
        parser.delegate = helperParser
        parser.parse()
    }
    
    func parseXML(data:Data,
                  elementName:String,
                  completion:@escaping(Array<XMLDictionary>?) -> Void) {
        let parser = XMLParser(data: data)
        self.completionArray = completion
        //let helperParser = ParserSpecificElement(elementName: elementName, completion:completion)
        let helperParser = ParserAllTags(elementName:elementName, completion: completion)
        parser.delegate = helperParser
        parser.parse()
    }
    
    @available(iOS 13.0, *)
    func parseXML(atURL url:URL) -> AnyPublisher<XMLDictionary?, Never> {
        let subject = CurrentValueSubject<XMLDictionary?, Never>(nil)
        parseXML(atURL: url) { dictionary in
            subject.send(dictionary)
        }
        return subject.eraseToAnyPublisher()
    }
    
    @available(iOS 13.0, *)
    func parseXML(data: Data) -> AnyPublisher<XMLDictionary?, Never> {
        let subject = CurrentValueSubject<XMLDictionary?, Never>(nil)
        parseXML(data:data) { dictionary in
            subject.send(dictionary)
        }
        return subject.eraseToAnyPublisher()
    }
    
    @available(iOS 13.0, *)
    func parseXML(atURL url:URL, elementName:String) -> AnyPublisher<Array<XMLDictionary>?, Never> {
        let subject = CurrentValueSubject<Array<XMLDictionary>?, Never>(nil)
        parseXML(atURL: url, elementName: elementName) { arrayDictionary in
            subject.send(arrayDictionary)
        }
        return subject.eraseToAnyPublisher()
    }
    
    @available(iOS 13.0, *)
    func parseXML(data:Data, elementName:String) -> AnyPublisher<Array<XMLDictionary>?, Never> {
        let subject = CurrentValueSubject<Array<XMLDictionary>?, Never>(nil)
        parseXML(data:data, elementName: elementName) { arrayDictionary in
            subject.send(arrayDictionary)
        }
        return subject.eraseToAnyPublisher()
    }
    
    // MARK: - Private
    
    private var completionArray:((Array<XMLDictionary>?) -> Void)?
    private var completion:((XMLDictionary?) -> Void)?
}

// MARK: - ParserSpecificElement

fileprivate class ParserSpecificElement:NSObject, XMLParserDelegate {
    init(elementName:String, completion:@escaping (Array<XMLDictionary>?) -> Void) {
        self.elementNameToGet = elementName
        self.completion = completion
    }
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        currentElementName = nil
        if elementName == elementNameToGet {
            newDictionary()
        }
        else if currentDictionary != nil {
            currentElementName = elementName
        }
        if let currentElementName = currentElementName {
            addAttributes(attributeDict, forKey:currentElementName)
        }
    }
    
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        if elementName == elementNameToGet {
            addCurrentDictionaryToResults()
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if let key = currentElementName {
            addString(string, forKey: key)
        }
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        if let _ = elementNameToGet {
            completion(results)
        }
    }

    // MARK: - Private
    
    private var completion:(Array<XMLDictionary>?) -> Void
    private var currentDictionary:XMLDictionary?
    private var currentElementName:String?
    private var elementNameToGet:String?
    private var results:[XMLDictionary] = []
    
    private func addAttributes(_ attributes:[String:String], forKey key:String) {
        currentDictionary?[key] = XMLElement(value: "", attributes: attributes)
    }
    
    private func addCurrentDictionaryToResults() {
        if let currentDictionary = currentDictionary {
            results.append(currentDictionary)
        }
        currentDictionary = nil
    }
    
    private func addString(_ string:String, forKey key:String) {
        if let currentValue = currentDictionary?[key] as? XMLElement {
            let valueString = currentValue.value + string
            currentDictionary?[key] = XMLElement(value: valueString, attributes: currentValue.attributes)
        }
        else {
            currentDictionary?[key] = XMLElement(value: string, attributes: [:])
        }
    }
    
    private func newDictionary() {
        currentDictionary = [:]
    }
}




// MARK: - ParserAllTags

fileprivate class ParserAllTags:NSObject, XMLParserDelegate {
    
    init(elementName:String, completion:@escaping(Array<XMLDictionary>?) -> Void) {
        self.arrayCompletion = completion
        elementNameToGet = elementName
    }
    
    init(completion:@escaping (XMLDictionary?) -> Void) {
        self.completion = completion
    }
    
    private var arrayCompletion:((Array<XMLDictionary>?) -> Void)? // used in case of specific element
    private var completion:((XMLDictionary?) -> Void)? // used when parsing all tags
    private var currentDictionary:XMLDictionary = [:]
    private var currentElementName:String = ""
    private var elementNameToGet:String?
    private var results:[XMLDictionary] = [] // used in case of specific element
    private var rootDictionary:XMLDictionary = [:]
    private var stack:[XMLDictionary] = []
    
    private func addAttributes(_ attributes:[String:String], forKey key:String) {
        currentDictionary[key] = XMLElement(value: "", attributes: attributes)
    }
    
    private func addCurrentDictionaryToResults() {
        results.append(currentDictionary)
        currentDictionary = [:]
    }
    
    /// Add a dictionary to an existing one
    /// If the key is already in the dictionary we need to create an array
    /// - Parameters:
    ///   - dictionary: the dictionary to add
    ///   - toDictionary: the dictionary where the given dictionary will be added
    ///   - key: the key
    /// - Returns: the dictionary passed as toDictionary with the new value added
    private func addDictionary(_ dictionary:XMLDictionary, toDictionary:XMLDictionary,
                                      key:String) -> XMLDictionary {
        var returnDictionary = toDictionary
        if let array = returnDictionary[key] as? Array<XMLDictionary> {
            var newArray = array
            newArray.append(dictionary)
            returnDictionary[key] = newArray
        }
        else if let dictionary = returnDictionary[key] as? XMLDictionary {
            var array:[XMLDictionary] = [dictionary]
            array.append(dictionary)
            returnDictionary[key] = array
        }
        else {
            returnDictionary[key] = dictionary
        }
        return returnDictionary
    }
    
    private func addString(_ string:String, forKey key:String) {
        if let currentValue = currentDictionary[key] as? XMLElement {
            let valueString = currentValue.value + string
            currentDictionary[key] = XMLElement(value: valueString, attributes: currentValue.attributes)
        }
        else {
            currentDictionary[key] = XMLElement(value: string, attributes: [:])
        }
    }
    
    private func newDictionary() {
        currentDictionary = [:]
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        if let elementNameToGet = elementNameToGet {
            currentElementName = ""
            if elementName == elementNameToGet {
                newDictionary()
            }
            else {
                currentElementName = elementName
            }
            if currentElementName != "" {
                addAttributes(attributeDict, forKey:currentElementName)
            }
        }
        else {
            stack.append(currentDictionary)
            currentDictionary = [:]
            currentElementName = elementName
        }
    }
    
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        if let elementNameToGet = elementNameToGet {
            if elementName == elementNameToGet {
                addCurrentDictionaryToResults()
            }
        }
        else {
            var parentDictionary = stack.removeLast()
            parentDictionary = addDictionary(currentDictionary, toDictionary: parentDictionary, key: elementName)
            currentDictionary = parentDictionary
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if string.starts(with: "\n") {
            return
        }
        if let _ = elementNameToGet {
            if currentElementName != "" {
                addString(string, forKey: currentElementName)
            }
            return
        }
        if let currentValue = currentDictionary[currentElementName] as? XMLElement {
            let valueString = currentValue.value + string
            currentDictionary[currentElementName] = XMLElement(value: valueString, attributes: currentValue.attributes)
        }
        else {
            currentDictionary[currentElementName] = XMLElement(value: string, attributes: [:])
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        if let arrayCompletion = arrayCompletion {
            arrayCompletion(results)
        }
        else if let completion = completion {
            completion(currentDictionary)
        }
    }
}

