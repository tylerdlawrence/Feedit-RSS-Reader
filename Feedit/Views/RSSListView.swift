//
//  RSSListView.swift
//  Feedit
//
//  Created by Tyler Lawrence on 10/22/20
//


import SwiftUI

struct RSSListView: View {
    
    enum FeatureItem {
        case remove
        case move
    }
    
    enum FeaureItem {
        case add
    }
    
    @ObservedObject var viewModel: RSSListViewModel
    @State private var revealDetails = false
    @State private var selectedFeaureItem = FeaureItem.add
    @State private var selectedFeatureItem = FeatureItem.remove
    @State private var isAddFormPresented = false
    @State private var isSheetPresented = false
    @State private var addRSSProgressValue = 0.0
    @State var sources: [RSS] = []
    @State var isEditing = false
    
    private var addSourceButton: some View {
        Button(action: {
            self.isSheetPresented = true
            self.selectedFeaureItem = .add
        }) {
            Image(systemName: "plus")
                .padding(.trailing, 0)
                .imageScale(.large)
        }
    }
    
    private var ListView: some View {
        HStack(alignment: .top, spacing: 24) {
            addSourceButton
        }
    }

    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))
                
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items, id: \.self) { rss in
                    NavigationLink(destination: self.destinationView(rss)) {
                        RSSRow(rss: rss)

                    }
//                    .onMove { (indexSet, index) in
//                        self.listItems.move(fromOffsets: indexSet, toOffset: index)
                            
                    .tag("RSS")
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        self.viewModel.delete(at: index)
                    }
                }
            }
//            return NavigationView {
//                List() {
//                    ForEach(viewModel.items) { rss in
//                        NavigationLink(destination: self.RSSListView(rss: rss),
//                                   isActive: $viewModel.isRead)
//                        VStack {
//                            HStack {
//                                RSSRow(rss: rss)
//                                Spacer()
//                                if rss.isRead == false {
//                                    Image(systemName: "circle.fill")
//                                        .imageScale(.small)
//                                        .foregroundColor(.blue)
//                                        .onTapGesture( perform: { rss.isRead = true } )
//                                }
//                                else {
//                                    Image(systemName: "circle")
//                                        .imageScale(.small)
//                                        .foregroundColor(.gray)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
        


            .navigationBarTitle("Feeds", displayMode: .automatic)
//            .navigationBarItems(trailing: ListView)
//            //leading: EditButton(),
            .navigationBarItems(trailing:
                HStack {
                    
                    Button(action: {
                        print("Reload button pressed...")
                        
                    }) {
                        
                        Image(systemName: "arrow.clockwise")
                    }
                    .padding(.trailing)
                    
                    addSourceButton
                }
            )
            .onAppear {
                self.viewModel.fecthResults()
            }

            .listStyle(InsetGroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .font(.headline)


        }

            .sheet(isPresented: $isSheetPresented, content: {
            AddRSSView( viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss),
                onDoneAction: self.onDoneAction)
        })
            .onAppear {
            self.viewModel.fecthResults()
            }
        }
    }

//        VStack {
//            DisclosureGroup("Default Feeds", isExpanded:      $revealDetails) {
//                Button("Hide") {
//                    revealDetails.toggle()
//                }
//            }

//        NavigationView {
//            List {
//                ForEach(viewModel.items, id: \.self) { rss in
//                    NavigationLink(destination: self.destinationView(rss)) {
//                        RSSRow(rss: rss)
//
//                    }
//                    .tag("RSS")
//                }
//                .onDelete { indexSet in
//                    if let index = indexSet.first {
//                        self.viewModel.delete(at: index)
//                    }
//                }
//
//
//            .navigationBarTitle("Feeds", displayMode: .automatic)
//            .navigationBarItems(leading: EditButton(), trailing: ListView)
//            .onAppear {
//                self.viewModel.fecthResults()
//            }
//
//            .listStyle(InsetGroupedListStyle())
//            .environment(\.horizontalSizeClass, .regular)
//            .font(.headline)
//
//
//        }
//
//            .sheet(isPresented: $isSheetPresented, content: {
//            AddRSSView( viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss),
//                onDoneAction: self.onDoneAction)
//        })
//            .onAppear {
//            self.viewModel.fecthResults()
//            }

extension RSSListView {
    
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

struct RSSListView_Previews: PreviewProvider {
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

    static var previews: some View {
        RSSListView(viewModel: self.viewModel)
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .small)
        }
    }

