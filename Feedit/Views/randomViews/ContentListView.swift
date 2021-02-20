//
//  ContentListView.swift
//  continuum
//
//  Created by Tyler D Lawrence on 10/12/20.
//


import SwiftUI

struct ContentListView: View {
    
    private var homeListView: some View {
        RSSListView(viewModel: RSSListViewModel(dataSource: DataSourceService.current.rss), items: item.stubs)
    
    @State var sheetSelection: SheetType?
    
    var body: some View {
        NavigationView {
            List {
                Button(action: {
                    sheetSelection = .itemsList
                }, label: {
                    Text("Delete")
                })
                
                Button(action: {
                    sheetSelection = .RSSListView
                }, label: {
                    Text("Feeds")
                })
                
//                Button(action: {
//                    sheetSelection = .form
//                }, label: {
//                    Text("Delete")
//                })
            }

            }.listStyle(InsetGroupedListStyle())
            .navigationTitle("Feeds")
            }
        }
    }
}


enum SheetType: String, Identifiable {
    var id: String { self.rawValue}
    case itemsList
    case RSSListView
    //case form
}

struct ContentListView_Previews: PreviewProvider {
    static var previews: some View {
        ContentListView()
        ItemsList(items: Item.stubs)
    }
}

