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
            Image(systemName: "checkmark")
            //Text("Done")
        }.disabled(!isVaildSource)
    }
    
    private var cancelButton: some View {
        Button(action: {
            self.viewModel.cancelCreateNewRSS()
            self.onCancelAction?()
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
            //Text("Cancel")
        }
    }
    
    private var trailingView: some View {
        HStack(alignment: .top, spacing: 24) {
            doneButton
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            Text("")//input//search
            Spacer()
            Button(action: self.fetchDetail) {
                Text("Search")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding(.all, 0)
                
            }
            //.frame(width: 50, height: 30)
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
                Section(header: sectionHeader) {
                    HStack{
                        Image(systemName: "magnifyingglass")
                            .opacity(0.4)
                            TextField("Feed URL", text: $feedUrl)
                                .padding(.trailing)
                            .opacity(0.4)
                            .disableAutocorrection(true)
                    }
                    Picker("  ❯   Folders", selection: $previewIndex) {
                        ForEach(0 ..< categories.count) {
                            Text(categories[$0].name)
                        }
                        VStack {
                            List(categories, id: \.self) { category in
                                VStack(alignment: .leading) {
                                    Text(category.name)
                                        .font(.system(size: 12))
                                        .padding(EdgeInsets(top: 4, leading: 7, bottom: 4, trailing: 7))
                                        .background(Color(category.color))
                                        .cornerRadius(3)
                                    Text("Number of articles: \(category.articlesCount)")
                                        .font(.footnote)
                                }
                            }
                        }
                        .navigationBarTitle("Folders")
                        .navigationBarItems(leading:
                            HStack {
                                Button("Add") {
                                    Category.insertSample(into: managedObjectContext)
                                }
                                Button("Rename") {
                                    self.renameCategory()
                                }
                            }, trailing:
                                Button("Save") {
                                    try! self.managedObjectContext.save()
                                }
                            )
                    }
                    .font(.body)
                }
                

                Section(header: Text("") //result
                            ) {
                    if !hasFetchResult {
                        Text("Search results will show here")
                            .opacity(0.4)
                    } else {
                        if viewModel.rss != nil {
                            RSSDisplayView(rss: viewModel.rss!)
                        }
                    }
                }
                
            }
            .navigationBarTitle("Add Feed")
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
        }
        .onDisappear {
            self.viewModel.cancelCreateNewRSS()
        }
    }
    
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
    private func renameCategory() {
        guard let category = categories.first else { return }
        if category.name == "News" {
            category.name = "Blogs"
        } else {
            category.name = "Technology"
        }
    }
}
