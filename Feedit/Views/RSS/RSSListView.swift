//
//  RSSListView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import WidgetKit
import Intents

struct RSSListView: View {
    
    enum FeaureItem {
        case add
    }
    
    @ObservedObject var viewModel: RSSListViewModel
    
    @State private var selectedFeatureItem = FeaureItem.add
    @State private var isAddFormPresented = false
    @State private var isSheetPresented = false
 //   @State private var addRSSProgressValue = 0.0
    @State var sources: [RSS] = []
    
    private var addSourceButton: some View {
        Button(action: {
            self.isSheetPresented = true
            self.selectedFeatureItem = .add
        }) {
            Image(systemName: "plus")
                .imageScale(.large)
        }
    }
    
//    private var settingButton: some View {
//        Button(action: {
//            self.isSheetPresented = true
//            self.selectedFeatureItem = .setting
//        }) {
//           Image(systemName: "ellipsis.circle")
//                .imageScale(.large)
//        }
//    }


    private var ListView: some View {
        HStack(alignment: .top, spacing: 24) {
            addSourceButton
            
        }
    }
//    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
//    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items, id: \.self) { rss in
                    NavigationLink(destination:  self.destinationView(rss)) {
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
            .navigationBarTitle("Feeds", displayMode: .inline)
            .navigationBarItems(trailing: ListView)
        }
        .padding(.horizontal, -10)
        .sheet(isPresented: $isSheetPresented, content: {
                    AddRSSView(
                        viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss),
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
    
}

struct RSSListView_Previews: PreviewProvider {
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

    static var previews: some View {
        RSSListView(viewModel: self.viewModel)
            .preferredColorScheme(.dark)
            
        
            }
        }


