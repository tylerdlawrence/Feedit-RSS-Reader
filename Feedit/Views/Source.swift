//
//  Source.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/16/20.
//

//import SwiftUI

//class Source: Identifiable, Codable {
//    var id = UUID()
//    var title = "Anonymous"
//    var desc = ""
//    fileprivate(set) var isStarred = false
//}
//
//class Sources: ObservableObject {
//    @Published private(set) var sources: [Source]
//    static let saveKey = "SavedData"
//
//    init() {
//        if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
//            if let decoded = try? JSONDecoder().decode([Source].self, from: data) {
//                self.sources = decoded
//                return
//            }
//        }
//
//        self.sources = []
//    }
//
//    private func save() {
//        if let encoded = try? JSONEncoder().encode(sources) {
//            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
//        }
//    }
//
//    func add(_ source: Source) {
//        sources.append(source)
//        save()
//    }
//
//    func toggle(_ source: Source) {
//        objectWillChange.send()
//        source.isStarred.toggle()
//        save()
//    }
//}
//
