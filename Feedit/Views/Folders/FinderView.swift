//
//  FinderView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/16/21.
//

import SwiftUI
import CoreData
import Foundation
import os.log

struct searchBar: View {
    @State var input = ""
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $input)
                Spacer()
                Image(systemName: "mic.fill")
            }
            .foregroundColor(Color(UIColor.secondaryLabel))
            .padding(12)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(14)
        }
    }
}

struct categorySection: View {
    @State var label: String
    
    @State var isExpanded = true
    
    @State var tagRow: Bool = false
    var body: some View {
        VStack (spacing: 14) {
            HStack {
                HStack {
                    VStack {
                        Image(systemName: "chevron.right")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                    .rotationEffect(self.isExpanded ? Angle(degrees: 90):  Angle(degrees: 0))
                    .animation(.easeOut(duration: 0.40))
                    .onTapGesture {
                        self.isExpanded.toggle()
                    }
                                        
                    Text(label)
                        .foregroundColor(Color(UIColor.label))
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .fontWeight(.semibold)
                        .onTapGesture {
                            self.isExpanded.toggle()
                    }
                    Spacer()
                }
            }
            HStack {
                if isExpanded == true {
                    VStack (spacing: 0) {
                        listItemRow(
                            tagRow: $tagRow,
                            label: "Item One",
                            tagColor: Color.blue
                        )
                        listItemRow(
                            tagRow: $tagRow,
                            label: "Item Two",
                            tagColor: Color.red
                        )
//                        listItemRow(
//                            tagRow: $tagRow,
//                            label: "Item Three",
//                            tagColor: Color.yellow
//                        )
//                        listItemRow(
//                            tagRow: $tagRow,
//                            label: "Item Four",
//                            tagColor: Color.orange
//                        )
                    }
                }
            }
//            .animation(.easeInOut(duration: 0.25))
            .frame(maxWidth: .infinity)
        }
    }
}

struct listItemRow: View {
    @Binding var tagRow: Bool
    @State var label: String
    @State var tagColor: Color
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            HStack (alignment: .center, spacing: 12) {
                if tagRow {
                    Circle()
                        .fill(tagColor)
                        .frame(width: 14, height: 14)
                } else {
                    Image(systemName: "chevron.right")
                }
                Text(label)
            }
            .padding()
            Divider()
        }
    }
}

struct FinderView: View {
    let rss = RSS()
    let rssItem = RSSItem()
    let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
    @ObservedObject var searchBar: SearchBar = SearchBar()

    var body: some View {
        ZStack {
            NavigationView {
                List{
//                    ScrollView(showsIndicators: false) {
                        VStack (alignment: .leading, spacing: 24) {
                            categorySection(
                                label: "Locations",
                                isExpanded: false,
                                tagRow: false
                            )
                            categorySection(
                                label: "Favorites",
                                isExpanded: true,
                                tagRow: false
                            )
                            categorySection(
                                label: "Tags",
                                isExpanded: true,
                                tagRow: true
                            )
                        }
//                    }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    .listRowBackground(Color(.black))
                }
                
                .add(self.searchBar)
                .listStyle(SidebarListStyle())
                .navigationBarItems(trailing: Button(action: {}) {
                    Image(systemName: "ellipsis.circle")
                })
                .navigationBarTitle("Finder")
            }
            .frame(width: 400, height: 780)
            
        }
    }
}

struct FinderView_Previews: PreviewProvider {
    static let rss = RSS()
    static let rssItem = RSSItem()
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
    static var previews: some View {
        FinderView()
            .preferredColorScheme(.dark)
    }
}
