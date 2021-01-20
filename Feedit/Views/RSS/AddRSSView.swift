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
    
    @ObservedObject var viewModel: AddRSSViewModel
//    @State private var previewIndex = 0

    var onDoneAction: (() -> Void)?
    var onCancelAction: (() -> Void)?
    
    private var doneButton: some View {
        Button(action: {
            self.viewModel.commitCreateNewRSS()
            self.onDoneAction?()
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "checkmark.circle")
        }.disabled(!isVaildSource)
    }
    
    private var cancelButton: some View {
        Button(action: {
            self.viewModel.cancelCreateNewRSS()
            self.onCancelAction?()
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
        }
    }
    
    private var trailingView: some View {
        HStack(alignment: .top, spacing: 24) {
            doneButton
        }
    }
    
    private var sectionHeader: some View {
        VStack(alignment: .center) {
            HStack{
                Button(action: self.fetchDetail) {
                    Text("Search").font(.system(size: 17, weight: .medium, design: .rounded))
                }
            }.padding(.horizontal, 120.0)
        }
    }
    
    private var isVaildSource: Bool {
        return !feedUrl.isEmpty
        
    }
    
    @State private var hasFetchResult: Bool = false
    
    @State private var feedUrl: String = ""
    @State private var feedTitle: String = ""

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
                Section() {
                    HStack(alignment: .center){
                        Image(systemName: "magnifyingglass")
                            .opacity(0.4)
                            TextField("Feed URL", text: $feedUrl)
//                                .textCase(.lowercase)
                                .disableAutocorrection(true)
                                .opacity(0.4)
                                .padding(.trailing)
                                .multilineTextAlignment(.leading)
                    }
                    HStack(alignment: .center){
                        sectionHeader
                    
                    }
                }
                    if !hasFetchResult {
                        EmptyView()
                    } else {
                        if viewModel.rss != nil {
                        Section(header: Text("Feed").font(.system(size: 15, weight: .medium, design: .rounded))
                                    
                                    ){
                            RSSDisplayView(rss: viewModel.rss!)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
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
}
