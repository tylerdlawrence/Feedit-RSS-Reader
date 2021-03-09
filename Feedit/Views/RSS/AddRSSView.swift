//
//  AddRssSource.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import FeedKit
import Valet
import CryptoKit
import CoreData
import Combine
import Introspect
import UIKit
import MobileCoreServices

struct AddRSSView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var viewModel: AddRSSViewModel
    var onDoneAction: (() -> Void)?
    var onCancelAction: (() -> Void)?
    
    private var doneButton: some View {
        Button(action: {
            self.viewModel.commitCreateNewRSS()
            self.onDoneAction?()
            do {
                try self.managedObjectContext.save()
            } catch {
                print(error)
                print(self.feedTitle)
            }
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
    
    private var sectionHeader: some View {
        VStack(alignment: .center) {
            HStack{
                Button(action: self.fetchDetail) {
                    Text("Search").font(.system(size: 17, weight: .medium, design: .rounded)).foregroundColor(Color("text"))
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
                Section(footer: Text("Supports RSS, Atom & JSON").padding(.leading)) {
                    HStack(alignment: .center){
                        Image(systemName: "magnifyingglass")
                            .opacity(0.4)
                            TextField("Feed URL", text: $feedUrl)
                                .disableAutocorrection(true)
                                .keyboardType(.URL)
                                .textContentType(.URL)
                                .opacity(0.4)
                                .padding(.trailing)
                                .multilineTextAlignment(.leading)
                    }
                    HStack(alignment: .center){
                        sectionHeader
                    }
                    
                }
                    if !hasFetchResult {
                        //EmptyView()
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
            .animation(Animation.easeIn(duration: 0.1))
            .animation(Animation.easeIn(duration: 0.5))
        }
        .onDisappear {
            self.viewModel.cancelCreateNewRSS()
        }
    }
    
    func readFromClipboard() {
        UIPasteboard.general.setValue(self.feedUrl,
                                      forPasteboardType: kUTTypePlainText as String)
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



#if DEBUG

struct AddRSSView_Previews: PreviewProvider {
    static var previews: some View {
        AddRSSView(viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss))
            .preferredColorScheme(.dark)
    }
}

#endif
