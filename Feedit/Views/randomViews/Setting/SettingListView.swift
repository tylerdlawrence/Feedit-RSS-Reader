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
////////////////////////
    enum Appearance {
        case light
        case dark
    }
    
    enum AppearanceItem: CaseIterable {
        case lightMode
        case darkMode
        
        var label: String {
            switch self {
            case .lightMode: return "Light"
            case .darkMode: return "Dark"
            }
        }
    }
////////////////////////
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
                            NavigationLink(destination: self.batchImportView) {
                                HStack {
                                    Image(systemName: "folder")
                                        .fixedSize()
                                    Text("Import")
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
                padding()
                SectionView {
                    Group {
                        //padding()
                        HStack {
                            Image(systemName: "safari")
                                .fixedSize()
                            Toggle("Reader View", isOn: self.$isSelected)
                        }
                        padding()
                        HStack {
                            HStack {
                                Image(systemName: "circle.lefthalf.fill")
                                        .fixedSize()
                                Toggle("Appearance", isOn: self.$isSelected)
                                
                                }
                            }
                        }
                    }
                
                
//                SectionView {
//                    Group {
//                        HStack {
//                            Image(systemName: "envelope")
//                                .fixedSize()
//                            Text("Contact")
//                        }
//                        .onTapGesture {
//                            print("tyler.lawrence@hey.com")
//                        }
//                    }
//                }
            }
            .listStyle(InsetListStyle())
            .navigationBarTitle("Settings", displayMode: .automatic)
            .environment(\.horizontalSizeClass, .regular)
    
    .onAppear {
        self.isSelected = AppEnvironment.current.useSafari
    }
    .onDisappear {
        AppEnvironment.current.useSafari = self.isSelected
    }
            
        }
    }
}


struct SettingView_Preview: PreviewProvider {
    static var previews: some View {
        SettingListView()
            .preferredColorScheme(.dark)
        .previewDevice("iPhone 11 Pro Max")
        //.preferredColorScheme(.dark)
    }
    
}

