//
//  RSS+CoreDataProperties.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import Foundation
import CoreData
import FeedKit
import FaviconFinder
import Combine
import BackgroundTasks


extension RSS {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RSS> {
          
        return NSFetchRequest<RSS>(entityName: "RSS")
    }

    @NSManaged public var author: String?
    @NSManaged public var urlString: String?
    @NSManaged public var imageURL: String
    @NSManaged public var url: String
    @NSManaged public var title: String
    @NSManaged public var desc: String
    @NSManaged public var createTime: Date?
    @NSManaged public var updateTime: Date?
    @NSManaged public var lastFetchTime: Date?
    @NSManaged public var uuid: UUID?
    @NSManaged public var image: String
    @NSManaged public var isFetched: Bool
    @NSManaged public var name: String
    @NSManaged public var isFavorite: Bool
    @NSManaged public var selected: Bool
    @NSManaged public var isSwiped: Bool
    @NSManaged public var isRead: Bool
    @NSManaged public var feedItems: NSSet
    @NSManaged public var drag : CGFloat
    @NSManaged public var degree : Double
//    @NSManaged public var setPostRead : String
    @NSManaged public var readDate : Date?

    
    //sorted 'feedItems' by publish date
    func sortedItems() -> [RSSItem] {
        guard let unsortedItems: [RSSItem] = feedItems.allObjects as? [RSSItem] else {
            return []
        }
        
        let sortedArray = unsortedItems.sorted(by: { (item1: RSSItem, item2: RSSItem) -> Bool in
            return item1.createTime?.string() ?? "" > item2.createTime?.string() ?? ""
        })
        
        return sortedArray
    }
    func setPostRead(rss: RSS, feed: RSS) {
        rss.readDate = Date()
        rss.objectWillChange.send()
//        totalUnreadPosts -= 1
//        totalReadPostsToday += 1
//        if let index = feed.posts.firstIndex(where: {$0.url.absoluteString == post.url.absoluteString}) {
//            feed.posts.remove(at: index)
//            feed.posts.insert(post, at: index)
//        }
//
//        if let index = self.feeds.firstIndex(where: {$0.url.absoluteString == feed.url.absoluteString}) {
//            self.feeds.remove(at: index)
//            self.feeds.insert(feed, at: index)
//        }
        
        self.updateFeeds()
    }
    
    func updateFeeds() {
        
    }
    //unread 'feedItems'
    func unreadItems() -> [RSSItem] {
        guard let items: [RSSItem] = feedItems.allObjects as? [RSSItem] else {
            return []
        }

        let unReadItem = items.filter({ (item: RSSItem) -> Bool in
            return item.wasRead.boolValue == false
        })
        //Text("\(feed.posts.filter { !$0.isRead }.count) unread posts")

        return unReadItem
    }
    
    
    


    
    public var rssURL: URL? {
        return URL(string: url)
    }
    
    public var createTimeStr: String {
        return "\(self.createTime?.string() ?? "")"
    }
    
    static func create(url: String = "", title: String = "", desc: String = "", imageURL: String = "", in context: NSManagedObjectContext) -> RSS {
        let rss = RSS(context: context)
        rss.title = title
        rss.desc = desc
        rss.url = url
        rss.imageURL = imageURL
        rss.uuid = UUID()
        rss.createTime = Date()
        rss.updateTime = Date()
        rss.isFetched = false
        return rss
    }
    
//    static func simple(image: String = "") -> RSS {
//    static func simple() -> RSS {
//        let rss = RSS(context: Persistence.current.context)
//        rss.title = "Apple Newsroom"
//        rss.imageURL = "https://i.insider.com/526e70dbecad040247237811?width=600&format=jpeg&auto=webp"
//        rss.desc = "Apple Newsroom"
//        rss.url = "http://images.apple.com/main/rss/hotnews/hotnews.rss"
//        return rss
//    }
//    func updateFeeds() {
//        UserDefaults = self.feedItems
//    }
    static func requestObjects() -> NSFetchRequest<RSS> {
        let request = RSS.fetchRequest() as NSFetchRequest<RSS>
        request.predicate = .init(value: true)
        request.sortDescriptors = [.init(key: #keyPath(RSS.title), ascending: true)]
        return request
    }
    
    static func requestDefaultObjects() -> NSFetchRequest<RSS> {
        let request = RSS.fetchRequest() as NSFetchRequest<RSS>
        return request
    }
}

extension RSS {
    static func == (lhs: RSS, rhs: RSS) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

extension RSS {
    func update(from feed: Feed) {
        let rss = self
        switch feed {
        case .atom(let atomFeed):
            rss.title = atomFeed.title ?? ""
        case .json(let jsonFeed):
            rss.title = jsonFeed.title ?? ""
            rss.desc = jsonFeed.description?.trimWhiteAndSpace ?? ""
        case .rss(let rssFeed):
            rss.title = rssFeed.title ?? ""
            rss.desc = rssFeed.description?.trimWhiteAndSpace ?? ""
        }
    }
}

extension RSS: ObjectValidatable {
    func hasChangedValues() -> Bool {
        return hasPersistentChangedValues
    }
}

//var reporter = PassthroughSubject<String, Never>()

struct swipeView: UIViewRepresentable {
  @State var direction = ""

  typealias UIViewType = UIView
  var v = UIView()

  func updateUIView(_ uiView: UIView, context: Context) {
    v.backgroundColor = UIColor(Color("accent"))
  }
  
  func makeUIView(context: Context) -> UIView {
    let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(sender:)))
//    let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(sender:)))
    let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(sender:)))
    let leftSwipe = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSwipe(sender:)))
    leftSwipe.direction = .left
    let rightSwipe = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSwipe(sender:)))
    rightSwipe.direction = .right
    
    
//    v.addGestureRecognizer(panGesture)
    v.addGestureRecognizer(pinchGesture)
    v.addGestureRecognizer(tapGesture)
    v.addGestureRecognizer(leftSwipe)
    v.addGestureRecognizer(rightSwipe)
    return v
    }
    
  func makeCoordinator() -> swipeView.Coordinator {
    Coordinator(v)
  }
    
    
  
  final class Coordinator: NSObject {
    private let view: UIView
  
    init(_ view: UIView) {
        self.view = view
        super.init()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handlePinch(sender: UIPinchGestureRecognizer) {
      let scale = sender.scale
      reporter.send("scale \(scale)")
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
      let location = sender.location(in: view)
      reporter.send("tap \(location)")
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {

      let translation = sender.translation(in: view)
      let location = sender.location(in: view)
      
      sender.setTranslation(.zero, in: view)
      reporter.send("pan \(location) \(translation)")
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
      if sender.direction == .left {
        let location = sender.location(in: view)
        reporter.send("left \(location)")
      } else {
        if sender.direction == .right {
          let location = sender.location(in: view)
          reporter.send("right \(location)")
        }
      }
    }
  }
}

class SwipeObserver : ObservableObject{
    
    @Published var items: [RSS] = []
    @Published var last = -1
    
    func update(id : RSS,value : CGFloat,degree : Double){
        
        for i in 0..<self.items.count{
            
            if self.items[i].id == id.id{
                
                self.items[i].drag = value
                self.items[i].degree = degree
                self.last = i
            }
        }
    }
}
