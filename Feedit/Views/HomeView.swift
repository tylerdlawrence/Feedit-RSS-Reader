//
//  HomeView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/12/20.
//

import SwiftUI
import ModalView
import FeedKit
import Foundation

enum FeaureItem {
    case add
    case setting
}

//enum FeatureItem {
//    case setting
//}

struct HomeView: View {
    
    @State private var items = ["One", "Two", "Three", "Four", "Five"]

    enum ContentViewGroup: Hashable {
        
      case RSS
      case tag
      case unread
    }
    @ObservedObject var viewModel: RSSListViewModel
//    @State private var activeSheet: Sheet?
    @State var showingContent: ContentViewGroup?
    @State private var selectedFeatureItem = FeaureItem.add
//    @State private var selectedFeatureItem = FeatureItem.setting
    @State private var isAddFormPresented = false
    @State private var isSettingPresented = false
    @State private var isSheetPresented = false
    @State private var addRSSProgressValue = 0.0
    @State var sources: [RSS] = []
    
//    private var settingListView: some View {
//        SettingView(settingViewModel: self.settingViewModel)
//    }
    
    private var addSourceButton: some View {
        Button(action: {
            self.isSheetPresented = true
            self.selectedFeatureItem = .add
        }) {
            Image(systemName: "plus")
                .imageScale(.large)
        }
    }
    
    private var settingButton: some View {
        Button(action: {
            self.isSheetPresented = true
            self.selectedFeatureItem = .setting
        }) {
            Image("settingtoggle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25, alignment: .center)
//            Image(systemName: "gear")
//                .imageScale(.medium)
        }
    }
    
    private var archiveListView: some View {
        Button(action: {
            print ("Tags")
        }) {
            Image(systemName: "tag")
                .imageScale(.medium)
        }
    }

    private var trailingView: some View {
        HStack(alignment: .top, spacing: 24) {
            settingButton
//            archiveListView
//            EditButton()
            addSourceButton
        }
    }
    
    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))
        
  var body: some View {
    NavigationView{
        List {
            DisclosureGroup(
            "All Sources",
            tag: .RSS,
            selection: $showingContent) {
                ForEach(viewModel.items, id: \.self) { rss in
                    NavigationLink(destination: self.destinationView(rss)) {
                        RSSRow(rss: rss)
                    }
                    .tag("RSS")

                }
                .onMove { (indexSet, index) in
                    self.items.move(fromOffsets: indexSet,
                toOffset: index)
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        self.viewModel.delete(at: index)
                    }
                }
              }
            
            
//          DisclosureGroup(
//            "Tagged Articles",
//            tag: .tag,
//            selection: $showingContent) {
//                Label(
//                    title: { Text("Tags") },
//                    icon: { Image(systemName: "tag")
//
//                })
//          }
        

//          DisclosureGroup(
//            "Unread",
//            tag: .unread,
//            selection: $showingContent) {
//            Label(
//                title: { Text("View All Unread") },
//                icon: { Image(systemName: "circle.fill")
//
//            })
//          }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Account")
        .navigationBarItems(leading: EditButton(), trailing: trailingView)
//        .navigationBarItems(leading: Button(action: {
//            activeSheet = .settings
//        }, label: {
//            Image(systemName: "gear")
//            imageScale(.medium)
//        }), trailing: Button(action: {
//            activeSheet = .add
//        }, label: {
//            Image(systemName: "plus")
//                    .imageScale(.medium)
//        }))
        if addRSSProgressValue > 0 && addRSSProgressValue < 1.0 {
            LinerProgressBar(lineWidth: 3, color: .blue, progress: $addRSSProgressValue)
                .padding(.top, 2)
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
                SettingView()
            }
        })
        .onAppear {
            self.viewModel.fecthResults()
        }
//            .sheet(isPresented: $isSheetPresented, content: {
//            AddRSSView(viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss),
//                onDoneAction: self.onDoneAction)
//            })
//            .onAppear {
//            self.viewModel.fecthResults()
//            }
//            .sheet(isPresented: $isSettingPresented, content: {
//                SettingView(settingViewModel: self.settingViewModel)
//            })
        }
    }
//}
        
//        .sheet(item: $activeSheet) { sheet in
//            switch sheet {
//            case .add:
//                NavigationView {
//                    RSSDisplayView(rss: $viewModel.rss)
//                                .init(get: {
//                        activeSheet == .add
//                    }, set: { isPresented in
//                        activeSheet = isPresented ? .add : nil
//                    }))
                
//            case settings:
//                NavigationView {
//                    settingListView
//            }
//                }
//            }
//        }
//    }
//        .sheet(isPresented: $addIsPresented, content: {
//        AddRSSView( viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss),
//            onDoneAction: self.onDoneAction)
//    })
//        .onAppear {
//        self.viewModel.fecthResults()
//        }
                            
//            HStack {
//
//                Button(action: {
//
//                    print("Reload button pressed...")
//
//                }) {
//                    settingButton
////                    Image(systemName: "arrow.clockwise")
//                }
//                .padding(.trailing)
//
//                addSourceButton
//            }

      //)
//        }
//
//    }
//}

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

    func deleteItems(at offsets: IndexSet) {
        viewModel.items.remove(atOffsets: offsets)
    }
}

struct HomeView_Previews: PreviewProvider {
    
    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
//    static let settingViewModel = SettingViewModel()

    static var previews: some View {
        
        HomeView(viewModel: self.viewModel)
        
//        ArchiveListView(viewModel: ArchiveListViewModel(dataSource: DataSourceService.current.rssItem))
    }
}
