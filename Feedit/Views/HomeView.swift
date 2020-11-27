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
import MobileCoreServices

struct Item: Identifiable {
    let id = UUID()
    let title: String
}
enum FeaureItem {
    case add
    case setting
}
enum FeatureItem {
    case settings
}
enum ContentViewSheet: Identifiable {
  case plus
  case settings

  var id: Int {
    switch self {
    case .plus:
      return 1
    case .settings:
      return 2
    }
  }
}
struct HomeView: View {
    @State private var showingSheet: ContentViewSheet?
    @Environment(\.managedObjectContext) var moc
    
enum ContentViewGroup: Hashable {
    case RSS
    case tag
}
    
    @State var sources: [RSS] = []

    @ObservedObject var viewModel: RSSListViewModel
    @ObservedObject var archiveListViewModel: ArchiveListViewModel
    
    @State var showingContent: ContentViewGroup?
    @State private var selectedFeatureItem = FeaureItem.add
    @State private var isAddFormPresented = false
    @State private var isSettingPresented = false
    @State private var isSheetPresented = false
    @State private var addRSSProgressValue = 0.0
    @State private var previewIndex = 0
    
    @FetchRequest(entity: Category.entity(), sortDescriptors: []) var categories: FetchedResults<Category>
    
    private var addSourceButton: some View {
        Button(action: {
            self.showingSheet = .plus
            self.isSheetPresented = true
            self.selectedFeatureItem = .add
        }) {
            Image(systemName: "plus")
                .imageScale(.large)
            }
        }
    
    private var settingButton: some View {
        Button(action: {
            self.showingSheet = .settings
            self.selectedFeatureItem = .setting
            self.isSheetPresented = true
        }) {
            Image(systemName: "gear")
                .imageScale(.large)
        }
    }
    @ViewBuilder
    private func presentSheet(for sheet: ContentViewSheet) -> some View {
      switch sheet {
      case .plus:
        AddRSSView(
            viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss),
            onDoneAction: self.onDoneAction)
      case .settings:
        SettingView()
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
    
    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))
    
    @State private var rss: [Item] = []
    @State private var editMode = EditMode.inactive
    private static var count = 0
    
    private var addButton: some View {
        switch editMode {
        case .inactive:
            return AnyView(Button(action: onAdd) { Image(systemName: "plus.circle.fill") })
        default:
            return AnyView(EmptyView())
        }
    }

    private func onDelete(offsets: IndexSet) {
        rss.remove(atOffsets: offsets)
    }

    private func onMove(source: IndexSet, destination: Int) {
        rss.move(fromOffsets: source, toOffset: destination)
    }

    private func onInsert(at offset: Int, itemProvider: [NSItemProvider]) {
        for provider in itemProvider {
            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    DispatchQueue.main.async {
                        url.map { self.rss.insert(Item(title: $0.absoluteString), at: offset) }
                    }
                }
            }
        }
    }

    private func onAdd() {
        rss.append(Item(title: "Folder\(Self.count)"))
        Self.count += 1
    }

  var body: some View {
        NavigationView{
            List {
                HStack{
                    Image("launch")
                        .resizable()
                        .frame(width: 35.0, height: 35.0)
                    Text("Local: On My iPhone")
                        .font(.custom("Gotham", size: 18))
                }
                
                Spacer()

                DisclosureGroup(
               " ❯   All Sources", //○♾️☰🔵🔲☁
                tag: .RSS,
                selection: $showingContent) {
                    ForEach(viewModel.items, id: \.self) { rss in
                        NavigationLink(destination: self.destinationView(rss)) {
                            RSSRow(rss: rss)
                        }
                        .tag("RSS")
                    }
                    //.onMove(perform: onMove)
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
                //Spacer()
                
//                Picker("Folders", selection: $previewIndex) {
//                    ForEach(0 ..< categories.count) {
//                        Text(categories[$0].name)
//                        NavigationView {
//                            VStack {
//                                List(categories, id: \.self) { category in
//                                    VStack(alignment: .leading) {
//                                        Text(category.name)
//                                            .font(.system(size: 12))
//                                            .padding(EdgeInsets(top: 4, leading: 7, bottom: 4, trailing: 7))
//                                            .cornerRadius(3)
//
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }

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
                .onAppear {
                    UITableView.appearance().separatorStyle = .none
                    self.viewModel.fecthResults()
                }
                .font(.custom("Gotham", size: 17))
                .listStyle(PlainListStyle())
                .navigationBarItems(leading: EditButton(), trailing: addSourceButton)
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
 
//
//                DisclosureGroup(
//                " ❯  News",
//                tag: .folder1,
//                selection: $showingContent) {
//                    ForEach(viewModel.items, id: \.self) { rss in
//                        NavigationLink(destination: self.destinationFolderView(rss)) {
//                            RSSRow(rss: rss)
//                        }
//                        .tag("folder1")
//                    }
//                }
////                    NavigationLink(destination: Text("❯  News")) {
////                        VStack{
////                            Text("❯  News")
////                        }
////                    }

struct HeaderView: View {
  let title: String

  var body: some View {
    Text(title)
      .font(.title)
      .fontWeight(.bold)
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct RowView: View {
  let text: String

  var body: some View {
    Text(text)
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}


struct ButtonView: View {
    var body: some View {
        Image(systemName: "bookmark")
            .foregroundColor(.blue)
            .imageScale(.medium)
        Text("Bookmarked Articles")
        
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
    
    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)

    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

    static var previews: some View {
        
        HomeView(viewModel: self.viewModel, archiveListViewModel: self.archiveListViewModel)
    }
}

