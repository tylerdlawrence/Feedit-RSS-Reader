//
//  HomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/12/20.
//

import SwiftUI
import SwiftUIX
import CoreData
import Introspect
import Combine
import WebKit

struct HomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(fetchRequest: Settings.fetchAllRequest()) var all_settings: FetchedResults<Settings>
            
    var settings: Settings {
        if let first = self.all_settings.first {
            if UIApplication.shared.alternateIconName != first.alternateIconName {
                UIApplication.shared.setAlternateIconName(first.alternateIconName, completionHandler: {error in
                    if let _ = error {
                        first.alternateIconName = nil
                        try? first.managedObjectContext?.save()
                        return
                    }
                })
            }
            return first
        }

        return Settings(context: viewContext)
    }
    
    enum FeaureItem {
        case add
        case setting
        case folder
        case star
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    @ObservedObject var articles: AllArticles
    @ObservedObject var unread: Unread
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
    @State private var revealFeedsDisclosureGroup = false
    @State private var revealSmartFilters = true
    @State private var isRead = false
    @State private var isLoading = false
    @State private var isExpanded = false
    @State var sources: [RSS] = []
    
    var filteredArticles: [RSSItem] {
        return rssFeedViewModel.items.filter({ (item) -> Bool in
            return !((self.rssFeedViewModel.isOn && !item.isArchive) || (self.rssFeedViewModel.unreadIsOn && item.isRead))
        })
    }
        
//    private var allArticlesView: some View {
//        let rss = RSS()
//        return AllArticlesView(articles: AllArticles(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
//    }
//
//    private var archiveListView: some View {
//        ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: self.rssFeedViewModel)
//    }
//
//    private var unreadListView: some View {
//        UnreadListView(unreads: Unread(dataSource: DataSourceService.current.rssItem))
//    }
    
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
            Image(systemName: "plus").font(.system(size: 20, weight: .medium, design: .rounded))
                .padding([.top, .leading, .bottom])
                
        }
    }
    
    private var folderButtonPopUp: some View {
        Button("Add Folder", action: {
            self.action = 4
            self.isSheetPresented = true
            self.selectedFeatureItem = .folder
        })
    }
    
    private var settingButton: some View {
        Button(action: {
            self.action = 3
            self.isSheetPresented = true
            self.selectedFeatureItem = .setting
        }) {
            Image(systemName: "gear").font(.system(size: 18, weight: .medium, design: .rounded))
                .padding([.top, .bottom, .trailing])
        }
    }
    private var navButtons: some View {
        HStack(alignment: .top, spacing: 24) {
//            FilterPicker(isOn: 2, rssFeedViewModel: rssFeedViewModel)
            settingButton
            Spacer()
//            archiveButton
//            folderButton
//            addSourceButton
            Menu {
                Button(action: {self.action = 4
                        self.isSheetPresented = true
                        self.selectedFeatureItem = .folder}, label: {
                    Label(
                        title: { Text("Add Folder") },
                        icon: {Image(systemName: "folder.badge.plus") }
                    )
                })
                Button(action: {self.action = 2
                        self.isSheetPresented = true
                        self.selectedFeatureItem = .add}, label: {
                    Label(
                        title: { Text("Add Feed") },
                        icon: {Image(systemName: "plus.circle") }
                    )
                })
            } label: {
               Image(systemName: "plus").font(.system(size: 18, weight: .medium, design: .rounded)).padding([.top, .bottom])
            }
        }.padding(24)
    }
    
    private var header: some View {
        Home()
    }
    
