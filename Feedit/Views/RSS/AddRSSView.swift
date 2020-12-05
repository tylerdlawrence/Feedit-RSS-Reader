//
//  AddRssSource.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI

struct AddRSSView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Category.entity(), sortDescriptors: []) var categories: FetchedResults<Category>
    
    @ObservedObject var viewModel: AddRSSViewModel
    @State private var previewIndex = 0

    var onDoneAction: (() -> Void)?
    var onCancelAction: (() -> Void)?
    
    private var doneButton: some View {
        Button(action: {
            self.viewModel.commitCreateNewRSS()
            self.onDoneAction?()
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "checkmark.circle")
            //Text("Done")
        }.disabled(!isVaildSource)
    }
    
    private var cancelButton: some View {
        Button(action: {
            self.viewModel.cancelCreateNewRSS()
            self.onCancelAction?()
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
            //Text("All Items") //xmark
            //Text("Cancel")
        }
    }
    
    private var trailingView: some View {
        HStack(alignment: .top, spacing: 24) {
            doneButton
        }
    }
    
    private var sectionHeader: some View {
        VStack {
            HStack(alignment: .center) {
//                Text("")//input//search
               // Spacer()
                Button(action: self.fetchDetail) {
                    Text("Search")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                }
            }
            .multilineTextAlignment(.center)

            .padding(.leading, 120)
        }
    }
    
    
    private var helpButton: some View {
        Button(action: {
                self.showingAlert = true
            }) {
            Image(systemName: "questionmark.circle")
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Where do I find an RSS feed?"), message: Text("RSS feed URLs can be found on most websites. Typically, RSS feeds will have /feed .rss, .xml, .json or .atom at the end of the site address."), dismissButton: .default(Text("Got it!")))
        }
    }
    
    private var trailingButtons: some View {
        HStack(alignment: .top, spacing: 24) {
            helpButton
            doneButton
        }
    }
    
    private var isVaildSource: Bool {
        return !feedUrl.isEmpty
        
    }
    
    @State private var hasFetchResult: Bool = false
    
    @State private var feedUrl: String = ""
    @State private var feedTitle: String = ""

//    @Binding var isPresented: Bool

    init(viewModel: AddRSSViewModel,
         onDoneAction: (() -> Void)? = nil,
         onCancelAction: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onDoneAction = onDoneAction
        self.onCancelAction = onCancelAction
        
    }
    var body: some View {
        NavigationView {
            Form {
                Section() { //header: sectionHeader
                    HStack(alignment: .center){
                        Image(systemName: "magnifyingglass")
                            .opacity(0.4)
                            TextField("Feed URL", text: $feedUrl)
                                .padding(.trailing)
                                .multilineTextAlignment(.leading)
                            .opacity(0.4)
                            .disableAutocorrection(true)
                    }
                    HStack(alignment: .center){
                        sectionHeader
                    
                    }
                }
//                    Picker("Manage Folders", selection: $previewIndex) {
//                        ForEach(0 ..< categories.count) {
//                            Text(categories[$0].name)
//                            NavigationView {
//                                VStack {
//                                    List(categories, id: \.self) { category in
//                                        VStack(alignment: .center) {
//                                            Text(category.name)
//                                                .cornerRadius(3)
//                                            Text("Number of articles: \(category.articlesCount)")
//                                                .font(.footnote)
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .frame(width: 300, height: 35)
//                    .font(.body)
//                    .padding(.leading, 90.0)
                
                    if !hasFetchResult {
                        EmptyView()

                    } else {
                        if viewModel.rss != nil {
                            //Spacer()
                            Section(header: Text("Search Results")
                                        .font(.subheadline)
                                        .fontWeight(.heavy)
                                        .multilineTextAlignment(.center)
                                        .padding(.leading, 100.0)
                                        ){
                                RSSDisplayView(rss: viewModel.rss!)
                                    .font(.subheadline)
                            }
                    }
                }
            }
            .navigationBarTitle("Add Feed")
            .navigationBarItems(leading: cancelButton, trailing: trailingButtons)
        }
        .onDisappear {
            self.viewModel.cancelCreateNewRSS()
    }
}
    @State private var showingAlert = false
    
func fetchDetail() {
    guard let url = URL(string: self.feedUrl),
        let rss = viewModel.rss else {
        return
    }
    updateNewRSS(url: url, for: rss) { result in
        switch result {
        case .success(let rss):
            self.viewModel.rss = rss
            self.hasFetchResult = true
        case .failure(let error):
            print("fetchDetail error = \(error)")
            }
        }
    }
}

struct AddRSSView_Previews: PreviewProvider {
    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static var previews: some View {
        HomeView(viewModel: self.viewModel, archiveListViewModel: self.archiveListViewModel)
            .preferredColorScheme(.dark)
    }
}
