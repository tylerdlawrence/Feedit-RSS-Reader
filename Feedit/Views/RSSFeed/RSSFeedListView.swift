//
//  RSSItemListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import FeedKit
import Combine

struct RSSFeedListView: View {
    
    public static let shared = ImageService()
    
    public func fetchImage(url: URL) -> AnyPublisher<UIImage?, Never> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> UIImage? in
                return UIImage(data: data)
                
        }.catch { error in
            
            return Just(nil)
            
        }
        
            .eraseToAnyPublisher()
    
    }
    
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
        
    }
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    
    @State private var selectedItem: RSSItem?
    @State private var isSafariViewPresented = false
    @State private var start: Int = 0
    @State private var footer: String = "Refresh"
    @State var cancellables = Set<AnyCancellable>()
    
    init(viewModel: RSSFeedViewModel) {
        self.rssFeedViewModel = viewModel
        
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(self.rssFeedViewModel.items, id: \.self) { item in
                    RSSItemRow(wrapper: item,
                               menu: self.contextmenuAction(_:))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.selectedItem = item
                        }
                }
                VStack(alignment: .center) {
                    Button(action: self.rssFeedViewModel.loadMore) {
                        Text(self.footer)
                    }
                }
            }
            .padding(.top)
            .navigationBarTitle(rssSource.title)
            .listStyle(InsetGroupedListStyle())
        }.onAppear {
            self.rssFeedViewModel.fecthResults()
            self.rssFeedViewModel.fetchRemoteRSSItems()
        }
        .sheet(item: $selectedItem, content: { item in
            if AppEnvironment.current.useSafari {
                SafariView(url: URL(string: item.url)!)
            } else {
                WebView(
                    rssItem: item,
                    onArchiveAction: {
                        self.rssFeedViewModel.archiveOrCancel(item)
                })
            }
        })
        .onAppear {
            self.rssFeedViewModel.fecthResults()
            self.rssFeedViewModel.fetchRemoteRSSItems()
        }
    }
    
    func contextmenuAction(_ item: RSSItem) {
        rssFeedViewModel.archiveOrCancel(item)
    }
}

extension RSSFeedListView {
    
    private func destinationView(_ rss: RSS) -> some View {
        RSSFeedListView(viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
            .environmentObject(DataSourceService.current.rss)
    }
}

struct RSSFeedListView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 11")
            
    }
}
