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
    @State private var isSelected: Bool = false
    var onDoneAction: (() -> Void)?
    @State private var isDarkModeOn = true
    @State private var isSettingsExpanded: Bool = true
    @State var accounts: String = ""
    @State var isPrivate: Bool = false
    @State var notificationsEnabled: Bool = false
    @State private var previewIndex = 0
    @Binding var fetchContentTime: String
    
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
            case .darkMode: return "Dark Mode"
            case .batchImport: return "Import"
            }
        }
    }
            
    var batchImportView: BatchImportView {
        let dataSource = DataSourceService.current.rss
        return BatchImportView(viewModel: BatchImportViewModel(dataSource: dataSource))
    }
    
//    var dataNStorage: DataNStorageView {
//        let storage = DataNStorageView()
//        return storage
//    }
    
    private var doneButton: some View {
        Button(action: {
            self.onDoneAction?()
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Done")
        }
    }
    
    var body: some View {
        VStack {
            NavigationView {
                Form {
//                    Section(header: Text("ACCOUNT")) {
//                        TextField("On My iPhone", text: $accounts)
//                        Toggle(isOn: $isPrivate) {
//                            Image(systemName: "icloud")
//                            Text("iCloud Sync")
//                        }.toggleStyle(SwitchToggleStyle(tint: .blue))
//                    }
//                    Stepper("Quantity: \(quantity)",
//                        value: $quantity,
//                        in: 1...99
//                    )
                    Section(header: Text("")) {
                        Picker(selection: $fetchContentTime, label:
                                Text("Fetch content time")) {
                            ForEach(ContentTimeType.allCases, id: \.self.rawValue) { type in
                                Text(type.rawValue)
                            }
                        }
                        Toggle(isOn: $notificationsEnabled) {
                            Text("Notifications")
                        }
                    }.toggleStyle(SwitchToggleStyle(tint: .blue))
                    Section(header: Text("Feeds")) {
                            Group {
                                HStack {
                                    NavigationLink(destination: self.batchImportView) {
                                            HStack {
                                            Image(systemName: "square.and.arrow.up")
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(.white)
                                                .background(Color("darkShadow"))
                                                .opacity(0.9)
                                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                            Text("Import & Export")
                                            }
                                        }
                                    }
//                                HStack {
//                                    NavigationLink(destination: self.dataNStorage) {
//                                        HStack {
//                                            Image(systemName: "internaldrive")
//                                                .frame(width: 25, height: 25)
//                                                .foregroundColor(.white)
//                                                .background(Color.gray)
//                                                .opacity(0.9)
//                                                .clipShape(RoundedRectangle(cornerRadius: 5))
//                                            Text("Data & Storage")
//                                        }
//                                    }
//                                }
                                HStack {
                                    Image(systemName: "safari")
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.white)
                                        .background(Color("tab"))
                                        .opacity(0.9)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                    ForEach([SettingItem.webView], id: \.self) { _ in
                                            Toggle("Safari Reader", isOn: self.$isSelected)
                                        }.toggleStyle(SwitchToggleStyle(tint: .blue))
                                    }
                                
                                HStack {
                                    Image(systemName: "circle.lefthalf.fill")
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.white)
                                        .background(Color("bg"))
                                        .opacity(0.9)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                    Toggle("Dark Mode", isOn: $isDarkModeOn)
                                }.toggleStyle(SwitchToggleStyle(tint: .blue))
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
                                                .foregroundColor(Color("text"))
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
                                                .foregroundColor(Color("text"))
                                            }
                                        }
                                    }
                            }
                    }
                    Section(header: Text("Copyright © 2021 Tyler D Lawrence"), footer: Text("Feedit version 1.04 build 0.0027")) {
                        Link(destination: URL(string: "https://tylerdlawrence.net")!) {
                            HStack {
                                Image("launch")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .cornerRadius(3.0)
                                Text("Website")
                                    .foregroundColor(Color("text"))
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
//                UITableView.appearance().separatorStyle = .none
                self.isSelected = UserEnvironment.current.useSafari
            }
            .onDisappear {
                UserEnvironment.current.useSafari = self.isSelected
        }
        }
    }
}

struct SettingView_Preview: PreviewProvider {
    static var previews: some View {
        SettingView(fetchContentTime: .constant("minute1"))
    }

}
