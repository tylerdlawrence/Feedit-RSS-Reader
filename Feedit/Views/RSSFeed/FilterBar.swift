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
    case unreadIsOn = "Unread"
    case isArchive = "Starred"
}

struct FilterBar: View {
    @Binding var selectedFilter: FilterType
//    @Binding var showFilter: Bool
    @Binding var isOn: Bool
    var markedAllPostsRead: (() -> Void)?
    
    var body: some View {
        ZStack {
//            Capsule()
            RoundedRectangle(cornerRadius: 25.0)
                .frame(width: 205, height: 35).foregroundColor(Color("text")).opacity(0.1)
            HStack(spacing: 0) {
                Spacer()
                ZStack {
                    if selectedFilter == .isArchive {
                        Capsule()
                            .frame(width: 85, height: 25)
                            .opacity(0.5)
                            .foregroundColor(Color.gray.opacity(0.5))

                    HStack {
                        Image(systemName: "star.fill").font(.system(size: 10, weight: .black))
                        Text(FilterType.isArchive.rawValue)
                            .textCase(.uppercase)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(Color("text"))
                        }
                    } else {
                        Image(systemName: "star.fill").font(.system(size: 10, weight: .black))
                    }
                }
                .padding()
                .onTapGesture {
                    self.selectedFilter = .isArchive
                }
                Divider()
        
                ZStack {
                    if selectedFilter == .unreadIsOn {
                        Capsule()
                            .frame(width: 85, height: 25)
                            .opacity(0.5)
                            .foregroundColor(Color.gray.opacity(0.5))
                    HStack {
                        Image(systemName: "circle.fill").font(.system(size: 10, weight: .black))
                        Text(FilterType.unreadIsOn.rawValue)
                            .textCase(.uppercase)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(Color("text"))
                        }
                    } else {
                        Image(systemName: "circle.fill").font(.system(size: 10, weight: .black)).padding()
                    }
                }//.padding()
                .onTapGesture {
                    self.selectedFilter = .unreadIsOn
                }
                Divider()
                
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
                    }.padding()
                    .onTapGesture {
                        self.selectedFilter = .all
                    }
                    Spacer()
            }
            .frame(width: 125, height: 20)
        }
    }
}

struct FilterBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            Spacer()
            FilterBar(selectedFilter: .constant(.unreadIsOn),
                   isOn: .constant(true), markedAllPostsRead: nil)
                .preferredColorScheme(.dark)
        }
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


struct FilterPicker: View {
    @State var isOn = 1
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    var body: some View {
        Picker(selection: $isOn, label: Text(""), content: {
            Image(systemName: "star.fill")
                .font(.system(size: 10, weight: .black)).tag(0)
            
            Image(systemName: "circle.fill").font(.system(size: 10, weight: .black)).tag(1)
            
            Image(systemName: "text.justifyleft").font(.system(size: 10, weight: .black)).tag(2)
                
        }).pickerStyle(SegmentedPickerStyle()).frame(width: 160, height: 20).padding(.top)
    }
}

struct FilterPicker_Previews: PreviewProvider {
    static let rss = RSS()
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
    static var previews: some View {

        FilterPicker(isOn: 1, rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem, isRead: false))
                .preferredColorScheme(.dark)
        
    }
}
