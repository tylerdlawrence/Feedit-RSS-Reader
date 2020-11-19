//
//  HomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/12/20.
//

import SwiftUI
import ModalView
import FeedKit
import Foundation

enum FeaureItem {
    case add
    case setting
}
enum FeatureItem {
    case settings
}

struct HomeView: View {
    
    @State private var items = ["One", "Two", "Three", "Four", "Five"]

    enum ContentViewGroup: Hashable {
        
      case RSS
      case tag
      case folder
    }
    @ObservedObject var viewModel: RSSListViewModel
    @ObservedObject var archiveListViewModel: ArchiveListViewModel

//    @State private var activeSheet: Sheet?
    @State var showingContent: ContentViewGroup?
    @State private var selectedFeatureItem = FeaureItem.add
    @State private var isAddFormPresented = false
    @State private var isSettingPresented = false
//    @State private var selectedFeaureItem = FeaureItem.setting
    @State private var isSheetPresented = false
    @State private var addRSSProgressValue = 0.0
    @State var sources: [RSS] = []
    
    private var addSourceButton: some View {
        Button(action: {
            self.isSheetPresented = true
            self.selectedFeatureItem = .add
        }) {
            Image(systemName: "plus")
                .imageScale(.large)
                .contextMenu {
                    Button(action: {
                        // add feed
                    }) {
                        Text("Add Feed")
                        Image(systemName: "plus.circle")
                            .imageScale(.large)
                    }

                    Button(action: {
                        // add folder
                    }) {
                        Text("Add Folder")
                        Image(systemName: "folder")
                    }
                }
            }
        }
//            Image(systemName: "plus")
//                .imageScale(.large)
//        }
//    }
    
    private var settingButton: some View {
        Button(action: {
            self.isSheetPresented = true
            self.selectedFeatureItem = .setting
        }) {
            Image(systemName: "gear")
                .imageScale(.large)
        }
    }
    
    private var archiveListView: some View {
        ArchiveListView(viewModel: archiveListViewModel)
    }

//    private var trailingView: some View {
//        HStack(alignment: .top, spacing: 24) {
//            settingButton
//            addSourceButton
//        }
//    }
    
    private var folderListView: some View {
        NavigationView{
            NavigationLink(destination: Text("Folders")) {
                Image("folder.badge.gear")
            }
        }
    }
    
    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))
    
  var body: some View {
        
        NavigationView{
            
            List {
                
                Text("Local")
                    .font(.headline)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.leading)



                DisclosureGroup(
                "○  All Sources",
                tag: .RSS,
                selection: $showingContent) {
                    ForEach(viewModel.items, id: \.self) { rss in
                        NavigationLink(destination: self.destinationView(rss)) {
                            RSSRow(rss: rss)
                        }
                        .tag("RSS")
                    }
                    
                    .onMove { (indexSet, index) in
                        self.items.move(fromOffsets: indexSet,
                    toOffset: index)
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            self.viewModel.delete(at: index)
                        }
                    }
                    
                  }
                VStack {
                    NavigationLink(destination: archiveListView) {
                        ButtonView()
                    }
                 }
                Spacer()
                
                Text("Folders")
                    .font(.headline)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.leading)
                    NavigationLink(destination: Text("❯  News")) {
                        VStack{
                            Text("❯  News")
                        }
                    }
                    NavigationLink(destination: Text("❯  Blogs")) {
                        VStack{
                            Text("❯  Blogs")
                        }
                    }
                    NavigationLink(destination: Text("❯  Technology")) {
                        VStack{
                            Text("❯  Technology")
                        }
                    }
                    NavigationLink(destination: Text("❯  Entertainment")) {
                        VStack{
                            Text("❯  Entertainment")
                        }
                    }
            }
            .onReceive(rssRefreshPublisher, perform: { output in
        self.viewModel.fecthResults()
    })
    .sheet(isPresented: $isSheetPresented, content: {
        if FeaureItem.add == self.selectedFeatureItem {
            AddRSSView(
                viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss),
                onDoneAction: self.onDoneAction)
        } else if FeaureItem.setting == self.selectedFeatureItem { //FeaureItem.setting == self.selectedFeatureItem
            SettingView()
            //settingViewModel: self.settingViewModel
        }
    })
    .onAppear {
        self.viewModel.fecthResults()
    }
        .font(.headline)
        .listStyle(PlainListStyle())
            .navigationBarItems(trailing: addSourceButton)
        .navigationTitle("Account")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                            Spacer()
                        }
                ToolbarItem(placement: .bottomBar) {
                    settingButton
                }
            }
        }
    }
}


struct ButtonView: View {
    var body: some View {
        Image(systemName: "tag")
            .imageScale(.small)
        Text("Tagged Articles")
        
    }
}

struct FolderView: View {
    var body: some View{
    VStack {
        NavigationLink(destination: FolderView()) {
            VStack{
                Text("iFolders")
                Image("folder.badge.gear")
                }
            }
        }
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

    func deleteItems(at offsets: IndexSet) {
        viewModel.items.remove(atOffsets: offsets)
    }
}

struct HomeView_Previews: PreviewProvider {
    
    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

    static var previews: some View {
        
        HomeView(viewModel: self.viewModel, archiveListViewModel: self.archiveListViewModel)
            .preferredColorScheme(.dark)
    }
}
