//
//  HomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/12/20.
//

import SwiftUI
import SwiftUIX
import FeedKit
import KingfisherSwiftUI
import CoreData
import Combine
import SwiftUIRefresh
import SwipeCell

struct DidReselectKey: EnvironmentKey {
    static let defaultValue = PassthroughSubject<TabSelection, Never>().eraseToAnyPublisher()
}

extension EnvironmentValues {
    var didReselect: AnyPublisher<TabSelection, Never> {
        get {
            return self[DidReselectKey.self]
        }
        set {
            self[DidReselectKey.self] = newValue
        }
    }
}

enum TabSelection: String {
    case Hottest, Newest, Settings, Tags
}
/** https://stackoverflow.com/a/64019877/193772 */
struct NavigableTabViewItem<Content: View, TabItem: View>: View {
    @Environment(\.didReselect) var didReselect
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let tabSelection: TabSelection
    let content: Content
    let tabItem: TabItem
    
    init(tabSelection: TabSelection, @ViewBuilder content: () -> Content, @ViewBuilder tabItem: () -> TabItem) {
        self.tabSelection = tabSelection
        self.content = content()
        self.tabItem = tabItem()
    }

    var body: some View {
        let didReselectThis = didReselect.filter( {
            $0 == tabSelection
        }).eraseToAnyPublisher()

        NavigationView {

//            self.content.environmentObject(settings).onReceive(didReselect) { _ in
//                    DispatchQueue.main.async {
//                        self.presentationMode.wrappedValue.dismiss()
//                    }
//                }

            
        }.tabItem {
            self.tabItem
        }
        .tag(tabSelection)
        .navigationViewStyle(StackNavigationViewStyle())
        .environment(\.didReselect, didReselectThis)
    }
}

struct HomeView: View {
    
    @Environment(\.managedObjectContext) var moc
//    @State private var didReselect = PassthroughSubject<TabSelection, Never>()
    @Environment(\.didReselect) var didReselect
    @State var isVisible = false

    @State private var archiveScale: Image.Scale = .medium

    @State private var titleFilter = "A"
        
//    @State private var downloadAmount = 0.0
//    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    var lineWidth: CGFloat = 2
    var color: Color = .blue
//    @Binding var progress: Double
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var rssDataSource: RSSDataSource
    
    //let defaultFeeds: [DefaultFeeds] = Bundle.main.decode("DefaultFeeds.json")
    
    let refreshControl: RefreshControl = RefreshControl()

    enum FeaureItem {
        case add
        case setting
    }
    @State var showSheetView = false
    @State var isRefreshing: Bool = false
    @State var scrollView: UIScrollView?
    @State var refresh = Refresh(started: false, released: false)
    @State private var isShowing = false
    @State var sources: [RSS] = []
    @ObservedObject var searchBar: SearchBar = SearchBar()
//    @ObservedObject var basicListViewController: BasicListViewController
    @ObservedObject var viewModel: RSSListViewModel
    @ObservedObject var archiveListViewModel: ArchiveListViewModel
    @State var rssFeedViewModel: RSSFeedViewModel

    @State private var selectedFeatureItem = FeaureItem.add
    @State private var isAddFormPresented = false
    @State private var isSettingPresented = false
    @State private var isSheetPresented = false
    @State private var addRSSProgressValue = 0.0
    @State private var previewIndex = 0
    @State var isExpanded = false
    @State private var revealDetails = false
    @State private var action: Int?

