//
//  SearchBar.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 12/17/20.
//

import SwiftUI

struct SearchBarView: View {
        
    var feed = ["Blog", "Feed", "hello", "RSS", "News", "Covid", "Better", "Days"]
        //["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"] + ["Ceres", "Pluto", "Haumea", "Makemake", "Eris"]
    
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(
                    feed.filter {
                        searchBar.text.isEmpty ||
                        $0.localizedStandardContains(searchBar.text)
                    },
                    id: \.self
                ) { eachFeed in
                    Text(eachFeed) //as! DateInterval)
                }
            }
                .add(self.searchBar)
        }
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView()
    }
}
