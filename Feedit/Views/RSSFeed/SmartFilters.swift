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

struct FilterView: View {
    @Binding var selectedFilter: FilterType
    @Binding var showFilter: Bool
    var markedAllPostsRead: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Smart Filters").font(.system(size: 17, weight: .regular, design: .rounded))
            
                HStack() {
                    Spacer()
                    
                    ZStack {
                        
                        if selectedFilter == .all {
                            RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(Color.backgroundNeo)
                        } else {
                            RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(Color.backgroundNeo)
                        }
                        Image(systemName: "text.justifyleft").font(.system(size: 16, weight: .black))
                    }
                    .padding()
                    .onTapGesture {
                        self.selectedFilter = .all
                    }
                    
                    ZStack {
                        
                        if selectedFilter == .unreadOnly {
                            RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(Color.backgroundNeo)
                        } else {
                            RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(Color.backgroundNeo)
                        }
                        Image(systemName: "circle.fill").font(.system(size: 16, weight: .black))
//                        Text(FilterType.unreadOnly.rawValue)
//                            .font(.system(size: 17, weight: .regular, design: .rounded))
                    }
                    .padding()
                    .onTapGesture {
                        self.selectedFilter = .unreadOnly
                    }

                    Spacer()
                    ZStack {

                    if selectedFilter == .starredOnly {
                        RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(Color.backgroundNeo)
                    } else {
                        RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(Color.backgroundNeo)
                    }
                        Image(systemName: "star.fill").font(.system(size: 16, weight: .black))
//                    Text(FilterType.starredOnly.rawValue)
//                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .onTapGesture {
                            self.selectedFilter = .starredOnly
                        }
                    }.padding()
                }.frame(height: 70)
                .padding()


                //Spacer()
                
                
                
//            Text("Options")
//                .font(.subheadline)

                Button(action: {
                    self.markedAllPostsRead?()
                }) {
                    Image("MarkAllAsRead")
                    Text("Mark All As Read")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .font(.subheadline)
                        .foregroundColor(Color(.label))
                        //.padding()
                }
                .frame(height: 70)
            }
        .padding()
        .frame(height: showFilter ? nil : 0)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(selectedFilter: .constant(.all),
                   showFilter: .constant(true), markedAllPostsRead: nil)
    }
}
//struct FilterListView: View{
//    @ObservedObject var rssListViewModel: RSSListViewModel
//    @ObservedObject var viewModel: PostListViewModel
//    @ObservedObject var rss: RSS
//    @Environment(\.presentationMode) var presentationMode
//    private func destinationView(rss: RSS) -> some View {
//        RSSFeedListView(withURL: "", rssViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
//            .environmentObject(DataSourceService.current.rss)
//    }
//    var body: some View{
//        List {
//            FilterView(selectedFilter: $viewModel.filterType, showFilter: $viewModel.showFilter, markedAllPostsRead: {
//                self.$viewModel.markAllPostsRead()
//
//            })
//            ForEach($viewModel.items.filteredPosts.indices, id: \.self) { index in
//                Button(action: {
//                    self.$viewModel.selectPost(index: index)
//                })  {
//                    RSSFeedListView(withURL: "", rssViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
//                        .environmentObject(DataSourceService.current.rss)
//
//                }
//            }
//        }
//    }
//}

class FeedObject: Codable, Identifiable, ObservableObject {
    var id = UUID()
    var url: URL
    var posts: [Post] {
        didSet {
            objectWillChange.send()
        }
    }
    
    var imageURL: URL?
    
    var lastUpdateDate: Date
    
    init?(feed: Feed, url: URL, posts: [Post]) {
        self.url = url
        lastUpdateDate = Date()
        self.posts = posts

    }

}

public class PostListViewModel: ObservableObject {
    
    @ObservedObject var store = RSSItemStore.instance
    @Published var feed: FeedObject
    @Published var filteredPosts: [Post] = []
    @Published var filterType = FilterType.unreadOnly
    @Published var selectedPost: Post?
    @Published var showingDetail = false
    @Published var shouldReload = false
    @Published var showFilter = false
    
    private var cancellable: AnyCancellable? = nil
    private var cancellable2: AnyCancellable? = nil
    let rss: RSS
    init(rss:RSS,feed: FeedObject) {
        self.rss = rss
        self.feed = feed
        self.filteredPosts = feed.posts.filter { self.filterType == .unreadOnly ? !$0.isRead : true }
        cancellable = Publishers.CombineLatest3(self.$feed, self.$filterType, self.$shouldReload)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (newValue) in
                self.filteredPosts = newValue.0.posts.filter { newValue.1 == .unreadOnly ? !$0.isRead : true }
            })
    }
    
    func setPostRead(post: Post, feed:RSSItem) {
        post.readDate = Date()
        feed.objectWillChange.send()
    }
}