    //let index : Int

    
    private var cardButton: some View {
        Menu {
            Button(action: {
                print("Starred")
            }, label: {
                HStack{
                    Text("Starred")
                    Image(systemName: "star.fill").font(.system(size: 10, weight: .heavy))
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
                print("All")
            }, label: {
                HStack{
                    Text("All")
                    Image(systemName: "text.justifyleft")
                        //.font(.system(size: 16, weight: .heavy))
                }
            })
        } label: {
            Label(
                title: { Text("")},
                icon: { Image(systemName: "line.horizontal.3.decrease.circle").font(.system(size: 20)) } //.frame(width: 44, height: 44) }
                    
                //Image("filterInactive").font(.system(size: 18, weight: .heavy))
                //Image(systemName: "text.justifyleft").font(.system(size: 18, weight: .heavy))
            )
        }
    }
    private var leadingView: some View {
        HStack(alignment: .top, spacing: 24) {
            //EditButton()
            settingButton
//            addSourceButton
        }
        .foregroundColor(Color("bg"))
    }
//        Button(action: {
//            print("On My iPhone")
//        }) {
//            Image("accountLocalPhone")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 25, height: 35, alignment: .center)
//                .border(Color.clear, width: 2)
//                .cornerRadius(3.0)
//
//        }
//    }
    
    private var settingButton: some View {
        Button(action: {
            self.selectedFeatureItem = .setting
            self.isSheetPresented = true
        }) {
            Image(systemName: "gear")
                .imageScale(.medium)
            //"slider.horizontal.3")
                .frame(width: 44, height: 44, alignment: .trailing)
                //.foregroundColor(Color("bg"))
//                .imageScale(.medium)
//                .font(.system(size: 18, weight: .semibold))
//            Image("toggle")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 25, height: 25)
//                .imageScale(.medium)

        }
    }
    private var addSourceButton: some View {
//            Menu {
                Button(action: {
                    self.isSheetPresented = true
                    self.selectedFeatureItem = .add
                }, label: {
                    //HStack{
                        //Text("Add Feed")
                        Image(systemName: "plus")
                            
                            //.foregroundColor(Color("bg"))
                            .imageScale(.medium)
//                            .font(.system(size: 20, weight: .semibold))
                            .frame(width: 44, height: 44, alignment: .trailing)
                        
                })
                
//                Button(action: {
//                    print("Add Folder")
//                }, label: {
//                    HStack{
//                        Text("Add Folder")
//                        Image(systemName: "folder").font(.system(size: 16, weight: .heavy))
//                    }
//                })
//            } label: {
//                Label(
//                    title: { Text("")},
//                    icon: { Image(systemName: "plus")
//                        .imageScale(.large)
//                    }
//                )
//            }
//        }
    }


    private var archiveListView: some View {
        ArchiveListView(viewModel: archiveListViewModel, rssFeedViewModel: self.rssFeedViewModel)
    }

//    private var archiveButton: some View {
//        Button(action: {
//            self.action = 1
//        }) {
//            Image(systemName: "archivebox.fill")
//                .imageScale(.medium)
//        }
//    }
    
    private var trailingView: some View {
        HStack(alignment: .top, spacing: 24) {
            //EditButton()
            settingButton
            Spacer()
            addSourceButton
                .accentColor(Color("darkShadow"))
        }.padding(24)
    }
    
    private var feedView: some View {
        HStack{
//            Image("3icon")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 25, height: 25, alignment: .center)
//                .border(Color.clear, width: 3)
//                .cornerRadius(5.0)
////            (systemName: "archivebox").font(.system(size: 16, weight: .bold))
//                .foregroundColor(Color("bg"))
//                .imageScale(.large)
            Text("All Items")
                .font(.system(size: 17, weight: .medium, design: .rounded))                //.font(.headline)
//            Spacer()
//            Text("\(viewModel.items.count)")
        }
    }
    
    private var unreadCount: some View {
        UnreadCountView(count: viewModel.items.count)
    }
    
    private var feedSection: some View {
        HStack{
            Image("3icon") //faviconTemplateImage") //accountLocalPhone")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20, alignment: .center)
                .cornerRadius(5.0)
                .foregroundColor(Color("bg"))
             Text("Feeds") //.font(.system(size: 18, weight: .semibold))
                .font(.system(size: 16, weight: .semibold))
                .fontWeight(.semibold)
                .foregroundColor(Color("bg"))
            Spacer()
            unreadCount
//            Text("\(viewModel.items.count)")
//                .font(.footnote)
         }
     }
    
    private var feedsAll: some View {
        HStack{
            //DisclosureGroup("On My iPhone", isExpanded: $revealDetails) {
//            Image("accountLocalPhone")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 30, height: 30, alignment: .center)
//                .foregroundColor(Color("bg"))
            Text("Feeds")
                .font(.system(size: 17, weight: .medium, design: .rounded))                //.font(.headline)
            Spacer()
            unreadCount
        }
    }
    
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
//        Text("Last Sync: ")
//            .foregroundColor(Color("bg"))
//            .fontWeight(.bold)
//            .font(.system(size: 16, weight: .medium, design: .rounded)) + Text(Date(), style: .time)
//            .font(.system(size: 15, weight: .medium, design: .rounded))
//            .fontWeight(.bold)
//            .foregroundColor(Color("bg"))

    }
//    private var infoListView: some View {
//        Button(action: {
//            self.showingInfo = true
//            }) {
//            Text("Feed Info")
//            Image(systemName: "info.circle")
//            }.sheet(isPresented: $showingInfo) {
//                InfoView(rssViewModel: rssFeedViewModel)
//        }
//    }
    
    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @State private var showingInfo = false
    
    @State private var isLoading = false
    var animation: Animation {
        Animation.linear
    }