//    private var feedsView: some View {
////        DisclosureGroup(
////            isExpanded: $revealSmartFilters,
////            content: {
//
//        //.font(.system(size: 20, weight: .medium, design: .rounded)).foregroundColor(Color("text")).textCase(nil)
//
//        Section(header: Text("Smart Feeds").font(.system(size: 20, weight: .medium, design: .rounded)).textCase(nil).foregroundColor(Color("text"))) {
//                HStack {
//                    ZStack{
//                        NavigationLink(destination: allArticlesView) {
//                            EmptyView()
//                        }
//                        .opacity(0.0)
//                        .buttonStyle(PlainButtonStyle())
//                    HStack{
//                        Image(systemName: "archivebox")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 21, height: 21,alignment: .center)
//                            .foregroundColor(Color.gray.opacity(0.8))
////                            .foregroundColor(Color("tab").opacity(0.9))
//                        Text("All Articles")
//                        Spacer()
//                        Text("\(articles.items.count)")
//                            .font(.caption)
//                            .fontWeight(.bold)
//                            .padding(.horizontal, 7)
//                            .padding(.vertical, 1)
//                            .background(Color.gray.opacity(0.5))
//                            .opacity(0.4)
//                            .cornerRadius(8)
//
//                        }.accentColor(Color("tab").opacity(0.9))
//                    }
//                    .onAppear {
//                        self.articles.fecthResults()
//                    }
//                }//.listRowBackground(Color("accent"))
//
//                HStack {
//                    ZStack{
//                        NavigationLink(destination: unreadListView) {
//                            EmptyView()
//                        }
//                        .opacity(0.0)
//                        .buttonStyle(PlainButtonStyle())
//                    HStack{
//                        Image(systemName: "largecircle.fill.circle")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 21, height: 21,alignment: .center)
//                            .foregroundColor(Color("tab").opacity(0.8))
//                        Text("Unread")
//                        Spacer()
//                        Text("\(unread.items.count)")
//                            .font(.caption)
//                            .fontWeight(.bold)
//                            .padding(.horizontal, 7)
//                            .padding(.vertical, 1)
//                            .background(Color.gray.opacity(0.5))
//                            .opacity(0.4)
//                            .cornerRadius(8)
//
//                        }.accentColor(Color("tab").opacity(0.8))
//
//                    }
//                    .onAppear {
//                        self.unread.fecthResults()
//                    }
//                }//.listRowBackground(Color("accent"))
//
//                HStack {
//                    ZStack{
//                    NavigationLink(destination: archiveListView) {
//                        EmptyView()
//                    }
//                    .opacity(0.0)
//                    .buttonStyle(PlainButtonStyle())
//                    HStack{
//                        Image(systemName: "star")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 21, height: 21,alignment: .center)
////                            .foregroundColor(Color("tab").opacity(0.9))
//                            .foregroundColor(Color.yellow.opacity(0.8))
//                        Text("Starred")
//
//                            Spacer()
//                        Text("\(archiveListViewModel.items.count)")
//                            .font(.caption)
//                            .fontWeight(.bold)
//                            .padding(.horizontal, 7)
//                            .padding(.vertical, 1)
//                            .background(Color.gray.opacity(0.5))
//                            .opacity(0.4)
//                            .cornerRadius(8)
//                    }
//                }//.listRowBackground(Color("accent"))
//                    .accentColor(Color("tab").opacity(0.9))
//                .onAppear {
//                    self.archiveListViewModel.fecthResults()
//                }
//            }
////            .listRowBackground(Color("accent"))
////            },
////            label: {
////                HStack {
////                    Text("All Items")
////                        .font(.system(size: 14, weight: .regular, design: .rounded)).textCase(.uppercase)
////                        .frame(maxWidth: .infinity, alignment: .leading)
////                        .contentShape(Rectangle())
////                        .onTapGesture {
////                            withAnimation {
////                                self.revealSmartFilters.toggle()
////                            }
////                        }
////                }
////            })
//        }
//        .environmentObject(unread)
//        .environmentObject(DataSourceService.current.rss)
//        .environmentObject(DataSourceService.current.rssItem)
//        .environment(\.managedObjectContext, Persistence.current.context)
////            .listRowBackground(Color("darkerAccent"))
//            .accentColor(Color("tab"))
//    }
    
