//
//  HomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/12/20.
//

import SwiftUI
import CoreData
import Introspect

struct HomeView: View {
    enum FeaureItem {
        case add
        case setting
        case star
    }
    @Environment(\.editMode) var editMode
//    @AppStorage("darkMode") var darkMode = false
    @ObservedObject var articles: AllArticles
    @ObservedObject var rssItem: RSSItem
    @ObservedObject var viewModel: RSSListViewModel
    @ObservedObject var searchBar: SearchBar = SearchBar()
    @StateObject var rssFeedViewModel: RSSFeedViewModel
    @StateObject var archiveListViewModel: ArchiveListViewModel
    
    @State private var archiveScale: Image.Scale = .medium
    @State private var addRSSProgressValue = 1.0
    @State private var isSheetPresented = false
    @State private var action: Int?
    @State private var isSettingPresented = false
    @State private var isAddFormPresented = false
    @State private var selectedFeatureItem = FeaureItem.add
    @State private var revealFeedsDisclosureGroup = true
    @State private var revealSmartFilters = true
    @State private var isRead = false
    @State private var isLoading = false
    @State var isExpanded = true
    @State var sources: [RSS] = []
    
    var filteredArticles: [RSSItem] {
        return rssFeedViewModel.items.filter({ (item) -> Bool in
            return !((self.rssFeedViewModel.isOn && !item.isArchive) || (self.rssFeedViewModel.unreadIsOn && item.isRead))
        })
    }
    
    private var allArticlesView: some View {
        AllArticlesView(articles: AllArticles(dataSource: DataSourceService.current.rssItem))
    }
    
