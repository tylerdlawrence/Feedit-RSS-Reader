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

struct HomeView: View {
    
    @Environment(\.managedObjectContext) var moc
    
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
    
//    private var folderSection: some View {
//        VStack{
//            HStack{
//                //Image("disclosure")
//                Text("Folders").font(.system(size: 18, weight: .semibold))
//            }
//        }
//    }
    
//    private var defaultFeedSection: some View {
//        HStack{
//            Image(systemName: "chevron.right").font(.system(size: 10, weight: .heavy))
//                .foregroundColor(Color("bg"))
//                .imageScale(.large)
//            Text("Default Feeds")
//            Spacer()
//            Text("\(defaultFeeds.count)")
//                .font(.footnote)
//        }
//    }
    
    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @State private var showingInfo = false
    
  var body: some View {
    NavigationView {
        
        List {

//            HStack(alignment: .top){
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
//                VStack(alignment: .center){
//                    Image(systemName: "icloud")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .foregroundColor(Color("bg"))
//                        .frame(width: 75, height: 75)
////                    Text("On My iPhone")
////                        .font(.title3)
////                        .fontWeight(.bold)
//                    Text("Today at ").font(.system(size: 16, weight: .medium, design: .rounded)) +
//                        Text(Date(), style: .time)
//                        .font(.system(size: 15, weight: .medium, design: .rounded))
//                        .fontWeight(.bold)
//
//                }.frame(width: 320.0).listRowBackground(Color("accent"))
                
            }.listRowBackground(Color("accent"))

                        
            Section(header: feedView) {
//                NavigationLink(destination: feedSection) {
//                    RSSFeedListView
//                }
//            DisclosureGroup("On My iPhone", isExpanded: $revealDetails) {
//                ForEach(viewModel.items, id: \.self) { rss in
//                    NavigationLink(destination: self.destinationView(rss: rss)) {
//                                        RSSRow(rss: rss)
//                                        }
//                                        .tag("RSS")
//                                }
//                                .padding(.leading)
//                            }
                NavigationLink(destination: DataNStorageView()) { //Tag.demoTags.randomElement()!) {
                    TagView()
                    Spacer()
                    //UnreadCountView(Text("items: \(content)"))
                    //UnreadCountView(count: DataNStorageView.count) //Tag.demoTags.count)
                }
                NavigationLink(destination: archiveListView) {
                    BookmarkView()
                    Spacer()
                    UnreadCountView(count: self.archiveListViewModel.items.count)
                }

            }
            .textCase(nil)
            .accentColor(Color("darkShadow"))
            .foregroundColor(Color("darkerAccent"))
            .listRowBackground(Color("accent"))
            .edgesIgnoringSafeArea(.all)

            Section(header: feedsAll) {
//            DisclosureGroup("", isExpanded: $revealDetails) {
//                ScrollView {
                ForEach(viewModel.items, id: \.self) { rss in
                    NavigationLink(destination: self.destinationView(rss: rss)) {
                        HStack{
                        RSSRow(rss: rss)
//                            .contextMenu {
//                                Button(action: {
//                                    self.showingInfo = true
//                                    }) {
//                                    Text("Get Info")
//                                    Image(systemName: "info.circle")
//                                    }.sheet(isPresented: $showingInfo) {
//                                        InfoView()
//                                        }
//                                
//                                Button(action: {
//                                    // change country setting
//                                }) {
//                                    Text("Copy Feed URL")
//                                    Image(systemName: "doc.on.doc")
//                                }
//
//                                Button(action: {
//                                    // enable geolocation
//                                }) {
//                                    Text("Mark All As Read")
//                                    Image("unread-action")
//                                }
//                            }
                        }
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
//            }
                .textCase(nil)
                .listRowBackground(Color("accent"))
                .accentColor(Color("darkShadow"))
                .foregroundColor(Color("darkerAccent"))
                .edgesIgnoringSafeArea(.all)
            .pullToRefresh(isShowing: $isShowing) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isShowing = false
                }
            }
//            Section(header: folderSection) {
//                Section(header: defaultFeedSection) {
//                    ForEach(viewModel.items, id: \.self) { rss in
//                        NavigationLink(destination: self.destinationView(rss)) {
//                            RSSRow(rss: rss) //TODO: make DefaultFeedRow
//                        }
//                        .padding(.leading)
//                        .tag("diplayName")
//                    }
//                }
//                 //;
////                NavigationLink(destination: Text("News Folder")) {
////                    HStack{
////                        Image(systemName: "chevron.right").font(.system(size: 10, weight: .heavy))
////                            .foregroundColor(Color("bg"))
////                            .imageScale(.large)
////                        Text("News")
////                    }
////                };
////                NavigationLink(destination: Text("Blogs Folder")) {
////                    HStack{
////                        Image(systemName: "chevron.right").font(.system(size: 10, weight: .heavy))
////                            .foregroundColor(Color("bg"))
////                            .imageScale(.large)
////                        Text("Blogs")
////                    }
////                };
////                NavigationLink(destination: Text("Entertainment Folder")) {
////                    HStack{
////                        Image(systemName: "chevron.right").font(.system(size: 10, weight: .heavy))
////                            .foregroundColor(Color("bg"))
////                            .imageScale(.large)
////                        Text("Entertainment")
////                    }
////                };
////                NavigationLink(destination: Text("Technology Folder")) {
////                    HStack{
////                        Image(systemName: "chevron.right").font(.system(size: 10, weight: .heavy))
////                            .foregroundColor(Color("bg"))
////                            .imageScale(.large)
////                        Text("Technology")
////                    }
////                }
//            }
//            .textCase(nil)
//            .accentColor(Color("darkShadow"))
//            .foregroundColor(Color("darkerAccent"))
//            .listRowBackground(Color("accent"))
//            .edgesIgnoringSafeArea(.all)
//            if addRSSProgressValue > 0 && addRSSProgressValue < 1.0 {
//                LinerProgressBar(lineWidth: 3, color: .blue, progress: $addRSSProgressValue)
//                    .padding(.top, 2)
//            }
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
//    .listStyle(PlainListStyle())
//    .listStyle(InsetGroupedListStyle())
        //.navigationViewStyle(DoubleColumnNavigationViewStyle())
        .navigationTitle("") 
        //.add(self.searchBar)
        .navigationBarItems(trailing: EditButton()) //leading: cardButton, 
         //Color("bg"))
//leading: leadingView,
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                settingButton
//                trailingView
//                    .frame(width: UIScreen.main.bounds.width, height: 49, alignment: .leading)

            }
//
            ToolbarItem(placement: .bottomBar) {
                Spacer()
//
            }
            ToolbarItem(placement: .bottomBar) {
                addSourceButton
////                Button(action: self.rssFeedViewModel.loadMore) {
////                    Image(systemName: "arrow.counterclockwise")
////                }
            }
        }.listRowBackground(Color("accent"))
        //Spacer()
//        if addRSSProgressValue > 0 && addRSSProgressValue < 1.0 {
//            LinerProgressBar(lineWidth: 3, color: .blue, progress: $addRSSProgressValue)
//                .frame(width: UIScreen.main.bounds.width, height: 3, alignment: .leading)
//        }
        
//        .toolbar {
////            ToolbarItem(placement: .bottomBar) {
////                Spacer()
////            }
//            ToolbarItem(placement: .bottomBar) {
//                Spacer()
//                    }
//            ToolbarItem(placement: .bottomBar) {
//                //Spacer()
//                //cardButton
//
////                settingButton
//            }
//
//                }
            }
    .accentColor(Color("darkShadow")) //Color("bg"))
            .onAppear {
                self.viewModel.fecthResults()
//                self.isRefreshing = true
//                self.refresh()
//                self.refreshControl.onValueChanged = {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                        self.refreshControl.refreshControl?.endRefreshing()
//                    }
                }
//            }
    
    }
}

