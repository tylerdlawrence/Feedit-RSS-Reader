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
    @AppStorage("darkMode") var darkMode = false
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
    
//    var group: RSSGroup
//    @Binding var selection: Set<RSSGroup>

//    init(viewModel: AddRSSViewModel,
//         onDoneAction: (() -> Void)? = nil,
//         onCancelAction: (() -> Void)? = nil, group: RSSGroup, selection: Set<RSSGroup>) {
//        self.viewModel = viewModel
//        self.onDoneAction = onDoneAction
//        self.onCancelAction = onCancelAction
//        self.group = group
//        self.selection = selection
//    }
    
    @EnvironmentObject private var persistence: Persistence
    @EnvironmentObject var rss: RSS
//    let rss = RSS()
    @State var groupPickerIsPresented = false
    
    private var addFolderButton: some View {
        Button(action: { groupPickerIsPresented.toggle() }) {
          Image(systemName: "tray.and.arrow.down.fill")
        }
    }
    
    private var trailingButtons: some View {
        HStack(alignment: .top, spacing: 24) {
            addFolderButton
            doneButton
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text("Supports RSS, Atom & JSON")) {
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
                
                NavigationLink(destination:
                                RSSGroupListView(persistence: Persistence.current, viewModel: RSSListViewModel(dataSource: DataSourceService.current.rss, unreadCount: 0))
                                .environment(\.managedObjectContext, Persistence.current.context)
                                .environmentObject(Persistence.current)) {
                    Label("Manage Folders", systemImage: "folder.badge.plus")
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
            .sheet(isPresented: $groupPickerIsPresented) {
                SelectGroupView(selectedGroups: (rss.groups as? Set<RSSGroup>) ?? []) {
                setGroups($0)
                groupPickerIsPresented = false
            }
        }
            .navigationBarTitle("Add Feed")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
//            .preferredColorScheme(darkMode ? .dark : .light)
            .animation(Animation.easeIn(duration: 0.1))
            .animation(Animation.easeIn(duration: 0.5))
            
        }
        .onDisappear {
            self.viewModel.cancelCreateNewRSS()
        }
    }
    
//    private func formAction() {
//      onComplete(name.isEmpty ? "Untitled Folder" : name)
//    }
    
    private func setGroups(_ groups: Set<RSSGroup>) {
      rss.groups = groups as NSSet
      persistence.saveChanges()
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

    static var group: RSSGroup = {
      let controller = Persistence.current
        return controller.makeRandomFolder(context: controller.context)
    }()

    @State static var selection: Set<RSSGroup> = [group]

    static var previews: some View {
        AddRSSView(viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss))
            .environment(\.managedObjectContext, Persistence.current.context)
            .environmentObject(Persistence.current)
            .preferredColorScheme(.dark)
    }
}

#endif
