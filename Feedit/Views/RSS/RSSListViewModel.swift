//
//  RSSListViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import Foundation
import Combine

class RSSListViewModel: NSObject, ObservableObject{
    
//    @Published var feeds: [String] = load("DefaultFeeds.json")
    @EnvironmentObject var viewModel: RSSListViewModel
    @Environment(\.managedObjectContext) var managedObjectContext

    @Published var articles: [RSSItem] = []
    @Published var items: [RSS] = []
    @State var editMode = EditMode.inactive
    @State var selection = Set<String>()
    let dataSource: RSSDataSource
    var start = 0
    
    init(dataSource: RSSDataSource) {
        self.dataSource = dataSource
        super.init()
    }
    
    var isRead: Bool {
        return readDate != nil
    }
    
    var readDate: Date? {
        didSet {
            objectWillChange.send()
        }
    }
    
    func loadMore() {
        start = items.count
        fecthResults(start: start)
    }
    
    func fecthResults(start: Int = 0) {
        if start == 0 {
            items.removeAll()
        }
        dataSource.performFetch(RSS.requestObjects())
        if let objects = dataSource.fetchedResult.fetchedObjects {
            items.append(contentsOf: objects)
        }
    }
    
    private func delete(rss: RSS) {
        if let index = self.viewModel.items.firstIndex(where: { $0.id == rss.id }) {
            viewModel.items.remove(at: index)
//            viewModel.items.remove(atOffsets: offsets)
            
//            func delete(at index: Int) {
//                let object = items[index]
//                dataSource.delete(object, saveContext: true)
//                items.remove(at: index)
//            }
        }
    }
    
    func delete(at index: Int) {
        let object = items[index]
        dataSource.delete(object, saveContext: true)
        items.remove(at: index)
    }
    private var deleteButton: some View {
        if editMode == .inactive {
            return Button(action: {}) {
                Image(systemName: "")
            }
        } else {
            return Button(action: deleteNumbers) {
                Image(systemName: "trash")
            }
        }
    }
    
    private func deleteNumbers() {
        for id in viewModel.items {
            if let index = viewModel.items.lastIndex(where: { $0 == id })  {
                viewModel.items.remove(at: index)
            }
        }
        self.viewModel.items = [RSS]()

//        selection = items
    }
        
    private var editButton: some View {
        if editMode == .inactive {
            return Button(action: {
                self.editMode = .active
                self.viewModel.items = [RSS]()
            }) {
                Text("Edit")
            }
        }
        else {
            return Button(action: {
                self.editMode = .inactive
                self.viewModel.items = [RSS]()
//                self.selection = Set<String>()
            }) {
                Text("Done")
            }
        }
    }
}
    
final class ModelData: ObservableObject {
    
    @Published var feeds: [String] = load("DefaultFeeds.json")
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
