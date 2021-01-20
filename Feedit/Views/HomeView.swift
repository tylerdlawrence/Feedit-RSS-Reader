//
//  HomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/12/20.
//

import SwiftUI
import UIKit
import FeedKit
import KingfisherSwiftUI
import CoreData
import Combine
import SwipeCell

extension View {
    func phoneOnlyStackNavigationView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return AnyView(self.navigationViewStyle(StackNavigationViewStyle()))
        } else {
            return AnyView(self)
        }
    }
}

extension View {
  func background(with color: Color) -> some View {
    background(GeometryReader { geometry in
      Rectangle().path(in: geometry.frame(in: .local)).foregroundColor(color)
    })
  }
}

struct HomeView: View {
    
//    @EnvironmentObject var modelData: ModelData
//    @State private var showFavoritesOnly = false
//    var filteredFeeds: [RSS] {
//        viewModel.items.filter { rss in
//            (!showFavoritesOnly || rss.isFavorite)
//        }
//    }
    
//    @FetchRequest(
//      entity: RSS.entity(),
//      sortDescriptors: [NSSortDescriptor(key: "url", ascending: true)]
//    ) var items: FetchedResults<RSS>
    
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var rssDataSource: RSSDataSource
//    @EnvironmentObject var articles: AllArticlesStorage
    @Environment(\.managedObjectContext) var moc
//    @EnvironmentObject var viewModel: RSSListViewModel
//    @EnvironmentObject var rssFeedViewModel: RSSFeedViewModel
//    @EnvironmentObject var archiveListViewModel: ArchiveListViewModel
    
//    @ObservedObject var articles: AllArticlesStorage
    @ObservedObject var viewModel: RSSListViewModel
    @ObservedObject var archiveListViewModel: ArchiveListViewModel
    @State var rssFeedViewModel: RSSFeedViewModel
    @State var editMode = EditMode.inactive
    @State var selection = Set<String>()
    @State private var archiveScale: Image.Scale = .small
    @State var showSheetView = false
    @State var scrollView: UIScrollView?
    @State private var isShowing = false
    @State var sources: [RSS] = []
    @State private var selectedFeatureItem = FeaureItem.add
    @State private var isAddFormPresented = false
    @State private var isSettingPresented = false
    @State private var isSheetPresented = false
    @State private var addRSSProgressValue = 1.0
    @State private var previewIndex = 0
    @State var isExpanded = false
    @State private var revealDetails = false
    @State private var revealFeeds = false
    @State private var action: Int?
    @State private var tapped: Bool = false
    @State private var showingDetail = false
    @State private var showInfoSheet = false
    enum FeaureItem {
        case add
        case setting
    }
    


    private var filterButton: some View {
        Menu {
            Button(action: {
//                ZStack {
//
//                    if selectedFilter == .all {
//                        RoundedRectangle(cornerRadius: 5)
//                        .foregroundColor(Color.backgroundNeo)
//                    } else {
//                        RoundedRectangle(cornerRadius: 5)
//                        .foregroundColor(Color.backgroundNeo)
//                    }
//                    Image(systemName: "text.justifyleft").font(.system(size: 16, weight: .black))
//                }
//                .padding()
//                .onTapGesture {
//                    self.selectedFilter = .all
//                }
            }, label: {
                HStack{
                    Text("All")
                    Image(systemName: "text.justifyleft")
                        //.font(.system(size: 16, weight: .heavy))
                }
            })
            Button(action: {
                print("Unread")
            }, label: {
                HStack{
                    Text("Unread")
                    Image("unread-action").font(.system(size: 10, weight: .heavy))
                }
            })
            Button(action: {
                print("Starred")
            }, label: {
                HStack{
                    Text("Starred")
                    Image(systemName: "star.fill").font(.system(size: 10, weight: .heavy))
                }
            })
        } label: {
            Label(
                title: { Text("")},
                icon: { Image(systemName: "line.horizontal.3.decrease.circle").foregroundColor(Color("bg")).font(.system(size: 20)) }
            )
        }
    } // filter menu
    
