//
//  Searchbar.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 1/18/21.
//

import SwiftUI

class SearchBar: NSObject, ObservableObject {
    @Published var text: String = ""
    let searchController: UISearchController = UISearchController(searchResultsController: nil)

    override init() {
        super.init()
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.autocapitalizationType = .none
        self.searchController.searchBar.placeholder = "Search"
    }
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


struct Searchbar: View {
    @ObservedObject var searchBar: SearchBar = SearchBar()


    var body: some View {
        NavigationView{
            List {
                Text("test")
                Text("hi")
                Text("hello")
            }
            .navigationBarTitle("Search")
            .listStyle(InsetGroupedListStyle())
            .add(self.searchBar)
        }
    }
}

struct Searchbar_Previews: PreviewProvider {
    static var previews: some View {
        Searchbar()
    }
}

//import UIKit
//import SwiftUI
//import EasySwiftUI
//
//struct SearchBar: View {
//    @Binding
//    var searchText: String
//    let onChange: () -> Void
//    @State
//    private var showsCancelButton: Bool = false
//
//    var body: some View {
//        return HStack {
//            textField
//            cancelButton
//        }
//    }
//
//    private var searchTextBinding: Binding<String> {
//        Binding<String>(get: {
//            searchText
//        }, set: { newValue in
//            DispatchQueue.main.async {
//                searchText = newValue
//                onChange()
//            }
//        })
//    }
//
//    private var textField: some View {
//        HStack {
//            Image(systemName: SFSymbol.magnifyingglass.rawValue)
//
//            TextField("Search", text: searchTextBinding, onEditingChanged: { isEditing in
//                withAnimation {
//                    self.showsCancelButton = true
//                }
//                onChange()
//            }, onCommit: {
//                // No op
//            })
//            .foregroundColor(.primary)
//
//            Button(action: {
//                self.searchText = ""
//            }) {
//                Image(systemName: SFSymbol.xmarkCircleFill.rawValue)
//                    .opacity(searchText == "" ? 0 : 1)
//            }
//        }
//        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
//        .foregroundColor(.secondary)
//        .background(Color(.systemBackground))
//        .cornerRadius(10.0)
//    }
//
//    @ViewBuilder
//    private var cancelButton: some View {
//        if showsCancelButton  {
//            Button("Cancel") {
//                UIApplication.shared.endEditing(true)
//                withAnimation {
//                    self.searchText = ""
//                    self.showsCancelButton = false
//                }
//                onChange()
//            }
//            .foregroundColor(Color(.systemBlue))
//        }
//    }
//}
//
//extension UIApplication {
//    func endEditing(_ force: Bool) {
//        self.windows
//            .filter{$0.isKeyWindow}
//            .first?
//            .endEditing(force)
//    }
//}
