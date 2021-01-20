//
//  SettingView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import FeedKit
import CoreData
import Foundation

struct SettingView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var quantity = 1


    enum ReadMode {
        case safari
        case webview
    }
    
    enum SettingItem: CaseIterable {
        case webView
        case darkMode
        case batchImport
        
        var label: String {
            switch self {
            case .webView: return "Read Mode"
            case .darkMode: return "Outlook"
            case .batchImport: return "Import RSS Sources"
            }
        }
    }
    
    @State private var isSelected: Bool = false
        
    var batchImportView: BatchImportView {
        let dataSource = DataSourceService.current.rss
        return BatchImportView(viewModel: BatchImportViewModel(dataSource: dataSource))
    }
    
    var dataNStorage: DataNStorageView {
        let storage = DataNStorageView()
        return storage
    }
    
    private var doneButton: some View {
        Button(action: {
            self.onDoneAction?()
            self.presentationMode.wrappedValue.dismiss()
                
        }) {
            Text("Done")
        }
    }
    var onDoneAction: (() -> Void)?

    @State private var isDarkModeOn = true
    @State private var isSettingsExpanded: Bool = true
    @State var accounts: String = ""
    @State var isPrivate: Bool = false
    @State var notificationsEnabled: Bool = false
    @State private var previewIndex = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("ACCOUNT")) {
                    TextField("On My iPhone", text: $accounts)
                    Toggle(isOn: $isPrivate) {
                        Image(systemName: "icloud")
                        Text("iCloud Sync")
                    }.toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                
                Stepper("Quantity: \(quantity)",
                    value: $quantity,
                    in: 1...99
                )

//                Section(header: Text("DATA")) {
//                    Group {
//                        HStack {
//                            NavigationLink(destination: self.dataNStorage) {
//                                HStack {
//                                    Image(systemName: "internaldrive")
//                                        .fixedSize()
//                                    Text("Data & Storage")
//                                }
//                            }
//                        }

//                    Group {
//                        HStack {
//                            Image(systemName: "app.badge")
//                                fixedSize()
//                            Toggle(isOn: $notificationsEnabled) {
//                                Text("Notifications")
//                            }.toggleStyle(SwitchToggleStyle(tint: .blue))
//                        }
//                    }
                //}
            //}
                Section(header: Text("Feeds")) {
                        Group {
                            HStack {
                                NavigationLink(destination: self.batchImportView) {
                                        HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        .fixedSize()
                                        Text("Import & Export")
                                        }
                                    }
                                }
//                            HStack {
//                                NavigationLink(destination: self.dataNStorage) {
//                                    HStack {
//                                        Image(systemName: "internaldrive")
//                                            .fixedSize()
//                                        Text("Data & Storage")
//                                    }
//                                }
//                            }
                            HStack {
                                Image(systemName: "safari")
                                    .fixedSize()
                                ForEach([SettingItem.webView], id: \.self) { _ in
                                        Toggle("Safari View", isOn: self.$isSelected)
                                    }.toggleStyle(SwitchToggleStyle(tint: .blue))
                                }
                            }
                        }
                
                Section(header: Text("About")) {
                        Group {
                            HStack {
                                Link(destination: URL(string: "https://github.com/tylerdlawrence/Feedit-RSS-Reader")!) {
                                        HStack {
                                            Image("github")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 25, height: 25)
                                                .cornerRadius(3.0)
                                        Text("GitHub")
                                        }
                                    }
                                }
                            HStack {
                                Link(destination: URL(string: "https://twitter.com/FeeditRSSReader")!) {
                                        HStack {
                                            Image("twitter")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 25, height: 25)
                                                .cornerRadius(3.0)
                                        Text("Twitter")
                                        }
                                    }
                                }

                        }
                }
//
//                                HStack {
//                                    HStack {
//                                Image(systemName: "circle.lefthalf.fill")
//                                    Toggle("Dark Mode", isOn: $isDarkModeOn)
//                                    }.toggleStyle(SwitchToggleStyle(tint: .blue))
//                                }
//                            }
//                        }
                Section(header: Text("Copyright © 2021 Tyler D Lawrence"), footer: Text("Feedit version 1.04 build 0.0027")) {
                    Link(destination: URL(string: "https://tylerdlawrence.net")!) {
                        HStack {
                            Image("launch")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .cornerRadius(3.0)
                            Text("Website")
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings", displayMode: .automatic)
            .navigationBarItems(trailing: doneButton)
            .environment(\.horizontalSizeClass, .regular)
        }
        .onAppear {
            UITableView.appearance().separatorStyle = .none
            self.isSelected = AppEnvironment.current.useSafari
        }
        .onDisappear {
            AppEnvironment.current.useSafari = self.isSelected
        }
    }
}

struct SettingView_Preview: PreviewProvider {
    static var previews: some View {
        SettingView()
    }

}