    private var centerView: some View {
        HStack(spacing: 60) {
            settingButton
            lastSync
            addSourceButton
        }
        .foregroundColor(Color("bg"))
    } // bottom nav bar
    private var settingButton: some View {
        Button(action: {
            self.selectedFeatureItem = .setting
            self.isSheetPresented = true
        }) {
            Image(systemName: "gear").font(.system(size: 18, weight: .medium, design: .rounded))
//                .frame(width: 44, height: 44, alignment: .trailing)
        }
    } // settings button
    private var addSourceButton: some View {
        Button(action: {
            self.isSheetPresented = true
            self.selectedFeatureItem = .add
        }, label: {
            HStack {
                Image(systemName: "plus").font(.system(size: 18, weight: .medium, design: .rounded))
            }
            .foregroundColor(Color("bg"))
//            .frame(width: 44, height: 44, alignment: .trailing)
        })
    } // add feed button
    private var archiveListView: some View {
        ArchiveListView(viewModel: archiveListViewModel, rssFeedViewModel: self.rssFeedViewModel)
    } // starred nav view
    
    private var headlineView: some View {
        VStack(alignment: .leading) {
//            HStack {
////                Spacer(minLength: 20)
//                Image(systemName: "icloud").font(.system(size: 24, weight: .heavy, design: .rounded)).foregroundColor(Color("bg"))
//            }
            HStack {
                Text("On My iPhone").font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(Color("text"))
                    .multilineTextAlignment(.leading)
            }
            HStack {
                Text("Today at ").foregroundColor(Color("bg")).font(.system(size: 16, weight: .medium, design: .rounded)) + Text(Date(), style: .time).foregroundColor(Color("bg"))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                    .fontWeight(.bold)
            }
//            Divider()
        }
//        .padding([.top, .leading, .trailing], 20.0)
        .accentColor(Color("darkShadow"))
        .foregroundColor(Color("darkerAccent"))
        .listRowBackground(Color("accent"))
    }
    
    private var trailingView: some View {
        HStack(alignment: .top, spacing: 24) {
            settingButton
            Spacer()
            addSourceButton
                .accentColor(Color("bg"))
        }.padding(24)
    } // bottom nav bar format
    private var feedView: some View {
        HStack{
            Text("All Items")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .fontWeight(.regular)
            Spacer()
            //unreadCount
            //Text("\(viewModel.items.count)")
        }
    } // "All Items" section header
    private var unreadCount: some View {
        UnreadCountView(count: viewModel.items.count)
    } // unread count format
    
    private var allArticles: some View {
        HStack{
//            Image(systemName: "plus").font(.system(size: 10, weight: .black, design: .rounded)).foregroundColor(Color("bg"))
            Text("All Articles")
                .font(.system(size: 18, weight: .regular, design: .rounded))
//            Spacer()
//            unreadCount
        }
    } // "All Articles" section header
    
    private var feedsAll: some View {
        HStack{
//            Image(systemName: "plus").font(.system(size: 10, weight: .black, design: .rounded)).foregroundColor(Color("bg"))
            Text("Feeds")
                .font(.system(size: 18, weight: .regular, design: .rounded))
            Spacer()
            //unreadCount
            Text("\(viewModel.items.count)")
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 7)
                .padding(.vertical, 1)
                .background(Color("Color"))
                .opacity(0.4)
                .foregroundColor(Color("text"))
                .cornerRadius(8)
        }
    } // "Feeds" section header
    private var lastSync: some View {
        HStack {
            Text("Last Sync ")
                .fontWeight(.bold)
                .foregroundColor(Color("lightShadow"))
                .font(.system(.footnote)) +
                Text(Date(), style: .time)
                .font(.system(.footnote))
                .fontWeight(.bold)
                .foregroundColor(Color("lightShadow"))
        }
    } // last sync nav bar header
    
    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }

    private func delete(rss: RSS) {
        if let index = self.viewModel.items.firstIndex(where: { $0.id == rss.id }) {
            viewModel.items.remove(at: index)
//            viewModel.items.remove(atOffsets: offsets)
            
//            func delete(at index: Int) {
//                let object = items[index]
//                dataSource.delete(object, saveContext: true)
//                items.remove(at: index)
//            }
        }
    }
    @State private var showSheet = false
    @State private var bookmark = false
    @State private var unread = false
    @State private var showAlert = false
    
