//
//  RSSListView.swift
//  Feedit
//
//  Created by Tyler Lawrence on 10/22/20
//


import SwiftUI
import ModalView

struct RSSListView: View {

    enum FeatureItem {
        case setting
//        case move
    }
    
    enum FeaureItem {
        case add
        case setting
    }
    
    @State var searchText = ""
    @State var isSearching = false
    
    @ObservedObject var viewModel: RSSListViewModel
    @State var size = UIScreen.main.bounds.width / 1.6
    @State private var showContent = false
    @State private var isSheetPresented = false
    @State private var selectedFeatureItem = FeaureItem.add
    @State private var selectedFeaureItem = FeatureItem.setting
    @State private var isSettingPresented = false
    @State var isEditing = false
    @State private var revealDetails = false
    @State private var addRSSProgressValue = 0.0
        
    private var addSourceButton: some View {
        Button(action: {
            self.isSheetPresented = true
            self.selectedFeatureItem = .add
        }) {
            Image(systemName: "plus")
                .padding(.trailing, 0)
                .imageScale(.large)
        }
    }
    
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

    private var trailingView: some View {
        HStack(alignment: .top, spacing: 24) {
            //settingListView
            //EditButton()
            addSourceButton

        }
    }
    
    @State private var selectedItem: RSSItem?
    
    private let addRSSPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("addNewRSSPublisher"))
    private let rssRefreshPublisher = NotificationCenter.default.publisher(for: Notification.Name.init("rssListNeedRefresh"))

    var body: some View {
        ZStack{
            
            Color.blue
            
                //.edgesIgnoringSafeArea(.all)
            
             //main home page components here below....
        
            HStack {
                NavigationView {
                    VStack {
                        SearchBar(searchText: $searchText, isSearching: $isSearching)
                        Form{
                            //SearchBar(searchText: $searchText, isSearching: $isSearching)

                            Section(header: Text("SMART FEEDS")) {
                                DisclosureGroup("All Feeds", isExpanded: $revealDetails) {
                                    ForEach(viewModel.items, id: \.self) { rss in
                                        //ModalLink
                                        NavigationLink(destination: self.destinationView(rss)) {
                                            RSSRow(rss: rss)
                                    }
                                
                                    .tag("RSS")
                                }
                                    
                                .onDelete { indexSet in
                                    if let index = indexSet.first {
                                        self.viewModel.delete(at: index)
                                        
                                        }
                                    }
                                }
                            }
                        }
                    //.listRowBackground(Color(.black.opacity(0.5))
                    //.background(Color(.black))
                    //.colorMultiply(Color.blue).padding(.top)
                        .onAppear {
                            self.viewModel.fecthResults()
                        }
                    }
                //}
                    .navigationBarTitle("Feedit: On My iPhone", displayMode: .automatic)
                    //.navigationBarHidden(true)
                    //.listStyle(InsetGroupedListStyle())
                    //.font(.custom("Gotham", size: 18)) // font for 'All Feeds'
                    .navigationBarItems(leading: Button(action: {
                        
                        self.size = 10
                        
                    }, label: {
                        
                        Image("launch")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(.body)
                            .cornerRadius(3)
                            .frame(width: 30, height: 30,alignment: .center)
                            .layoutPriority(10)
                    }).foregroundColor(.blue), trailing: trailingView)//(trailing: trailingView)//(leading: leadingView, trailing: trailingView)
                    //.background(View)
            .sheet(isPresented: $isSheetPresented, content: {
                if FeaureItem.add == self.selectedFeatureItem {
                    AddRSSView(
                        viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss),
                        onDoneAction: self.onDoneAction)
                } else if FeaureItem.setting == self.selectedFeatureItem {
                    SettingView()
                }
            })
                        
            .sheet(isPresented: $isSheetPresented, content: {
            AddRSSView( viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss),
                onDoneAction: self.onDoneAction)
                
            })
                        
                .onAppear {
                self.viewModel.fecthResults()
                    
                    }
                }
            }.navigationBarItems(leading: Button(action: {
                
                self.size = 10
                
            }, label: {
                
                Image("menu").resizable().frame(width: 20, height: 20)
            }).foregroundColor(.black))
        
        HStack{
            
            menu(size: $size)
            .cornerRadius(20)
                .padding(.leading, -size)
                .offset(x: -size)
            
            Spacer()
        }
        
    }.animation(.spring())
    }
}
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
            //.preferredColorScheme(.dark)
    }
}

