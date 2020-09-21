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
    //^^^
    var body: some View {
        NavigationView {
            List {
                SectionView {
                    Group {
                        HStack {
                            Image(systemName: "safari")
                                .fixedSize()
                            Toggle("Use Safari", isOn: self.$isSelected)
                        }
                        HStack {
                            NavigationLink(destination: self.batchImportView) {
                                HStack {
                                    Image(systemName: "folder")
                                        .fixedSize()
                                    Text("Import File")
                                }
                            }
                        }
                    }
                }
                SectionView {
                    Group {
                        HStack {
                            NavigationLink(destination: self.dataNStorage) {
                                HStack {
                                    Image(systemName: "info.circle")
                                        .fixedSize()
                                    Text("Data and Storage")
                                }
                            }
                        }
                    }
                }
                SectionView {
                    Group {
                        HStack {
                            Image(systemName: "envelope")
                                .fixedSize()
                            Text("Contact")
                        }
                        .onTapGesture {
                            print("tyler.lawrence@hey.com")
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings", displayMode: .inline)
            .environment(\.horizontalSizeClass, .regular)
        }
        .onAppear {
            self.isSelected = AppEnvironment.current.useSafari
        }
        .onDisappear {
            AppEnvironment.current.useSafari = self.isSelected
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingListView()
    }
}