//    @State var selectedFilter: FilterType
//    @State var showFilter: Bool
//    var markedAllPostsRead: (() -> Void)?

  var body: some View {
    let button1 = SwipeCellButton(
        buttonStyle: .image,
        title: "Mark",
        systemImage: "bookmark",
        titleColor: .white,
        imageColor: .white,
        view: nil,
        backgroundColor: .green,
        action: { bookmark.toggle() },
        feedback: true
    )
    let editInfo = SwipeCellButton(
        buttonStyle: .image,
        title: "",
        systemImage: "rectangle.and.pencil.and.ellipsis",
        view: nil,
        backgroundColor: .gray,
        action: { showSheet.toggle() }
    )
    let button3 = SwipeCellButton(
        buttonStyle: .view,
        title: "",
        systemImage: "",
        view: {
            AnyView(
                Group {
                    if unread {
                        Image(systemName: "largecircle.fill.circle")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                    else {
                        Image(systemName: "circle")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                }
            )
        },
        backgroundColor: Color("footnoteColor"),
        action: { unread.toggle() },
        feedback: false
    )

    let deleteButton = SwipeCellButton(
        buttonStyle: .image,
        title: "",
        systemImage: "trash",
        titleColor: .white,
        imageColor: .white,
        view: nil,
        backgroundColor: .red,
        action: {
            showAlert.toggle()
            deleteItems(at: IndexSet())
            
        },
        feedback: true
    )
    let slot3 = SwipeCellSlot(slots: [editInfo, deleteButton], slotStyle: .destructive, buttonWidth: 50)
    NavigationView{
        List{
            headlineView
//            LazyVStack(alignment: .leading){
////                Spacer()
//                Image(systemName: "icloud").font(.system(size: 24, weight: .heavy, design: .rounded)).foregroundColor(Color("bg"))
//                Text("On My iPhone").font(.system(size: 24, weight: .heavy, design: .rounded))
//                    .foregroundColor(Color("text"))
//                    .multilineTextAlignment(.leading)
//                Text("Today at ").foregroundColor(Color("bg")).font(.system(size: 16, weight: .medium, design: .rounded)) + Text(Date(), style: .time).foregroundColor(Color("bg"))
//                    .font(.system(size: 15, weight: .medium, design: .rounded))
//                    .fontWeight(.bold)
////                Spacer()
////                    .padding(.all)
////                    Divider().padding(0).padding([.leading])
//            }
//            .listRowBackground(Color("accent"))
//            .frame(alignment: .topLeading)
////            .frame(width: 370)
//            .border(Color.clear, width: 0)

// all items section - archive - starred
//            Section(header: feedView) {
//                NavigationLink(destination: DataNStorageView()) {
//                    TagView()
//                    Spacer()
//                }
//                NavigationLink(destination: archiveListView) {
//                    BookmarkView()
//                    Spacer()
//                    Text("\(self.archiveListViewModel.items.count)")
//                        .font(.caption)
//                        .fontWeight(.bold)
//                        .padding(.horizontal, 7)
//                        .padding(.vertical, 1)
//                        .foregroundColor(Color("darkShadow"))
//                        .cornerRadius(8)
//                }
//                .onAppear {
//                    self.archiveListViewModel.fecthResults()
//                }
//            }


                
            
            
            DisclosureGroup(
                isExpanded: $revealDetails,
                content: {
                    NavigationLink(destination: DataNStorageView()) {
                        TagView()
                        Spacer()
                    }

                    NavigationLink(destination: archiveListView) {
                        BookmarkView()
                        Spacer()
                        Text("\(self.archiveListViewModel.items.count)")
//                            .font(.system(size: 18, weight: .regular, design: .rounded))
        
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 1)
                            .background(Color("Color"))
                            .opacity(0.4)
                            .foregroundColor(Color("text"))
                            .cornerRadius(8)

                    }
                    .onAppear {
                        self.archiveListViewModel.fecthResults()
                    }
                },
                label: {
                    HStack {
                        feedView
                    }
                })
                .textCase(nil)
//                .accentColor(Color("tab"))
//                .foregroundColor(Color("darkerAccent"))
//                .listRowBackground(Color("tab"))
                .accentColor(Color("darkShadow"))
                .foregroundColor(Color("darkerAccent"))
                .listRowBackground(Color("accent"))
//                .listRowBackground(Color("footnoteColor"))
//                .edgesIgnoringSafeArea(.all)
            
// feeds section
//            Section(header: feedsAll) {
//                ForEach(viewModel.items, id: \.self) { rss in
//                    NavigationLink(destination: self.destinationView(rss: rss)) {
//                        RSSRow(rss: rss)
//                    }
//                    .tag("RSS")
//                }
//                .onDelete { indexSet in
//                    if let index = indexSet.first {
//                        self.viewModel.delete(at: index)
//                        }
//                    }
//            }
//                }
//            }
            

            
            DisclosureGroup(
                isExpanded: $revealFeeds,
                content: {
//                    ScrollView{
                    ForEach(viewModel.items, id: \.self) { rss in
                            NavigationLink(destination: self.destinationView(rss: rss)) {
                                    RSSRow(rss: rss)
                                        //Spacer()
                                        .padding(.trailing)
                                    Text("\(rssFeedViewModel.items.count)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 1)
                                        .background(Color("darkShadow"))
                                        .opacity(0.4)
                                        .foregroundColor(Color("text"))
                                        .cornerRadius(8)
//                                Text("\(viewModel.items.filter { !$0.isRead }.count)")
//                                Text("\(self.viewModel.items.filter { !$0.isRead }.self.count)")

                                        .contextMenu {
                                            Button(action: {
                                                // delete the selected feed
                                                self.delete(rss: rss)
                                            }) {
                                                HStack {
                                                    Text("Delete")
                                                    Image(systemName: "trash")
                                                }
                                            }
                                        }
                                }
//                        .frame(width: 0)
//                        .opacity(0)
                        .tag("RSS")
                        }
                        .onDelete { indexSet in
                            if let index = indexSet.first {
                                self.viewModel.delete(at: index)
                                }
                            }
//                    }
                },
                label: {
                    HStack {
                        feedsAll
                    }
                })
                .textCase(nil)
                .listRowBackground(Color("accent"))
                .accentColor(Color("darkShadow"))
                .foregroundColor(Color("darkerAccent"))
                .edgesIgnoringSafeArea(.all)
        } // list
//        .zIndex(.infinity)
//        .listStyle(SidebarListStyle())
        .listStyle(PlainListStyle())
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(leading:
            HStack {
                Image(systemName: "icloud").font(.system(size: 20, weight: .heavy, design: .rounded)).foregroundColor(Color("bg"))
            },trailing: filterButton)//,trailing: EditButton())

// bottom navigation bar
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                settingButton
            }
            ToolbarItem(placement: .status) {
                lastSync
            }
            ToolbarItem(placement: .bottomBar) {
                addSourceButton
            }
        }
    }

//    .zIndex(.infinity)
    //.padding(.trailing, -30.0)
    //navigation view
//    .introspectNavigationController { navigationController in
//        navigationController.navigationBar.backgroundColor = UIColor(Color("accent"))
//    }
//    .navigationViewStyle(DoubleColumnNavigationViewStyle())
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
            SettingView()
    }
    })
    .onAppear {
            self.viewModel.fecthResults()
//            self.viewModel.getRSSItemCount()
    }