    private var archiveListView: some View {
        ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: self.rssFeedViewModel)
    }
    
    private var archiveButton: some View {
        Button(action: {
            self.action = 1
        }) {
            Image(systemName: "folder")
                .font(.system(size: 18, weight: .medium, design: .rounded)).foregroundColor(Color("tab"))
                    .padding([.top, .leading, .bottom])
        }
    }
    
    private var addSourceButton: some View {
        Button(action: {
            self.action = 2
            self.isSheetPresented = true
            self.selectedFeatureItem = .add
        }) {
            Image(systemName: "plus").font(.system(size: 20, weight: .medium, design: .rounded)).foregroundColor(Color("tab"))
                .padding([.top, .leading, .bottom])
        }
    }
    
    private var settingButton: some View {
        Button(action: {
            self.action = 3
            self.isSheetPresented = true
            self.selectedFeatureItem = .setting
        }) {
            Image(systemName: "gear").font(.system(size: 18, weight: .medium, design: .rounded)).foregroundColor(Color("tab"))
                .padding([.top, .bottom, .trailing])
        }
    }
    
    private var navButtons: some View {
        HStack(alignment: .top, spacing: 24) {
//            FilterPicker(isOn: 2, rssFeedViewModel: rssFeedViewModel)
            settingButton
            Spacer()
//            archiveButton
            folderButton
            addSourceButton
        }.padding(24)
    }
    
    private var feedsView: some View {
        DisclosureGroup(
            isExpanded: $revealSmartFilters,
            content: {
//        Section(header: Text("All Items").font(.system(size: 18, weight: .medium, design: .rounded)).foregroundColor(Color("text")).textCase(nil)) {
//            VStack{
                HStack {
                    ZStack{
                        NavigationLink(destination: allArticlesView) {
                            EmptyView()
                        }
                        .opacity(0.0)
                        .buttonStyle(PlainButtonStyle())
                    HStack{
                        Image(systemName: "tray.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 21, height: 21,alignment: .center)
                            .foregroundColor(Color("tab").opacity(0.9))
                        Text("All Articles")
                        Spacer()
                        Text("\(articles.items.count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 1)
                            .background(Color.gray.opacity(0.5))
                            .opacity(0.4)
                            .cornerRadius(8)
                            
                        }.accentColor(Color("tab").opacity(0.9))
                    }
                    .onAppear {
                        self.articles.fecthResults()
                        self.articles.fetchCount()
                    }
                }.listRowBackground(Color("accent"))
                    
                HStack {
                    ZStack{
                        NavigationLink(destination: DataNStorageView(rssFeedViewModel: self.rssFeedViewModel, viewModel: self.viewModel)) {
                            EmptyView()
                        }
                        .opacity(0.0)
                        .buttonStyle(PlainButtonStyle())
                    HStack{
//                        Label("Archive", systemImage: "archivebox")
                        Image(systemName: "archivebox")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 21, height: 21,alignment: .center)
                            .foregroundColor(Color("tab").opacity(0.9))
                        Text("Archive")
                        Spacer()
                        Text("\(viewModel.items.count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 1)
                            .background(Color.gray.opacity(0.5))
                            .opacity(0.4)
                            .cornerRadius(8)
                            
                        }.accentColor(Color("tab").opacity(0.9))
                    
                    }
                    
                }.listRowBackground(Color("accent"))
                
                
//            }.listRowBackground(Color("accent"))
                HStack {
                    ZStack{
                    NavigationLink(destination: archiveListView) {
                        EmptyView()
                    }
                    .opacity(0.0)
                    .buttonStyle(PlainButtonStyle())
                    HStack{
    //                    Label("Starred", systemImage: "star")
                        Image(systemName: "star")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 21, height: 21,alignment: .center)
                            .foregroundColor(Color("tab").opacity(0.9))
                        Text("Starred")
                        
                            Spacer()
                        Text("\(archiveListViewModel.items.count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 1)
                            .background(Color.gray.opacity(0.5))
                            .opacity(0.4)
                            .cornerRadius(8)
                    }
                }.listRowBackground(Color("accent"))
                    .accentColor(Color("tab").opacity(0.9))
                .onAppear {
                    self.archiveListViewModel.fecthResults()
                }
    //        }
                }.listRowBackground(Color("accent"))
            },
            label: {
                HStack {
                    Text("All Items")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                self.revealSmartFilters.toggle()
                            }
                        }
                }
            }).listRowBackground(Color("darkerAccent"))
//            .listRowBackground(Color("darkerAccent"))
            .accentColor(Color("tab"))
        }
    
    let selection = Set<RSS>()
    private var feedsSection: some View {
        DisclosureGroup(
            isExpanded: $revealFeedsDisclosureGroup,
            content: {
//        Section(header: Text("Feeds").font(.system(size: 18, weight: .medium, design: .rounded)).foregroundColor(Color("text")).textCase(nil)) {
            ForEach(viewModel.items, id: \.self) { rss in
                ZStack {
                    NavigationLink(destination: NavigationLazyView(self.destinationView(rss: rss))) {
                        EmptyView()
                    }
                    .opacity(0.0)
                    .buttonStyle(PlainButtonStyle())
                    HStack {
                        RSSRow(rss: rss, viewModel: self.viewModel)
                        Spacer()
                        Text("\(viewModel.items.count)")
//                        Text("\(rssFeedViewModel.items.count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 1)
                            .background(Color.gray.opacity(0.5))
                            .opacity(0.4)
                            .foregroundColor(Color("text"))
                            .cornerRadius(8)
                    }
                }
            }
            .onDelete { indexSet in
                if let index = indexSet.first {
                    self.viewModel.delete(at: index)
                }
            }

            .listRowBackground(Color("accent"))
//        }
            },
            label: {
                HStack {
                    Text("Feeds")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                self.revealFeedsDisclosureGroup.toggle()
                            }
                        }
                }.frame(maxWidth: .infinity)
            })
            .listRowBackground(Color("darkerAccent"))
            .accentColor(Color("tab"))
    }
    
    private var folderButton: some View {
        NavigationLink(destination: RSSGroupListView(persistence: Persistence.current, viewModel: self.viewModel)) {
            Image(systemName: "folder").font(.system(size: 18, weight: .medium, design: .rounded)).foregroundColor(Color("tab"))
                .padding([.top, .bottom, .trailing])
        }
    }
    
    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))
    
    var body: some View {
        NavigationView{
            VStack {
                ZStack {
                    List {
                        feedsView
//                        Spacer()
                        RSSFoldersDisclosureGroup(persistence: Persistence.current, viewModel: self.viewModel)
//                        Spacer()
                        feedsSection
                    }
                    //.listSeparatorStyle(.none)
                    .navigationBarItems(trailing:
                                            HStack(spacing: 20) {
                                                Button(action: {
                                                    startNetworkCall()
                                                }) {
                                                    if isLoading {
                                                        ProgressView()
                                                            .progressViewStyle(CircularProgressViewStyle(tint: Color("tab")))
                                                            .scaleEffect(1)
                                                        } else {
                                                            Image(systemName: "arrow.clockwise").font(.system(size: 16, weight: .bold)).foregroundColor(Color("tab"))
                                                    }
                                                }
                                            })
                
//                    .listStyle(GroupedListStyle())
//                    .listStyle(SidebarListStyle())
//                    .listStyle(PlainListStyle())
//                    .listStyle(InsetGroupedListStyle())
//                    .introspectTableView { tableView = $0 }
                    .navigationBarTitle("Home", displayMode: .automatic)
                    .add(self.searchBar)
                    .environment(\.editMode, self.editMode)
//                    .preferredColorScheme(darkMode ? .dark : .light)
                }
                .onAppear {
                    startNetworkCall()
                }
            Spacer()
                if addRSSProgressValue > 0 && addRSSProgressValue < 1.0 {
                    LinerProgressBar(lineWidth: 3, color: .blue, progress: $addRSSProgressValue)
                        .frame(width: UIScreen.main.bounds.width, height: 3, alignment: .leading)
                }
            navButtons
                .frame(width: UIScreen.main.bounds.width, height: 49, alignment: .leading)
            NavigationLink(
                destination: ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: self.rssFeedViewModel),
                tag: 1,
                selection: $action) {
                EmptyView()
                }
            }.redacted(reason: isLoading ? .placeholder : [])
            .onReceive(addRSSPublisher, perform: { output in
                guard
                    let userInfo = output.userInfo,
                    let total = userInfo["total"] as? Double else { return }
                self.addRSSProgressValue += 1.0/total
            })
            .onReceive(rssRefreshPublisher, perform: { output in
                self.viewModel.fecthResults()
            })
            .sheet(isPresented: $isSheetPresented, content: {
                if FeaureItem.add == self.selectedFeatureItem {
                    AddRSSView(
                        viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss),
                                            onDoneAction: self.onDoneAction)
                    
                } else if FeaureItem.setting == self.selectedFeatureItem {
                    SettingView(fetchContentTime: .constant("minute1"))
                }
            })
        }
        .onAppear {
            self.viewModel.fecthResults()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

extension HomeView {
    
//    func delete(_ rss: RSS) {
//        self.viewModel.items.removeAll(where: {$0 == rss})
//        }
    
    func onDoneAction() {
        self.viewModel.fecthResults()
    }
    func startNetworkCall() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
        }
    }
    private func destinationView(rss: RSS) -> some View {
        let item = RSSItem()
        return RSSFeedListView(viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), wrapper: item, filter: .all)
            .environmentObject(DataSourceService.current.rss)
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static let rss = RSS()
    static let rssItem = RSSItem()
    static let articles = AllArticles(dataSource: DataSourceService.current.rssItem)
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
    static var group: RSSGroup = {
      let controller = Persistence.preview
      return controller.makeRandomFolder(context: controller.context)
    }()
    @State static var selection: Set<RSSGroup> = [group]

    static var previews: some View {
        HomeView(articles: articles, rssItem: rssItem, viewModel: self.viewModel, rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), archiveListViewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
            .environment(\.managedObjectContext, Persistence.current.context)
            .environmentObject(Persistence.current)
                .environment(\.colorScheme, .dark)
    }
}
#endif

extension Collection {
    func count(where item: (Element) throws -> Bool) rethrows -> Int {
        return try self.filter(item).count
    }
}

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content

    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
 }
