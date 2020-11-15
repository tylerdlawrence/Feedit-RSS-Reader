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
    
    @Environment(\.colorScheme) var colorScheme

    @State private var selectedItem: RSSItem?
    @State private var isSafariViewPresented = false
    @State private var start: Int = 0
    @State private var footer: String = "Load more articles"
    @State var cancellables = Set<AnyCancellable>()
    
    init(viewModel: RSSFeedViewModel) {
        self.rssFeedViewModel = viewModel
        
    }
    
    private var archiveListView: some View {
        Button(action: {
            print ("Tags")
        }) {
            Image(systemName: "tag")
                .imageScale(.medium)
        }
    }
    
    private var markAllRead: some View {
        Button(action: {
            print ("Mark all as Read")
        }) {
            Image(systemName: "checkmark")
                .imageScale(.medium)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 20, height: 20)
        }
    }
    
    private var trailingFeedView: some View {
        HStack(alignment: .top, spacing: 24) {
            archiveListView
            markAllRead
        }
    }
    
    var body: some View {
        VStack(alignment: .leading){
                Text(rssSource.title)
                    .font(.title2)
                    .fontWeight(.heavy)
            HStack{
                Text("Added")
                    .font(.footnote)
                    .fontWeight(.heavy)
                Text(rssSource.createTimeStr)
                    .font(.footnote)
                    .fontWeight(.heavy)
            }
            Text(rssSource.desc)
                    .font(.footnote)
        }
        .frame(width: 325.0, height: 80)

        VStack{
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
            .listStyle(PlainListStyle())
            }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: trailingFeedView)
        //.navigationBarHidden(true)
        .onAppear {
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
    
    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

    static let settingViewModel = SettingViewModel()

    static var previews: some View {
        ContentView(settingViewModel: self.settingViewModel, viewModel: self.viewModel)
        }
    }
//archiveListViewModel: self.archiveListViewModel,
//settingViewModel: self.settingViewModel,
