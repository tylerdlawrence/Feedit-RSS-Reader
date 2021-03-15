//
//  RSSObservable.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 2/6/21.
//

//import Foundation
//import Combine
//
////class RSS
//
//class RSSObservable: ObservableObject {
//    @Published var items: [RSS] = []
//
//    init(items: [RSS]) {
//        self.items = items
//    }
//
//    func insert(head item: RSS) {
//        self.items.insert(item, at: 0)
//    }
//
//    func append(_ item: RSS) {
//        self.items.append(item)
//    }
//
//    func append(contentsOf items: [RSS]) {
//        self.items.append(contentsOf: items)
//    }
//
//    func delete(_ item: RSS) {
//        self.items.removeAll { item == $0 }
//    }
//}
