//
//  AddRssSource.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI

struct AddRSSView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: AddRSSViewModel
    
    var onDoneAction: (() -> Void)?
    var onCancelAction: (() -> Void)?
    
    private var doneButton: some View {
        Button(action: {
            self.viewModel.commitCreateNewRSS()
            self.onDoneAction?()
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Done")
        }.disabled(!isVaildSource)
    }
    
    private var cancelButton: some View {
        Button(action: {
            self.viewModel.cancelCreateNewRSS()
            self.onCancelAction?()
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Cancel")
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            Text("SEARCH")//input
            Spacer()
            Button(action: self.fetchDetail) {
                Text("FIND")
                    .padding(.all, 0)
                
            }
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
                Section(header: sectionHeader) {
                    TextFieldView(label: "Feed URL", placeholder: "https://morningreader.com/rss/feed/", text: $feedUrl)
                        .opacity(0.5)
                        .disableAutocorrection(true)
                }
                Section(header: Text("Result")) {
                    if !hasFetchResult {
                        Text("")
                            .opacity(0.3)
                    } else {
                        if viewModel.rss != nil {
                            RSSDisplayView(rss: viewModel.rss!)
                        }
                    }
                }
            }
            .navigationBarTitle("Add Feed")
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
            .preferredColorScheme(.dark)
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

struct AddRSSView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 11")
    }
}