    struct LoadingButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color("bg"))
                .multilineTextAlignment(.center)
                .frame(width: 44, height: 44)
                .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
        }
    }
    
  var body: some View {
    NavigationView {
        List {
            VStack(alignment: .leading){
                VStack{
                    Image(systemName: "icloud").foregroundColor(Color("bg"))
                }.listRowBackground(Color("accent"))
                    Text("On My iPhone").font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Color("bg"))
                        .multilineTextAlignment(.leading)
                    Text("Today at ").font(.system(size: 16, weight: .medium, design: .rounded)) + Text(Date(), style: .time)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .fontWeight(.bold)
                }.listRowBackground(Color("accent"))
            Section(header: feedView) {
                NavigationLink(destination: DataNStorageView()) {
                    TagView()
                    Spacer()
                }
                NavigationLink(destination: archiveListView) {
                    BookmarkView()
                    Spacer()
                    Text("\(self.archiveListViewModel.items.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 1)
                        .foregroundColor(Color("darkShadow"))
                        .cornerRadius(8)
                }
                .onAppear {
                    self.archiveListViewModel.fecthResults()
                }
            }
            .textCase(nil)
            .accentColor(Color("darkShadow"))
            .foregroundColor(Color("darkerAccent"))
            .listRowBackground(Color("accent"))
            .edgesIgnoringSafeArea(.all)
            Section(header: feedsAll) {
                ForEach(viewModel.items, id: \.self) { rss in
                    NavigationLink(destination: self.destinationView(rss: rss)) {
                        RSSRow(rss: rss)
//                            if RSSRow.viewModel.items.count <= 0 {
//                            Text("\(RSSRow.viewModel.items.count)")
//                                .font(.caption)
//                                .fontWeight(.bold)
//                                .padding(.horizontal, 7)
//                                .padding(.vertical, 1)
//                                .foregroundColor(Color("darkShadow"))
//                                .cornerRadius(8)
//                            } else {
//                                EmptyView()
//                            }
                    }
                    .tag("RSS")
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        self.viewModel.delete(at: index)
                        }
                    }
                .onMove(perform: moveRow)
                }
                .textCase(nil)
                .listRowBackground(Color("accent"))
                .accentColor(Color("darkShadow"))
                .foregroundColor(Color("darkerAccent"))
                .edgesIgnoringSafeArea(.all)
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
                SettingView()
        }
        })
        .toolbar {
            #if os(iOS)
            ToolbarItem {
                //loadMore
            }
            #endif
            ToolbarItem(placement: .bottomBar) {
                settingButton
            }
            ToolbarItem(placement: .status) {
                //Spacer()
                lastSync
            }
            ToolbarItem(placement: .bottomBar) {
                addSourceButton
            }
        }.listRowBackground(Color("accent"))
            if addRSSProgressValue > 0 && addRSSProgressValue < 1.0 {
                LinerProgressBar(lineWidth: 3, color: .blue, progress: $addRSSProgressValue)
                    .frame(width: UIScreen.main.bounds.width, height: 3, alignment: .leading)
            }
        }
        .onAppear {
            self.viewModel.fecthResults()
        }
//        .navigationBarItems(.trailing: Button(action: self.archiveListViewModel.loadMore) {
//                            //self.isLoading.toggle()
//        //                    self.archiveListViewModel.loadMore()
//        //                }) {
//                            Image(systemName: "arrow.counterclockwise")
//                                .rotationEffect(.degrees(isLoading ? 360 : 0))
//                                .animation(animation)
//                                .onAppear {
//                                    self.isLoading.toggle()
//                                }
//                        }.buttonStyle(LoadingButtonStyle()))
        .accentColor(Color("darkShadow"))
    }
}

struct BookmarkView: View {
    var body: some View {
        VStack(alignment: .trailing) {
            HStack{
                Image(systemName: "star.fill").font(.system(size: 16, weight: .black)).foregroundColor(Color("bg"))
                Text("Starred")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(Color("text"))
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

    func moveRow(from indexes: IndexSet, to destination: Int) {
        if let first = indexes.first {
            viewModel.items.insert(viewModel.items.remove(at: first), at: destination)
            return
        }
    }
    
    private func destinationView(rss: RSS) -> some View {
        RSSFeedListView(rssViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
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
    static let rssFeedViewModel = RSSFeedViewModel(rss: RSS.simple(), dataSource: DataSourceService.current.rssItem)
    
    static var previews: some View {
        HomeView(viewModel: self.viewModel, archiveListViewModel: self.archiveListViewModel, rssFeedViewModel: self.rssFeedViewModel)
            .preferredColorScheme(.dark)
    }
}

struct UnreadCountView: View {
//struct UnreadCountView<Content: View>: View {
//    let unreadCount: () -> Content
//    init(_ unreadCount: @autoclosure @escaping () -> Content) {
//        self.unreadCount = unreadCount
//    }
//    var body: Content {
//        unreadCount()
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
//if viewModel.items.count <= 0 {
//    ForEach(1..<10) { _ in
//        HStack{
//            RSSRow(rss: rss)
//            Text("\(self.viewModel.items.count)")
//                    .font(.caption)
//                    .fontWeight(.bold)
//                    .padding(.horizontal, 7)
//                    .padding(.vertical, 1)
//                    .foregroundColor(Color("darkShadow"))
//                    .cornerRadius(8)
//        }
//    }
//}
