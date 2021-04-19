//
//  Searchbar.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 1/18/21.
//

import Foundation
import Combine
import SwiftUI

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


//struct Searchbar: View {
//    @ObservedObject var searchBar: SearchBar = SearchBar()
//
//    var body: some View {
//        NavigationView{
//            List {
//                Text("test")
//                Text("hi")
//                Text("hello")
//            }
//            .navigationBarTitle("Search")
//            .listStyle(InsetGroupedListStyle())
//            .add(searchBar)
//        }
//    }
//}

struct SearchbarView: View {
    @Binding var searchText: String
//    @ObservedObject var searchBar: SearchBar = SearchBar()
    
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
                Image(systemName: "xmark.circle.fill")
.foregroundColor(.secondary)
.opacity(searchText == "" ? 0 : 1)
            }
        }.padding(.horizontal)
    }
}
