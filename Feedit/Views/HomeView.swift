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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
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
        return Settings(context: viewContext) }
    
    enum FeaureItem {
        case add
        case setting
        case folder
        case star
    }
    
    @ObservedObject var rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    @StateObject var archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    
    @EnvironmentObject private var persistence: Persistence
    @ObservedObject var articles: AllArticles
    @ObservedObject var unread: Unread
    @ObservedObject var rssItem: RSSItem
    @ObservedObject var viewModel: RSSListViewModel
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    @State private var archiveScale: Image.Scale = .medium
    @State private var addRSSProgressValue = 1.0
    @State private var isSheetPresented = false
    @State private var sheetAction: Int?
    @State private var isSettingPresented = false
    @State private var isAddFormPresented = false
    @State private var selectedFeatureItem = FeaureItem.add
    @State var addGroupIsPresented = false
    @State private var selectedCells: Set<RSS> = []
    var rss = RSS()
    
    private var archiveButton: some View {
        Button(action: {
            self.sheetAction = 1
        }) {
            Image(systemName: "folder")
                .font(.system(size: 18, weight: .medium, design: .rounded)).foregroundColor(Color("tab"))
                    .padding([.top, .leading, .bottom])
        }
    }
    
    private var addSourceButton: some View {
        Button(action: {
            self.sheetAction = 2
            self.isSheetPresented = true
            self.selectedFeatureItem = .add
        }) {
            Image(systemName: "plus").font(.system(size: 20, weight: .medium, design: .rounded))
                .padding([.top, .bottom])
        }
    }

    private var settingButton: some View {
        Button(action: {
            self.sheetAction = 3
            self.isSheetPresented = true
            self.selectedFeatureItem = .setting
        }) {
            Image(systemName: "gear").font(.system(size: 18, weight: .medium, design: .rounded))
                .padding([.top, .bottom])
        }
    }
    
    private var folderButtonPopUp: some View {
        Button("Add Folder", action: {
            self.sheetAction = 4
            self.isSheetPresented = true
            self.selectedFeatureItem = .folder
        })
    }
    
    private var navButtons: some View {
        HStack(alignment: .center, spacing: 24) {
            settingButton
            Spacer()
            Picker("Home", selection: $selectedFilter, content: {
                ForEach(FilterType.allCases, id: \.self) {
                    Text($0.rawValue)
                }
//                SelectedFilterView(selectedFilter: selectedFilter)
            }).pickerStyle(SegmentedPickerStyle()).frame(width: 180, height: 20).listRowBackground(Color("accent"))
            Spacer()
            Menu {
                Button(action: {self.sheetAction = 4
                        self.isSheetPresented = true
                        self.selectedFeatureItem = .folder}, label: {
                    Label(
                        title: { Text("Add Folder") },
                        icon: {Image(systemName: "folder.badge.plus") }
                    )
                })
                Button(action: {self.sheetAction = 2
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
    
    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))
    
    var filteredFeeds: [RSS] {
        return viewModel.items.filter({ (rss) -> Bool in
            return !((self.viewModel.isOn && !rss.isArchive) || (self.viewModel.unreadIsOn && rss.isRead))
        })
    }
    
    func filterFeeds(url: String?) -> RSS? {
            guard let url = url else { return nil }
        return viewModel.items.first(where: { $0.url.id == url })
        }
    
    @State var selectedFilter: FilterType
    @State private var editMode = EditMode.inactive
    @State var isEditing = false
    
    private var ifEditModeButton: some View {
        HStack {
            Button(action: {
                self.isEditing.toggle()
            }) {
                if self.isEditing {
                    Text("Done")
                } 
            }
        }
    }
    
    @Environment(\.managedObjectContext) private var context
    @State var selection = Set<String>()
    private var editMenu: some View {
        Menu {
            Button(action: {
                if self.isEditing {
                    viewContext.delete(rss)
                    try! viewContext.save()
                }
                self.isEditing.toggle()
                
            }) {
                if self.isEditing {
                    Text("Remove Selected")
                    Image(systemName: "trash")
                } else {
                    Text("Edit")
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle").font(.system(size: 20, weight: .medium, design: .rounded))
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { scrollViewProxy in
                ZStack {
                    List(selection: $selectedCells) {
                        SmartFeedsHomeView(rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), archiveListViewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem), articles: AllArticles(dataSource: DataSourceService.current.rssItem), unread: Unread(dataSource: DataSourceService.current.rssItem))
                        
                        RSSFoldersDisclosureGroup(persistence: Persistence.current, unread: unread, viewModel: self.viewModel, isExpanded: selectedCells.contains(rss))
                            .onTapGesture { self.selectDeselect(rss) }
                    }
                    .environmentObject(DataSourceService.current.rss)
                    .environmentObject(DataSourceService.current.rssItem)
                    .environment(\.managedObjectContext, Persistence.current.context)
                    .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive)).animation(Animation.spring())
//                    .environment(\.editMode, $editMode)
                    .listStyle(PlainListStyle())
//                    .listStyle(SidebarListStyle())
                    .navigationBarTitle("Home", displayMode: .automatic)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            ifEditModeButton
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            editMenu
                        }
                    }
//                    .add(self.searchBar)
                }
                Spacer()
                if addRSSProgressValue > 0 && addRSSProgressValue < 1.0 {
                    LinerProgressBar(lineWidth: 3, color: .blue, progress: $addRSSProgressValue)
                        .frame(width: UIScreen.main.bounds.width, height: 3, alignment: .leading)
                }
                navButtons
                    .frame(width: UIScreen.main.bounds.width, height: 49, alignment: .leading)
                    EmptyView()
            }
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
                } else if FeaureItem.folder == self.selectedFeatureItem {
                    AddGroup { name in
                      addNewGroup(name: name)
                      addGroupIsPresented = false
                    }
                }
            })
        }
