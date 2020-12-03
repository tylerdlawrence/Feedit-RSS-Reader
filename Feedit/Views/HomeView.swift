//
//  HomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/12/20.
//

import SwiftUI
import FeedKit
import KingfisherSwiftUI
import CoreData

struct HomeView: View {

    enum FeaureItem {
        case add
        case setting
    }
    
    @State var sources: [RSS] = []

    @ObservedObject var viewModel: RSSListViewModel
    @ObservedObject var archiveListViewModel: ArchiveListViewModel
    
    @State private var selectedFeatureItem = FeaureItem.add
    @State private var isAddFormPresented = false
    @State private var isSettingPresented = false
    @State private var isSheetPresented = false
    @State private var addRSSProgressValue = 0.0
    @State private var previewIndex = 0

    private var addSourceButton: some View {
        Button(action: {
            self.isSheetPresented = true
            self.selectedFeatureItem = .add
        }) {
            Image(systemName: "plus")
                .imageScale(.large)
            }
        }
    private var settingButton: some View {
        Button(action: {
            self.selectedFeatureItem = .setting
            self.isSheetPresented = true
        }) {
            Image(systemName: "gear").font(.system(size: 16, weight: .heavy))
                .imageScale(.large)
                .foregroundColor(Color("darkShadow"))
        }
    }
    private var archiveListView: some View {
        ArchiveListView(viewModel: archiveListViewModel)
    }

    private var trailingView: some View {
        HStack(alignment: .top, spacing: 24) {
            //EditButton()
            addSourceButton
        }
        .foregroundColor(Color("darkShadow"))
    }
    
       private var feedView: some View {
        HStack{
            Image(systemName: "text.justifyleft").font(.system(size: 16, weight: .heavy))
                .foregroundColor(Color("darkShadow"))
                .imageScale(.large)
            Text("All Items")
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
    
    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))
    
  var body: some View {
    NavigationView {
        List {
            HStack(alignment: .top){
                VStack(alignment: .center){
//                    Image("launch")
                    Image(systemName: "icloud")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120.0, height: 120.0)
//                    Text("On My iPhone")
//                        .font(.title3)
//                        .fontWeight(.semibold)
                }.frame(width: 320.0).listRowBackground(Color("accent"))
            }.listRowBackground(Color("accent"))
            VStack(alignment: .leading) {
                HStack {
                    feedView
                    }.listRowBackground(Color("darkShadow"))
                }
                .listRowBackground(Color("accent"))
                .edgesIgnoringSafeArea(.all)
            HStack(alignment: .center) {
                        NavigationLink(destination: archiveListView) {
                            BookmarkView()
                    }
                    .listRowBackground(Color("accent"))
                }
                .listRowBackground(Color("accent"))
                .edgesIgnoringSafeArea(.all)
////                    DisclosureGroup(
////                    "❯  Feeds", //☰𝝣
////                    tag: .RSS,
////                    selection: $showingContent) {
            Section(header: Text("   □     Feeds")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("darkerAccent"))
                        .multilineTextAlignment(.center)) {
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
                .textCase(nil)
                .listRowBackground(Color("accent"))
                .accentColor(Color("darkShadow"))
                .edgesIgnoringSafeArea(.all)
                }
                .onReceive(rssRefreshPublisher, perform: { output in
                    self.viewModel.fecthResults()
                })
                .sheet(isPresented: $isSheetPresented, content: {
                    if FeaureItem.add == self.selectedFeatureItem {
                        AddRSSView(
                            viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss),
                            onDoneAction: self.onDoneAction)
                    } else if FeaureItem.setting == self.selectedFeatureItem {
                        SettingView()
                    }
                })
        .listStyle(SidebarListStyle())
        //.listStyle(GroupedListStyle())
        .navigationTitle("")
        .navigationBarItems(trailing: trailingView)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                            Spacer()
                        }
                ToolbarItem(placement: .bottomBar) {
                    settingButton
                        }
                    }
                }
            .onAppear {
                self.viewModel.fecthResults()
        }
    }
}

struct BookmarkView: View {
    var body: some View {
//        Image(systemName: "bookmark").font(.system(size: 16, weight: .bold))
//            .foregroundColor(Color("darkShadow"))
//            .imageScale(.medium)
        Image("bookmark-tag")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            .cornerRadius(5)
        Text("  Bookmarked")
            .font(.system(size: 16, weight: .semibold))
            .fontWeight(.medium)
    }
}

extension DisclosureGroup where Label == Text {
  public init<V: Hashable, S: StringProtocol>(
    _ label: S,
    tag: V,
    selection: Binding<V?>,
    content: @escaping () -> Content) {
    let boolBinding: Binding<Bool> = Binding(
      get: { selection.wrappedValue == tag },
      set: { newValue in
        if newValue {
          selection.wrappedValue = tag
        } else {
          selection.wrappedValue = nil
        }
      }
    )

    self.init(
      label,
      isExpanded: boolBinding,
      content: content
    )
  }
}

extension HomeView {
    
    func onDoneAction() {
        self.viewModel.fecthResults()
    }
    
    private func destinationView(_ rss: RSS) -> some View {
        RSSFeedListView(viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
            .environmentObject(DataSourceService.current.rss)
    }
    private func destinationFolderView(_ rss: RSS) -> some View {
        RSSFeedListView(viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
            .environmentObject(DataSourceService.current.rss)
    }

    func deleteItems(at offsets: IndexSet) {
        viewModel.items.remove(atOffsets: offsets)
    }
}

struct HomeView_Previews: PreviewProvider {
    
    static let current = DataSourceService()
    
    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)

    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

    static var previews: some View {
        
        HomeView(viewModel: self.viewModel, archiveListViewModel: self.archiveListViewModel)
            .preferredColorScheme(.dark)
    }
}
