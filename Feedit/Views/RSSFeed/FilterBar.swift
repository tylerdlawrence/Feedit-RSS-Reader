//
//  SmartFilters.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 1/19/21.
//

import SwiftUI
import Combine
import FeedKit
import Foundation

enum FilterType: String {
    case all = "All"
    case unreadOnly = "Unread"
    case starredOnly = "Starred"
}

struct FilterBar: View {
    @State private var refresh = UUID()
    @Binding var selectedFilter: FilterType
    @Binding var showFilter: Bool
    var markedAllPostsRead: (() -> Void)?
    
    var body: some View {
        HStack(alignment:.center) {
                    ZStack {
                        if selectedFilter == .starredOnly {
                            Capsule()
                                .frame(width: 90, height: 25)
                                .opacity(0.5)
                                .foregroundColor(Color.gray.opacity(0.5))

                        HStack {
                            Image(systemName: "star.fill").font(.system(size: 10, weight: .black))
                            Text(FilterType.starredOnly.rawValue)
                                .textCase(.uppercase)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Color("text"))
                            }
                        } else {
                            Image(systemName: "star.fill").font(.system(size: 10, weight: .black))
                        }
                    }
                    .padding()
                    .onTapGesture {
                        self.selectedFilter = .starredOnly
                    }
                    Spacer()
            
                    ZStack {
                        if selectedFilter == .unreadOnly {
                            Capsule()
                                .frame(width: 85, height: 25)
                                .opacity(0.5)
                                .foregroundColor(Color.gray.opacity(0.5))
                        HStack {
                            Image(systemName: "circle.fill").font(.system(size: 10, weight: .black))
                            Text(FilterType.unreadOnly.rawValue)
                                .textCase(.uppercase)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("text"))
                            }
                        } else {
                            Image(systemName: "circle.fill").font(.system(size: 10, weight: .black))
                        }
                    }
                    .padding()
                    .onTapGesture {
                        self.selectedFilter = .unreadOnly
                    }
                    Spacer()
                    
                    ZStack {
                        if selectedFilter == .all {
                            Capsule()
                                .frame(width: 65, height: 25)
                                .opacity(0.5)
                                .foregroundColor(Color.gray.opacity(0.5))


                        HStack{
                            Image(systemName: "text.justifyleft").font(.system(size: 10, weight: .black))
                            Text(FilterType.all.rawValue)
                                .textCase(.uppercase)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(Color("text"))
                            }
                        } else {
                            Image(systemName: "text.justifyleft").font(.system(size: 10, weight: .black))
                            }
                        }
                        .padding()
                        .onTapGesture {
                            self.selectedFilter = .all
                        }
                        Spacer()
        }.id(refresh)
            .frame(height: 20)

    }
}

struct FilterBar_Previews: PreviewProvider {
    static var previews: some View {
        FilterBar(selectedFilter: .constant(.all),
                   showFilter: .constant(true), markedAllPostsRead: nil)
    }
}

class FeedObject: Identifiable, ObservableObject {
    var id = UUID()
    var url: URL
    var posts: [RSSItem] {
        didSet {
            objectWillChange.send()
        }
    }
    
    var imageURL: URL?
    
    var lastUpdateDate: Date
    
    init?(feed: Feed, url: URL, posts: [RSSItem]) {
        self.url = url
        lastUpdateDate = Date()
        self.posts = posts

    }

}
