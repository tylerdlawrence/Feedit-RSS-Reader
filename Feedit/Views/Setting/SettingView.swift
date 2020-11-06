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
    
    @State private var isDarkModeOn = true
    @State private var isSettingsExpanded: Bool = true
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
        HStack {
        NavigationView {
            
            Form {
                Section(header: Text("ACCOUNTS")) {
                    TextField("On My iPhone", text: $accounts)
                    Toggle(isOn: $isPrivate) {
                        Image(systemName: "key.icloud")
                        Text("Private Account")
                    }.toggleStyle(SwitchToggleStyle(tint: .blue))
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
                                Text("Notifications")
                            }.toggleStyle(SwitchToggleStyle(tint: .blue))
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
                                    ForEach([SettingItem.webView], id: \.self) { _ in
                                            Toggle("Reader View", isOn: self.$isSelected)
                                        }.toggleStyle(SwitchToggleStyle(tint: .blue))
                                    }
                                   
                                HStack {
                                    HStack {
                                Image(systemName: "circle.lefthalf.fill")
                                    Toggle("Dark Mode", isOn: $isDarkModeOn)
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
                        Text("Feedit: RSS Reader")
                        Spacer()
                        Text("1.1.6")
                    }
                }
                
                Section {
                    Button(action: {
                        print("Perform an action here...")
                    }) {
                        Text("Reset Settings")
                    }
                }
            }
//            .navigationBarItems(leading: BackButton())

            .onAppear {
                self.isSelected = AppEnvironment.current.useSafari
            }.toggleStyle(SwitchToggleStyle(tint: .blue))
            .onDisappear {
                AppEnvironment.current.useSafari = self.isSelected
            }
            //.shadow(color: .gray, radius: 1, y: 1)
        }
        .foregroundColor(.gray)
        }.navigationBarTitle("Settings", displayMode: .automatic)
    }
}

struct SettingView_Preview: PreviewProvider {
    static var previews: some View {
        SettingView()
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 11")
    }
    
}
