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
    
    @ObservedObject var viewModel: RSSListViewModel
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
//            FilterPicker(isOn: 2, rssFeedViewModel: rssFeedViewModel)
            settingButton
            Spacer()
//            settingButton
//            archiveButton
            addSourceButton
        }.padding(24)
    }
    
    //MARK: LISTVIEWS
    private var allItemsSection: some View {
        Group{
            HStack {
                Text("All Items")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                Spacer()
                
            }
            VStack{
                HStack {
                    ZStack{
                        NavigationLink(destination: DataNStorageView(rssFeedViewModel: self.rssFeedViewModel, viewModel: self.viewModel, isRead: isRead)) {
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
                        Text("\(viewModel.items.count)")
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
            }
            ZStack{
                NavigationLink(destination: archiveListView) {
                    EmptyView()
                }
                .opacity(0.0)
                .buttonStyle(PlainButtonStyle())
                HStack{
                    Image(systemName: "star.fill")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(.yellow)
                        .opacity(0.8)
                        .frame(width: 25, height: 25)
                    Text("Starred")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        Spacer()
                    Text("\(archiveListViewModel.items.count)")
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
            .onAppear {
                self.archiveListViewModel.fecthResults()
            }
        }
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
            },
            label: {
                HStack {
                    Text("Feeds")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                }
            })
            .accentColor(Color("tab"))
        }
    
    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))

    var body: some View {
        NavigationView{
            VStack {
                ZStack {
                    List{
                        Spacer()
                        allItemsSection
                        Spacer()
                        feedsSection
                    }
                    .navigationBarItems(trailing:
                                            HStack(spacing: 10) {
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

                    .listStyle(PlainListStyle())
                    .navigationBarTitle("Account")
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
                destination: ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)),
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
    func startNetworkCall() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isLoading = false
        }
    }
    private func destinationView(rss: RSS) -> some View {
        RSSFeedListView(viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem, isRead: isRead), isRead: isRead)
            .environmentObject(DataSourceService.current.rss)
    }
}

struct HomeView_Previews: PreviewProvider {
    static let rss = RSS()
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static let isRead = true

    static var previews: some View {
        Group{
            HomeView(viewModel: self.viewModel, rssFeedViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem, isRead: isRead), archiveListViewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
            .environment(\.colorScheme, .dark)
        }.environmentObject(DataSourceService.current.rss)
    }
}


