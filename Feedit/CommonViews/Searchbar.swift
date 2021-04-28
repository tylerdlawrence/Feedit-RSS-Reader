//
//  Searchbar.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 1/18/21.
//

import Foundation
import Combine
import SwiftUI
import SwiftyJSON
import Alamofire

final class SearchBar: NSObject, ObservableObject {
    @Published var text: String = ""
    let searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    override init() {
        super.init()
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.autocapitalizationType = .none
        self.searchController.searchBar.placeholder = "Search"
    }
    func willSet() { objectWillChange.send() }
}

extension SearchBar: UISearchResultsUpdating {
   
    func updateSearchResults(for searchController: UISearchController) {
        
        // Publish search bar text changes.
        if let searchBarText = searchController.searchBar.text {
            self.text = searchBarText
        }
    }
}

struct SearchBarModifier: ViewModifier {
    let searchBar: SearchBar

    func body(content: Content) -> some View {
        content
            .overlay(
                ViewControllerResolver { viewController in
                    viewController.navigationItem.searchController = self.searchBar.searchController
                }
                .frame(width: 0, height: 0)
            )
    }
}

extension View {
    func add(_ searchBar: SearchBar) -> some View {
        return self.modifier(SearchBarModifier(searchBar: searchBar))
    }
}

final class ViewControllerResolver: UIViewControllerRepresentable {
    let onResolve: (UIViewController) -> Void
        
    init(onResolve: @escaping (UIViewController) -> Void) {
        self.onResolve = onResolve
    }
    
    func makeUIViewController(context: Context) -> ParentResolverViewController {
        ParentResolverViewController(onResolve: onResolve)
    }
    
    func updateUIViewController(_ uiViewController: ParentResolverViewController, context: Context) {
        
    }
}

class ParentResolverViewController: UIViewController {
    
    let onResolve: (UIViewController) -> Void
    
    init(onResolve: @escaping (UIViewController) -> Void) {
        self.onResolve = onResolve
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use init(onResolve:) to instantiate ParentResolverViewController.")
    }
        
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        if let parent = parent {
            onResolve(parent)
        }
    }
}

struct SearchbarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
          Image(systemName: "magnifyingglass")
            .padding(.leading, -10)
            .foregroundColor(.secondary)
            TextField("Search", text: $searchText, onCommit:  {
                UIApplication.init().windows.first { $0.isKeyWindow }?.endEditing(true)
            })
          .padding(.leading, 10)
            Button(action: {
                self.searchText = ""
            }) {
                Image(systemName: "xmark.circle.fill").foregroundColor(.secondary).opacity(searchText == "" ? 0 : 1)
            }
        }.padding(.horizontal)
    }
}

struct SearchResultItem: Identifiable, Hashable {
    
    let id: String
    let sName: String
}

public class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?

    public init(delay: TimeInterval) {
        self.delay = delay
    }

    /// Trigger the action after some delay
    public func run(action: @escaping () -> Void) {
        workItem?.cancel()
        workItem = DispatchWorkItem(block: action)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem!)
    }
}



class SearchResult: ObservableObject {
    
    @Published var results = [SearchResultItem]()
    
    func fetchData (url: String, callback: @escaping (_ json:JSON) -> Void) {
        //fetch json and decode and update array property
        
        if let url = URL(string: (url)) {
            print("requesting: \(url)")
            AF.request(url).validate().responseJSON{(response) in
                if let data  = response.data {
                    let json = JSON(data)
                    callback(json)
                    print(json)
                    return
                }
            }
        }
        
    }
    

    
    func processValues(json: JSON) {
        for (index, subJson):(String, JSON) in json {
            print(json[index], subJson)
        }
    }
}

protocol JSONable {
    init?(parameter: JSON)
}

extension JSON {
    func to<T>(type: T?) -> Any? {
        if let baseObj = type as? JSONable.Type {
            if self.type == .array {
                var arrObject: [Any] = []
                for obj in self.arrayValue {
                    let object = baseObj.init(parameter: obj)
                    arrObject.append(object!)
                }
                return arrObject
            } else{
                let object = baseObj.init(parameter: self)
                return object!
            }
        }
        return nil
    }
}