//color of nav bar buttons
    .accentColor(Color("darkShadow"))

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

struct BookmarkView: View {
    var body: some View {
        VStack(alignment: .trailing) {
            HStack{
                Image(systemName: "star.fill").font(.system(size: 16, weight: .black)).foregroundColor(Color("bg"))
                Text("Starred")

//                    .font(.system(size: 17, weight: .medium, design: .rounded))
//                    .foregroundColor(Color("text"))
            }
        }
    }
}
struct TagView: View {
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Image(systemName: "archivebox.fill").font(.system(size: 16, weight: .black)).foregroundColor(Color("bg"))
                Text("Archive")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(Color("text"))
            }
        }
    }
}
struct UnreadCountView: View {
    var count: Int
    var body: some View {
        Text(verbatim: String(count))
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 7)
            .padding(.vertical, 1)
            .foregroundColor(Color("darkShadow"))
            .cornerRadius(8)
    }
}

extension HomeView {
    
    func onDoneAction() {
        self.viewModel.fecthResults()
    }

    func moveRow(from indexes: IndexSet, to destination: Int) {
        if let first = indexes.first {
            viewModel.items.insert(viewModel.items.remove(at: first), at: destination)
            return
        }
    }
    
    private func destinationView(rss: RSS) -> some View {
        RSSFeedListView(withURL: "", rssViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
            .environmentObject(DataSourceService.current.rss)
    }
    
    func deleteItems(at offsets: IndexSet) {
        viewModel.items.remove(atOffsets: offsets)
    }
    
}
struct HomeView_Previews: PreviewProvider {
//    static let articles = AllArticlesStorage(managedObjectContext: Persistence.current.context)

    static let current = DataSourceService()
    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static let rssFeedViewModel = RSSFeedViewModel(rss: RSS(context: Persistence.current.context), dataSource: DataSourceService.current.rssItem)

    static var previews: some View {
        HomeView(viewModel: self.viewModel, archiveListViewModel: self.archiveListViewModel, rssFeedViewModel: self.rssFeedViewModel)
            .preferredColorScheme(.dark)
    }
}
//articles: self.articles,
