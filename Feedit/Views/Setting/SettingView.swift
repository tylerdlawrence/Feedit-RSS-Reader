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
import ModalView

struct SettingView: View {
    
//    @ObservedObject var settingViewModel: SettingViewModel

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
    
    @State private var isDarkModeOn = true
    @State private var isSettingsExpanded: Bool = true
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
                        Image(systemName: "icloud")
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
                                    }.toggleStyle(SwitchToggleStyle(tint: .blue))
                                }
                            }
                        }
                HStack(alignment: .center) {
                        Image("launch")
                            .resizable()
                            .frame(width: 35, height: 35)
                        Text("Feedit")
                        Text("version 1.01")
                        Text("build 0.0020")
                }
//                HStack(alignment: .center) {
//                    Text("  created by Tyler D Lawrence")
//                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings", displayMode: .automatic)
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

//struct SettingView_Preview: PreviewProvider {
//    static var previews: some View {
//        SettingView
//    }
//
//}
