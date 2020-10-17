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

struct SettingListView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
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
    @State var accounts: String = ""
    @State var isPrivate: Bool = true
    @State var notificationsEnabled: Bool = false
    @State private var previewIndex = 0

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("ACCOUNTS")) {
                    TextField("On My iPhone", text: $accounts)
                    Toggle(isOn: $isPrivate) {
                        Image(systemName: "key.icloud")
                        Text("Private Account")
                    }
                }
                
                Section(header: Text("DATA & Notifications")) {
                    Group {
                        HStack {
                            NavigationLink(destination: self.dataNStorage) {
                                HStack {
                                    Image(systemName: "internaldrive")
                                        .fixedSize()
                                    Text("Data & Storage")
                                }
                            }
                        }
                            
                    Group {
                        HStack {
                            Image(systemName: "circlebadge.2")
                                fixedSize()
                            Toggle(isOn: $notificationsEnabled) {
                                Text("Notification Badges")
                            }
                        }
                    }
                }
            }
                Section(header: Text("FEEDS")) {
                        Group {
                            HStack {
                                NavigationLink(destination: self.batchImportView) {
                                        HStack {
                                        Image(systemName: "square.and.arrow.down")
                                        .fixedSize()
                                        Text("Import")
                                        }
                                    }
                                }
                            }
                        }

                Section(header: Text("READING & APPEARENCE")) {
                            Group {
                            //padding()
                                HStack {
                                    Image(systemName: "safari")
                                        .fixedSize()
                                    Toggle("Reader View", isOn: self.$isSelected)
                                }
                                //padding()
                                HStack {
                                    HStack {
                                        Image(systemName: "circle.lefthalf.fill")
                                                .fixedSize()
                                        Toggle("Appearance", isOn: self.$isSelected)
                                        
                                        }
                                    }
                                }
                        }
                        

                    //Picker(selection: $previewIndex, label: Text("Show Previews")) {
                        //ForEach(0 ..< previewOptions.count) {
                            //Text(self.previewOptions[$0])
                        //}
                    //}
                //}
                
                Section(header: Text("ABOUT")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.1.4")
                    }
                }
                
                Section {
                    Button(action: {
                        print("Perform an action here...")
                    }) {
                        Text("Reset All Settings")
                    }
                }
            }.navigationBarTitle("Settings")

            
        }
    }
    
}

struct SettingView_Preview: PreviewProvider {
    static var previews: some View {
        SettingListView()
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 11")
        //.preferredColorScheme(.dark)
    }
    
}