//    private var feedsSection: some View {
//        DisclosureGroup(
//            isExpanded: $revealFeedsDisclosureGroup,
//            content: {
////        Section(header: Text("Feeds")) {
//            ForEach(viewModel.items, id: \.self) { rss in
//                ZStack {
//                    NavigationLink(destination: self.destinationView(rss: rss)) {
//                        EmptyView()
//                    }
//                    .opacity(0.0)
//                    .buttonStyle(PlainButtonStyle())
//                    HStack {
//                        RSSRow(rss: rss, viewModel: viewModel)
//                    }
//                }
//            }
//            .onDelete { indexSet in
//                if let index = indexSet.first {
//                    self.viewModel.delete(at: index)
//                }
//            }
//
//            .listRowBackground(Color("accent"))
////        }
//            .environmentObject(DataSourceService.current.rss)
//            .environmentObject(DataSourceService.current.rssItem)
//            .environment(\.managedObjectContext, Persistence.current.context)
//            },
//            label: {
//                HStack {
//                    Text("Feeds")
//                        .font(.system(size: 14, weight: .regular, design: .rounded)).textCase(.uppercase)
////                        .font(.system(size: 20, weight: .semibold, design: .rounded))
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            withAnimation {
//                                self.revealFeedsDisclosureGroup.toggle()
//                            }
//                        }
//                }.frame(maxWidth: .infinity)
//            })
////            .listRowBackground(Color("darkerAccent"))
//            .accentColor(Color("tab"))
//    }
    
//    private var folderButton: some View {
//        NavigationLink(destination: RSSGroupListView(persistence: Persistence.current, viewModel: self.viewModel)) {
//            Image(systemName: "folder").font(.system(size: 18, weight: .medium, design: .rounded))
//                .padding([.top, .bottom])
//        }
//    }
    
    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))
    
    
    
    @State var name = ""
    @ObservedObject var persistence: Persistence
    @State var addGroupIsPresented = false
    @State private var selectedCells: Set<RSS> = []
    var rss = RSS()
    @State var onComplete: (Set<RSSGroup>) = []
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollViewReader { scrollViewProxy in
                ZStack {
                    List {
                        SmartFeedsHomeView(rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), articles: AllArticles(dataSource: DataSourceService.current.rssItem), unread: Unread(dataSource: DataSourceService.current.rssItem), archiveListViewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
                        
                        RSSFoldersDisclosureGroup(persistence: Persistence.current, unread: unread, viewModel: self.viewModel, isExpanded: selectedCells.contains(rss))
                            .onTapGesture { self.selectDeselect(rss) }
                    }
                    .environmentObject(DataSourceService.current.rss)
                    .environmentObject(DataSourceService.current.rssItem)
                    .environment(\.managedObjectContext, Persistence.current.context)
                    .navigationBarTitle("Home", displayMode: .automatic)
                    .add(self.searchBar)
                }
                
            Spacer()
                
                if addRSSProgressValue > 0 && addRSSProgressValue < 1.0 {
                    LinerProgressBar(lineWidth: 3, color: .blue, progress: $addRSSProgressValue)
                        .frame(width: UIScreen.main.bounds.width, height: 3, alignment: .leading)
                }
            navButtons
                .frame(width: UIScreen.main.bounds.width, height: 49, alignment: .leading)
//            NavigationLink(
//                destination: ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem), rssFeedViewModel: self.rssFeedViewModel),
//                tag: 1,
//                selection: $action) {
//                EmptyView()
//                }
            }
            .redacted(reason: isLoading ? .placeholder : [])
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
                    SettingView(fetchContentTime: .constant("minute1"), iconSettings: IconNames())
                        .environment(\.managedObjectContext, Persistence.current.context).environmentObject(Settings(context: Persistence.current.context))
                }
                else if FeaureItem.folder == self.selectedFeatureItem {
                    AddGroup { name in
                      addNewGroup(name: name)
                      addGroupIsPresented = false
                    }
                }
            })
        }
//        .onAppear {
//            self.viewModel.fecthResults()
//            }
//        .navigationViewStyle(StackNavigationViewStyle())
    }
    private func selectDeselect(_ rss: RSS) {
        if selectedCells.contains(rss) {
            selectedCells.remove(rss)
        } else {
            selectedCells.insert(rss)
        }
    }
    private func addNewGroup(name: String) {
      withAnimation {
        persistence.addNewGroup(name: name)
        }
    }
}

extension HomeView {
    func onDoneAction() {
        self.viewModel.fecthResults()
    }
    func selectDeselect(_ group: RSSGroup) {
        print("Selected \(String(describing: group.id))")
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static let rss = RSS()
    static let rssItem = RSSItem()
    static let unread = Unread(dataSource: DataSourceService.current.rssItem)
    static let articles = AllArticles(dataSource: DataSourceService.current.rssItem)
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss, unreadCount: 10)
    static var group: RSSGroup
        = {
      let controller = Persistence.current
      return controller.makeRandomFolder(context: controller.context)
    }()
    @State static var selection: Set<RSSGroup> = [group]
    @State static var onComplete: (Set<RSSGroup>) = []
    
    static var previews: some View {
        HomeView(articles: articles, unread: unread, rssItem: rssItem, viewModel: self.viewModel, rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), archiveListViewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem), persistence: Persistence.current)
            .environmentObject(DataSourceService.current.rssItem)
            .environment(\.managedObjectContext, Persistence.current.context)
            .preferredColorScheme(.dark)
    }
}
#endif