//        .onAppear {
//            self.viewModel.fecthResults()
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
    }
}

extension HomeView {
    func delete(rss: RSS) {
        if self.viewModel.items.firstIndex(where: { $0.id == rss.id }) != nil {
            viewModel.delete(rss: rss)
        }
    }
    private func onDoneAction() {
        withAnimation {
            self.viewModel.fecthResults()
        }
    }
    private func selectDeselect(_ group: RSSGroup) {
        print("Selected \(String(describing: group.id))")
    }
    private func selectDeselect(_ rss: RSS) {
        withAnimation {
            if selectedCells.contains(rss) {
                selectedCells.remove(rss)
            } else {
                selectedCells.insert(rss)
            }
        }
    }
    private func addNewGroup(name: String) {
        withAnimation {
            persistence.addNewGroup(name: name)
        }
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static let rss = RSS()
    static let rssItem = RSSItem()
    static let unread = Unread(dataSource: DataSourceService.current.rssItem)
    static let articles = AllArticles(dataSource: DataSourceService.current.rssItem)
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static let persistence = Persistence.current
    
    static var previews: some View {
        HomeView(articles: articles, unread: unread, rssItem: rssItem, viewModel: viewModel, selectedFilter: FilterType.all)
            .environmentObject(DataSourceService.current.rssItem)
            .environment(\.managedObjectContext, Persistence.current.context)
            .preferredColorScheme(.dark)
    }
}
#endif

extension EditMode {

    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}

struct ContentView: View {

    @State var isEditing = false
    @State var selection = Set<String>()

    var names = ["Karl", "Hans", "Faustao"]

    var body: some View {
        NavigationView {
            VStack {
                List(names, id: \.self, selection: $selection) { name in
                    Text(name)
                }
                .navigationBarTitle("Names")
                .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive)).animation(Animation.spring())
                Button(action: {
                    self.isEditing.toggle()
                }) {
                    Text(isEditing ? "Done" : "Edit")
                        .frame(width: 80, height: 40)
                }
                .background(Color.yellow)
            }
            .padding(.bottom)
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