struct BookmarkView: View {
    var body: some View {
        VStack(alignment: .trailing) { //(alignment: .leading){
            HStack{
//                Image(systemName: "star.fill")
//                    .imageScale(.medium)
                Image(systemName: "star.fill").font(.system(size: 16, weight: .black)).foregroundColor(.yellow)
//                    .foregroundColor(.yellow)
//                Image("star")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 15, height: 15, alignment: .center)
                Text("Starred")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
//                    .font(.headline) //.system(size: 16, weight: .semibold))
//                    .fontWeight(.semibold)
                    .foregroundColor(Color("bg"))
            }
        }
    }
}

struct TagView: View {
    var body: some View {
        VStack(alignment: .leading){
            HStack{

                Image(systemName: "archivebox.fill").font(.system(size: 16, weight: .black)).foregroundColor(Color("text"))
                    //.imageScale(.medium)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 15, height: 15, alignment: .center)
                Text("Archive")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
//                    .font(.headline) //.system(size: 16, weight: .semibold))
//                    .fontWeight(.semibold)
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

    func moveRow(from indexes: IndexSet, to destination: Int) {
        if let first = indexes.first {
            viewModel.items.insert(viewModel.items.remove(at: first), at: destination)
        }
    }
    
    private func destinationView(rss: RSS) -> some View {
        RSSFeedListView(rssViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem)) //, basicListViewController: basicListViewController) //, showSheetView: self.showSheetView)
            .environmentObject(DataSourceService.current.rss)
    }
//    private func destinationFolderView(_ rss: RSS) -> some View {
//        RSSFeedListView(rssViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), showSheetView: Bool)
//            .environmentObject(DataSourceService.current.rss)
//    }
    func deleteItems(at offsets: IndexSet) {
        viewModel.items.remove(atOffsets: offsets)
    }
}

struct HomeView_Previews: PreviewProvider {


    static let current = DataSourceService()
    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static let rssFeedViewModel = RSSFeedViewModel(rss: RSS.simple(), dataSource: DataSourceService.current.rssItem)
    //static let basicListViewController = BasicListViewController()
    static var previews: some View {
        //ZStack {
            //Color(.systemBackground)
        HomeView(viewModel: self.viewModel, archiveListViewModel: self.archiveListViewModel, rssFeedViewModel: self.rssFeedViewModel)
            .preferredColorScheme(.dark)
//            HomeView(viewModel: self.viewModel, archiveListViewModel: self.archiveListViewModel, rssFeedViewModel: self.rssFeedViewModel)
        //}
        //basicListViewController: self.basicListViewController,
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
//            .background(Color("darkShadow")) //accent")) //darkShadow"))
            .foregroundColor(Color("darkShadow"))
            .cornerRadius(8)
    }
}

