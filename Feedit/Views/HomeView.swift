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
    
    let defaultFeeds: [DefaultFeeds] = Bundle.main.decode("DefaultFeeds.json")

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
    
//    private var cardButton: some View {
//        Menu {
//            Button(action: {
//                print("All")
//            }, label: {
//                HStack{
//                    Text("All")
//                    Image(systemName: "text.justifyleft")
//                        //.font(.system(size: 16, weight: .heavy))
//                }
//            })
//
//            Button(action: {
//                print("Unread")
//            }, label: {
//                HStack{
//                    Text("Unread")
//                    Image(systemName: "circle.fill").font(.system(size: 16, weight: .heavy))
//                }
//            })
//            Button(action: {
//                print("Filters")
//            }, label: {
//                HStack{
//                    Text("Filters")
//                    Image(systemName: "chevron.up").font(.system(size: 16, weight: .heavy))
//                }
//            })
//        } label: {
//            Label(
//                title: { Text("")},
//                icon: { Image(systemName: "chevron.up").font(.system(size: 16, weight: .heavy)) }
//            )
//        }
//    }
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
            Menu {
                Button(action: {
                    self.isSheetPresented = true
                    self.selectedFeatureItem = .add
                }, label: {
                    HStack{
                        Text("Add Feed")
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .font(.system(size: 16, weight: .heavy))
                    }
                })
                
                Button(action: {
                    print("Add Folder")
                }, label: {
                    HStack{
                        Text("Add Folder")
                        Image(systemName: "folder").font(.system(size: 16, weight: .heavy))
                    }
                })
            } label: {
                Label(
                    title: { Text("")},
                    icon: { Image(systemName: "plus")
                        .imageScale(.large)
                    }
                )
            }
        }

    private var archiveListView: some View {
        ArchiveListView(viewModel: archiveListViewModel)
    }
    
    private var defaultFeedsListView: some View {
        DefaultFeedsListView(viewModel: viewModel)
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
        }
    }
    
    private var feedSection: some View {
        HStack{
             Image(systemName: "text.justifyleft").font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("bg"))
                .imageScale(.large)
             Text("Feeds").font(.system(size: 18, weight: .semibold))
         }
     }
    
    private var folderSection: some View {
        VStack{
            HStack{
                Image("disclosure")
                Text("Folders").font(.system(size: 18, weight: .semibold))
            }
        }
    }
    
    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))
    
  var body: some View {
    NavigationView {
        List {
            HStack(alignment: .top){
                VStack(alignment: .center){
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
                        .fontWeight(.bold)
                }.frame(width: 320.0).listRowBackground(Color("accent"))
            }.listRowBackground(Color("accent"))
            Section(header: feedView) {
                NavigationLink(destination: archiveListView) {
                    BookmarkView()
                        }
                NavigationLink(destination: Tag.demoTags.randomElement()!) {
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
                
                NavigationLink(destination: defaultFeedsListView) {
                    HStack{
                        Image(systemName: "chevron.right").font(.system(size: 10, weight: .heavy))
                            .foregroundColor(Color("bg"))
                            .imageScale(.large)
                        Text("Default Feeds")
                        Spacer()
                        Text("\(defaultFeeds.count)")
                    }
                }
                NavigationLink(destination: Text("News Folder")) {
                    HStack{
                        Image(systemName: "chevron.right").font(.system(size: 10, weight: .heavy))
                            .foregroundColor(Color("bg"))
                            .imageScale(.large)
                        Text("News")
                    }
                }
                NavigationLink(destination: Text("Blogs Folder")) {
                    HStack{
                        Image(systemName: "chevron.right").font(.system(size: 10, weight: .heavy))
                            .foregroundColor(Color("bg"))
                            .imageScale(.large)
                        Text("Blogs")
                    }
                }
                NavigationLink(destination: Text("Entertainment Folder")) {
                    HStack{
                        Image(systemName: "chevron.right").font(.system(size: 10, weight: .heavy))
                            .foregroundColor(Color("bg"))
                            .imageScale(.large)
                        Text("Entertainment")
                    }
                }
                NavigationLink(destination: Text("Technology Folder")) {
                    HStack{
                        Image(systemName: "chevron.right").font(.system(size: 10, weight: .heavy))
                            .foregroundColor(Color("bg"))
                            .imageScale(.large)
                        Text("Technology")
                    }
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
//            ToolbarItem(placement: .bottomBar) {
//                cardButton
//            }
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
                Image("star")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20, alignment: .center)
                Text("Starred")
                    .font(.system(size: 16, weight: .semibold))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("bg"))

            }
        }
    }
}
struct TagView: View {
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Image("smartFeedUnread")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20, alignment: .center)
                Text("Tags")
                    .font(.system(size: 16, weight: .semibold))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("bg"))
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
        ZStack {
            Color(.systemBackground)
        HomeView(viewModel: self.viewModel, archiveListViewModel: self.archiveListViewModel)
            .preferredColorScheme(.dark)
        }
    }
}
