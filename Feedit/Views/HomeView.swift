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

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let list = [GridItem(.flexible(minimum: 320))]
    
    let grid = [
        GridItem(.flexible(minimum: 160)),
        GridItem(.flexible(minimum: 160)),
        GridItem(.flexible(minimum: 160)),
    ]
    
    enum FeaureItem {
        case add
        case setting
        case card
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
    @State private var isCardPresented = false
    
    private var cardButton: some View {
        Button(action: {
            self.isCardPresented = true
            self.selectedFeatureItem = .card
        }) {
            CardView()
                .frame(width: 170.0, height: 50.0)
            }
        }
    private var settingButton: some View {
        Button(action: {
            self.selectedFeatureItem = .setting
            self.isSheetPresented = true
        }) {
            Image(systemName: "gear").font(.system(size: 16, weight: .heavy))
                .imageScale(.large)
                .foregroundColor(Color("lightShadow"))
        }
    }
    private var addSourceButton: some View {
        Button(action: {
            self.isSheetPresented = true
            self.selectedFeatureItem = .add
        }) {
            Image(systemName: "plus")
                .imageScale(.large)
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
        .foregroundColor(Color("bg"))
    }
    
    private var feedView: some View {
        HStack{
            Image(systemName: "archivebox").font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("bg"))
                .imageScale(.large)
            Text("All Items").font(.system(size: 18, weight: .semibold))
//                .font(.title3)
//                .fontWeight(.semibold)
        }
    }
    
    private var feedSection: some View {
        HStack{
             Image(systemName: "text.justifyleft").font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("bg"))
                .imageScale(.large)
             Text("Feeds").font(.system(size: 18, weight: .semibold))
//                 .font(.title3)
//                 .fontWeight(.semibold)
         }
     }
    
    private var folderSection: some View {
        HStack{
             Image(systemName: "folder").font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("bg"))
                .imageScale(.large)
             Text("Folders").font(.system(size: 18, weight: .semibold))
                 //.font(.title3)
                 //.fontWeight(.semibold)
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
                        .foregroundColor(Color("bg"))
                        .frame(width: 75, height: 75)
                    Text("On My iPhone")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Today at ").font(.system(.headline)) +
                        Text(Date(), style: .time)
                }.frame(width: 320.0).listRowBackground(Color("accent"))
            }.listRowBackground(Color("accent"))
//            VStack(alignment: .leading) {
//                HStack {
//                    feedView
//                    }.listRowBackground(Color("darkShadow"))
//                }
//                .listRowBackground(Color("accent"))
//                .edgesIgnoringSafeArea(.all)
            Section(header: feedView) {
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(Color("darkerAccent"))
//                        .multilineTextAlignment(.center))
//                HStack(alignment: .center) {
                
                NavigationLink(destination: archiveListView) {
                    BookmarkView()
                        }
                NavigationLink(destination: EmptyView()) {
                    TagView()
                }
                    }
                    .textCase(nil)
                    .accentColor(Color("darkShadow"))
                    .foregroundColor(Color("darkerAccent"))
                    .listRowBackground(Color("accent"))
                    .edgesIgnoringSafeArea(.all)
////                    DisclosureGroup(
////                    "❯  Feeds", //☰𝝣
////                    tag: .RSS,
////                    selection: $showingContent) {
            Section(header: feedSection) {
//                        Text("   □     Feeds")
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(Color("darkerAccent"))
//                        .multilineTextAlignment(.center)) {
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
                .accentColor(Color("darkShadow")).foregroundColor(Color("darkerAccent"))
                .edgesIgnoringSafeArea(.all)

            Section(header: folderSection) {
                List {
                    Text("Folders are coming.")
                }
            }
            .textCase(nil)
            .accentColor(Color("darkShadow"))
            .foregroundColor(Color("darkerAccent"))
            .listRowBackground(Color("accent"))
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
    //.listStyle(SidebarListStyle())
//    .listStyle(GroupedListStyle())
    .navigationTitle("")
    .navigationBarItems(trailing: trailingView)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                LazyHStack {
                    Button(action: {
                        print("All")
                    }) {
                        Image(systemName: "text.justifyleft").font(.system(size: 16, weight: .heavy))
                            .frame(width: 30, height: 30)
                    }
                    Button(action: {
                        print("Unread")
                    }) {
                        Image(systemName: "circle.fill")
                            .frame(width: 30, height: 30)
                    }
                    Button(action: {
                        print("Filters")
                    }) {
                        Image(systemName: "chevron.up").font(.system(size: 16, weight: .heavy))
                            .frame(width: 30, height: 30)
                    }
                }
            }
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
        VStack(alignment: .leading){
            HStack{
                Image(systemName: "bookmark").font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("bg"))
                    .imageScale(.medium)
                Text("Bookmarked")
                    .font(.system(size: 16, weight: .semibold))
                    .fontWeight(.semibold)
                    //.foregroundColor(Color("bg"))

            }
        }
    }
}
struct TagView: View {
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Image(systemName: "tag").font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("bg"))
                    .imageScale(.medium)
                Text("Tags")
                    .font(.system(size: 16, weight: .semibold))
                    .fontWeight(.semibold)
                    //.foregroundColor(Color("bg"))
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
