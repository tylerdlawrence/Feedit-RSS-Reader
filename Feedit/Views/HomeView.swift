//
//  HomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/12/20.
//

import SwiftUI

struct HomeView: View {
    
    enum FeaureItem {
        case add
        case setting
        case star
    }
    
    @ObservedObject var viewModel: RSSListViewModel

//    @State private var refreshID = UUID()
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
    @State var isExpanded = false
    @State var sources: [RSS] = []

    private var archiveListView: some View {
        ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
    }
    
    private var archiveButton: some View {
        Button(action: {
            self.action = 1
        }) {
            Image(systemName: "star.fill")
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
            settingButton
            Spacer()
            archiveButton
            addSourceButton
        }.padding(24)
    }
    
    private var navTopButtons: some View {
        HStack {
            settingButton
            Spacer()
            archiveButton
            addSourceButton
        }
    }
    
    private var trailingView: some View {
        HStack(spacing: 125) {
            settingButton
            Spacer()
            addSourceButton
        }
    }
    
    //MARK: LISTVIEWS
    private var allItemsSection: some View {
        Group{
            HStack {
                Text("All Items")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                Spacer()
                Text("\(self.viewModel.items.count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 1)
                    .background(Color.gray.opacity(0.5))
                    .opacity(0.4)
                    .foregroundColor(Color("text"))
                    .cornerRadius(8)
            }
            
            HStack {
                ZStack{
                    NavigationLink(destination: DataNStorageView()) {
                        EmptyView()
                    }
                    .opacity(0.0)
                    .buttonStyle(PlainButtonStyle())
                    HStack{
                        Image(systemName: "archivebox.fill").font(.system(size: 20, weight: .ultraLight))
                            .foregroundColor(Color("text"))
                            .opacity(0.8)
                            .frame(width: 25, height: 25)
                        Text("Archive")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                        Spacer()
                        }
                }
            }
        }
    }
    private var smartSection: some View {
        DisclosureGroup(
            isExpanded: $revealSmartFilters,
            content: {
                ZStack{
                    NavigationLink(destination: DataNStorageView()) {
                        EmptyView()
                    }
                    .opacity(0.0)
                    .buttonStyle(PlainButtonStyle())
                    
                    HStack{
                        Image(systemName: "archivebox.fill").font(.system(size: 20, weight: .thin))
                            .foregroundColor(Color("tab"))
                            .opacity(0.8)
                            .frame(width: 25, height: 25)
                        Text("Archive")
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                        Spacer()
                    }
                }
                .accentColor(Color("tab"))
                .foregroundColor(Color("darkerAccent"))
                .listRowBackground(Color("accent"))
                ZStack{
                    NavigationLink(destination: archiveListView) {
                        EmptyView()
                    }
                    .opacity(0.0)
                    .buttonStyle(PlainButtonStyle())
                    HStack{
                        Image(systemName: "star.square.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                            .opacity(0.8)
                            .frame(width: 25, height: 25)
                        Text("Starred")
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            Spacer()
                    }
                }
                .accentColor(Color("tab"))
                .foregroundColor(Color("darkerAccent"))
                .listRowBackground(Color("accent"))
            },
            label: {
                HStack {
                    Text("All Items")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                }
                
            })
            .textCase(nil)
            .accentColor(Color("tab"))
            .foregroundColor(Color("darkerAccent"))
            .listRowBackground(Color("accent"))
    }
    private var feedsSection: some View {
        DisclosureGroup(
            isExpanded: $revealFeedsDisclosureGroup,
            content: {
                ForEach(viewModel.items, id: \.self) { rss in
                    ZStack {
                        NavigationLink(destination: self.destinationView(rss: rss)) { //.onDisappear(perform: {self.refreshID = UUID()})
                            EmptyView()
                        }
                        .opacity(0.0)
                        .buttonStyle(PlainButtonStyle())
                    HStack {
                        RSSRow(rss: rss)
                        }
                    }
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        self.viewModel.delete(at: index)
                    }
                }
                .accentColor(Color("tab"))
                .foregroundColor(Color("darkerAccent"))
                .listRowBackground(Color("accent"))
            },
            label: {
                HStack {
                    Text("Feeds")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                    Spacer()
                }
            })
            .accentColor(Color("tab"))
            .foregroundColor(Color("darkerAccent"))
            .listRowBackground(Color("accent"))
        }
    
    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))
    
    var body: some View {
        NavigationView{
            VStack {
                ZStack {
                    
                    List{

                        Spacer()
                            .accentColor(Color("tab"))
                            .foregroundColor(Color("darkerAccent"))
                            .listRowBackground(Color("accent"))
                        allItemsSection
                        Spacer()
                        feedsSection
                    }
                    .navigationBarItems(trailing:
                                            HStack(spacing: 10) {
                                                Button(action: {
                                                    self.isLoading = true
                                                }) {
                                                Image(systemName: "arrow.clockwise").font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(Color("tab"))
                                                    .frame(width: 50, height: 50)
                                                    .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                                                    .animation(Animation.linear(duration: 2).repeatCount(3, autoreverses: false))
                                                    .onAppear() {
                                                        self.isLoading = true
                                                    }
                                                }
                                                Toggle("", isOn: $isRead)
                                                    .toggleStyle(CheckboxStyle())
                                                
                                            })
                    .listStyle(PlainListStyle())
                    .navigationBarTitle("Account")
                }
            Spacer()
                if addRSSProgressValue > 0 && addRSSProgressValue < 1.0 {
                    LinerProgressBar(lineWidth: 3, color: .blue, progress: $addRSSProgressValue)
                        .frame(width: UIScreen.main.bounds.width, height: 3, alignment: .leading)
                }
            navButtons
                .frame(width: UIScreen.main.bounds.width, height: 49, alignment: .leading)
            NavigationLink(
                destination: ArchiveListView(viewModel: ArchiveListViewModel( dataSource: DataSourceService.current.rssItem)),
                tag: 1,
                selection: $action) {
                EmptyView()
                }
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
                    SettingView(fetchContentTime: .constant("minute1"))
                }
            })
            .onAppear {
                self.viewModel.fecthResults()
            }
        }
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
        RSSFeedListView(viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), rss: rss)
            .environmentObject(DataSourceService.current.rss)
    }
    func deleteItems(at offsets: IndexSet) {
        viewModel.items.remove(atOffsets: offsets)
    }
    func startProgressBar() {
        for _ in 0...100 {
            self.addRSSProgressValue += 0.015
            
        }
    }
    func resetProgressBar() {
        self.addRSSProgressValue = 0.0
    }
}

struct HomeView_Previews: PreviewProvider {
    
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
    static var previews: some View {
        Group{
            HomeView(viewModel: self.viewModel)
            .environment(\.colorScheme, .dark)

            HomeView(viewModel: self.viewModel)
        }.environmentObject(DataSourceService.current.rss)
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