//
//    enum FeatureItem {
//        case setting
////        case move
//    }
//
//    enum FeaureItem {
//        case add
//        case setting
//    }
//    @State private var searchTerm: String = ""
//    @State var searchText = ""
//    @State var isSearching = false
//
//    @ObservedObject var viewModel: RSSListViewModel
//    @State var size = UIScreen.main.bounds.width / 1.6
//    @State private var showContent = false
//    @State private var isSheetPresented = false
//    @State private var selectedFeatureItem = FeaureItem.add
//    @State private var selectedFeaureItem = FeatureItem.setting
//    @State private var isSettingPresented = false
//    @State var isEditing = false
//    @State private var revealDetails = false
//    @State private var addRSSProgressValue = 0.0
//
//    private var addSourceButton: some View {
//        Button(action: {
//            self.isSheetPresented = true
//            self.selectedFeatureItem = .add
//        }) {
//            Image(systemName: "plus")
//                .padding(.trailing, 0)
//                .imageScale(.large)
//        }
//    }
//
//    private var settingListView: some View {
//        Button(action: {
//            self.isSettingPresented = true
//            self.selectedFeaureItem = .setting
//            //SettingView()
//        }) {
//            Image(systemName: "switch.2")
//            .padding(.trailing, 5)
//            imageScale(.medium)
//                .layoutPriority(10)
//                .animation(.easeInOut)
//        }
//    }
//
//    private var trailingView: some View {
//        HStack(alignment: .top, spacing: 24) {
//            settingListView
//            EditButton()
//            addSourceButton
//
//        }
//    }
//
//    @State private var selectedItem: RSSItem?
//
//    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
//    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))
//
//    var body: some View {
////        SearchBar(searchText: $searchText, isSearching: $isSearching)
////        ZStack{
////
////            EmptyView()
//
//                //.edgesIgnoringSafeArea(.all)
//
//             //main home page components here below....
//            HStack {
//                NavigationView {
//                    VStack {
//                        Form{
//
//                            //SearchBar(text: $searchTerm)
//
////                            SearchBar(searchText: $searchText, isSearching: $isSearching)
//
//                                //.padding(.top, 25.0)
//                            Section(header: Text("SMART FEEDS")) {
//                                DisclosureGroup("All Feeds", isExpanded: $revealDetails) {
//                                    ForEach(viewModel.items, id: \.self) { rss in
//                                        NavigationLink(destination: self.destinationView(rss)) {
//                                            RSSRow(rss: rss)
////ForEach(self.names.filter {
////self.searchTerm.isEmpty ? true
////}, id: \.self) { name in
////Text(name)
//
//
//                                    }
//
//                                    .tag("RSS")
//                                }
//
//                                .onDelete { indexSet in
//                                    if let index = indexSet.first {
//                                        self.viewModel.delete(at: index)
//
//                                        }
//                                    }
//                                }
//                            }
//                        }
//
//                        .font(.custom("Gotham", size: 18)) //.background(Color("bg"))
//                        .shadow(color: Color.gray, radius: 1, y: 1)
//                        //darkshadow
////                        .padding([.leading, .trailing])
//                    //.listRowBackground(Color(.black.opacity(0.5))
//                    //.background(Color(.black))
//                    //.colorMultiply(Color.blue).padding(.top)
//                        .onAppear {
//                            self.viewModel.fecthResults()
//                        }
//                    }
//
//                    .navigationBarTitle("Feedit", displayMode: .automatic)
//                    //.navigationBarHidden(true)
//                    .listStyle(InsetGroupedListStyle())
//                    .font(.custom("Gotham", size: 18)) // font for 'All Feeds'
//                    .navigationBarItems(trailing: trailingView)
////                    leading: Button(action: {
////
////                        self.size = 10
////
////                    }, label: {
////
////                        Image("launch")
////                            .resizable()
////                            .aspectRatio(contentMode: .fit)
////                            .font(.body)
////                            .cornerRadius(3)
////                            .frame(width: 30, height: 30,alignment: .center)
////                            .layoutPriority(10)
////                    }).foregroundColor(.blue), trailing: trailingView)
//                    //(trailing: trailingView)//(leading: leadingView,
//
//                    //.background(View)
//            .sheet(isPresented: $isSheetPresented, content: {
//                if FeaureItem.add == self.selectedFeatureItem {
//                    AddRSSView(
//                        viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss),
//                        onDoneAction: self.onDoneAction)
//                } else if FeaureItem.setting == self.selectedFeatureItem {
//                    SettingView()
//                }
//            })
//
//            .sheet(isPresented: $isSheetPresented, content: {
//            AddRSSView( viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss),
//                onDoneAction: self.onDoneAction)
//
//            })
//
//                .onAppear {
//                self.viewModel.fecthResults()
//
//                    }
//                }
//            }
//        }
//    }
//
//extension RSSListView {
//
//    func onDoneAction() {
//        self.viewModel.fecthResults()
//    }
//
//    private func destinationView(_ rss: RSS) -> some View {
//        RSSFeedListView(viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
//            .environmentObject(DataSourceService.current.rss)
//    }
//
//    func deleteItems(at offsets: IndexSet) {
//        viewModel.items.remove(atOffsets: offsets)
//    }
//}
//
//struct RSSListView_Previews: PreviewProvider {
//    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
//
//    static var previews: some View {
//        RSSListView(viewModel: self.viewModel)
//            //.preferredColorScheme(.dark)
//    }
//}
