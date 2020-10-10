//
//  RSSListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import WidgetKit
import Intents
import FeedKit

struct RSSListView: View {
    
    enum FeatureItem {
        case remove
        case move
    }
    
    enum FeaureItem {
        case add
    }
    
    @ObservedObject var viewModel: RSSListViewModel
    
    @State private var selectedFeaureItem = FeaureItem.add
    @State private var selectedFeatureItem = FeatureItem.remove
    @State private var isAddFormPresented = false
    @State private var isSheetPresented = false
    @State private var addRSSProgressValue = 0.0
    @State var sources: [RSS] = []
    
    private var addSourceButton: some View {
        Button(action: {
            self.isSheetPresented = true
            self.selectedFeaureItem = .add
        }) {
            Image(systemName: "plus")
                .padding(.trailing, 0)
                .imageScale(.large)
        }
    }
    
    private var ListView: some View {
        HStack(alignment: .top, spacing: 24) {
            addSourceButton
        }
    }

    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))
    
// TODO: add move function
//.onMove { (indexSet, index) in
//self.viewModel.move(fromOffsets: indexSet, toOffset: index)
                
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items, id: \.self) { rss in
                    NavigationLink(destination: self.destinationView(rss)) {
                        RSSRow(rss: rss)
                        
                    }
                    .tag("RSS")
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        self.viewModel.delete(at: index)
                    }
                }
            }
            
            .navigationBarTitle("Feeds", displayMode: .automatic)
            .navigationBarItems(leading: EditButton(), trailing: ListView)
            .onAppear {
                self.viewModel.fecthResults()
            }
            
            .listStyle(InsetListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .font(.body)
        }
            .sheet(isPresented: $isSheetPresented, content: {
            AddRSSView( viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss),
                onDoneAction: self.onDoneAction)
        })
            .onAppear {
            self.viewModel.fecthResults()
        }
    }
    }
    
extension RSSListView {
    
    func onDoneAction() {
        self.viewModel.fecthResults()
    }
    
    private func destinationView(_ rss: RSS) -> some View {
        RSSFeedListView(viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
            .environmentObject(DataSourceService.current.rss)
    }

    func deleteItems(at offsets: IndexSet) {
        viewModel.items.remove(atOffsets: offsets)
    }
}

struct RSSListView_Previews: PreviewProvider {
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

    static var previews: some View {
        RSSListView(viewModel: self.viewModel)
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .small)
        }
    }