struct menu : View {
    
    @Binding var size : CGFloat
    
    
    var body : some View{

    
        VStack{
            HStack{

                Spacer()

                Button(action: {

                    self.size =  UIScreen.main.bounds.width / 1.6
                }) {

                    Image(systemName: "xmark.circle.fill").resizable().frame(width: 35, height: 35)//.padding()
                }.background(Color(.systemGray6))
                .foregroundColor(Color(.systemGray3))
                .clipShape(Circle())
            }
            VStack(alignment: .center, spacing: 0) {
                
                HStack {
                    Image("launch")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .font(.body)
                        .cornerRadius(20)
                        .frame(width: 90, height: 90,alignment: .center)
                        //.layoutPriority(10)
                }
                
                HStack {
                    //Image(systemName: "largecircle.fill.circle")
                        //.imageScale(.small)
                    
                    Text("Feedit")//.bold()
                        .font(.custom("Gotham", size: 36))
                        .padding(.top)
                    //Spacer()
                }.padding(.horizontal)
                .padding(.vertical, 10)
                .foregroundColor(.primary)
                .font(.largeTitle)
                
                    Text("RSS Reader")
                        .font(.custom("Gotham", size: 26))
                        .foregroundColor(.gray)
                }.padding(.horizontal)
                .padding(.vertical, 10)
//            HStack{
//
//                Spacer()
//
//                Button(action: {
//
//                    self.size =  UIScreen.main.bounds.width / 1.6
//                }) {
//
//                    Image(systemName: "xmark.circle.fill").resizable().frame(width: 35, height: 35).padding()
//                }.background(Color(.systemGray6))
//                .foregroundColor(Color(.systemGray3))
//                .clipShape(Circle())
//            }

            HStack{
                Image(systemName: "text.alignleft")
                    //.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30,alignment: .center)
//                    .frame(width: 20, height: 15).padding()

                Text("Feeds").fontWeight(.heavy)
                    .font(.custom("Gotham", size: 20))
                Spacer()
            }.padding(.leading, 23)
            HStack{

                Image(systemName: "bookmark")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30,alignment: .center)
                //.resizable().frame(width: 25, height: 25).padding()

                Text("Bookmarked").fontWeight(.heavy)
                    .font(.custom("Gotham", size: 20))

                Spacer()
            }.padding(.leading, 23)
            HStack{

                Image(systemName: "magnifyingglass")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30,alignment: .center)
                    //.resizable().frame(width: 25, height: 25).padding()

                Text("Search").fontWeight(.heavy)
                    .font(.custom("Gotham", size: 20))

                Spacer()
            }.padding(.leading, 23)
            HStack{

                Image(systemName: "switch.2")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30,alignment: .center)
                    //.resizable().frame(width: 25, height: 25).padding()

                Text("Settings").fontWeight(.heavy)
                    .font(.custom("Gotham", size: 20))

                Spacer()
            }.padding(.leading, 23)

            Spacer()

        }.frame(width: UIScreen.main.bounds.width / 1.6)
        .background(Color(.systemGray6))
        //(Color.secondary)
       // if u want to change swipe menu background color
    }
}

struct SearchBar: View {
    
    @Binding var searchText: String
    @Binding var isSearching: Bool
    
    var body: some View {
        Spacer()
        HStack {
            HStack {
                TextField("Search", text: $searchText)
                    .font(.custom("Gotham", size: 20))
                    .padding(.leading, 24)
            }
            .padding()
            .background(Color(.systemGray6))
            .opacity(0.5)
            .cornerRadius(18)
            //.padding(.vertical)
            .padding(.horizontal)
            .onTapGesture(perform: {
                isSearching = true
            })
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .imageScale(.large)
                    Spacer()
                    
                    if isSearching {
                        Button(action: { searchText = "" }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .padding(.vertical)
                        })
                        
                    }
                    
                }.padding(.horizontal, 32)
                .foregroundColor(.gray).opacity(0.8)
            ).transition(.move(edge: .trailing))
            .animation(.spring())
            
            if isSearching {
                Button(action: {
                    isSearching = false
                    searchText = ""
                    
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    
                }, label: {
                    Text("Cancel")
                        .padding(.trailing)
                        .padding(.leading, 0)
                })
                .transition(.move(edge: .trailing))
                .animation(.spring())
            }
            
        }
    }
}
