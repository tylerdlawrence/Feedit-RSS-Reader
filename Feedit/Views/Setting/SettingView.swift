//
//  SettingView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import CoreMotion
import FeedKit
import CoreData
import Foundation

struct SettingView: View {
    @AppStorage("darkMode") var darkMode = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme: ColorScheme
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
    
    @State var model = ToggleModel()
    
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
            Image(systemName: "xmark")
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
                                Image(systemName: "circle.lefthalf.fill")
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                                    .background(Color("bg"))
                                    .opacity(0.9)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                Toggle(isOn: $darkMode) {
                                             Text("Appearence")
                                        }
                                .toggleStyle(ToggleAppearence())
                            }
                                
                            HStack {
                                Image(systemName: "safari")
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                                    .background(Color("tab"))
                                    .opacity(0.9)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                ForEach([SettingItem.webView], id: \.self) { _ in
                                        Toggle("Safari Reader", isOn: self.$isSelected)
                                    }
                                }.toggleStyle(SwitchToggleStyle(tint: .blue))
                                
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
                .navigationBarItems(leading: doneButton)
                .environment(\.horizontalSizeClass, .regular)
                .preferredColorScheme(darkMode ? .dark : .light)
            }
            .onAppear {
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

enum Vibration {
    case error
    case success
    case light
    case selection
    
    func vibrat(){
        switch self {
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
}

class MotionManager: ObservableObject {
    let motionManager = CMMotionManager()
    
    @Published var x: CGFloat = 0
    @Published var y: CGFloat = 0
    @Published var z: CGFloat = 0
    
    init() {
        motionManager.startDeviceMotionUpdates(to: .main){ data, _ in
            guard let tilt = data?.gravity else { return }
            
            self.x = CGFloat(tilt.x)
            self.y = CGFloat(tilt.y)
            self.z = CGFloat(tilt.z)
        }
    }
}

struct DarkmModeSettingView: View {
    
    @Binding var darkMode: Bool
    
    var body: some View {
        Button(action:{
            Vibration.selection.vibrat()
            darkMode.toggle()
        }){
            Image(systemName: darkMode ? "sun.max.fill" : "moon.fill")
                .imageScale(.medium)
                .foregroundColor(Color("tab"))
                .font(.system(size: 20, weight: .regular, design: .default))
        }
    }
}

struct DarkmModeSettingView_Previews: PreviewProvider {
    static var previews: some View {
        DarkmModeSettingView(darkMode: .constant(false))
    }
}

