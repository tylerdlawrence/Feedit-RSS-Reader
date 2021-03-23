//
//  SettingView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import Foundation
import MessageUI
import CoreMotion
import FeedKit
import CoreData

struct AppIcon: Codable {
    var alternateIconName: String?
    var name: String
    var assetName: String
    var subtitle: String?
}

//struct SettingView: View {
//    var icon: AppIcon
//
//    @EnvironmentObject var settings: Settings
//
//    @AppStorage("darkMode") var darkMode = false
//    @Environment(\.presentationMode) var presentationMode
//    @Environment(\.colorScheme) var colorScheme: ColorScheme
//    @State private var quantity = 1
//    @State private var isSelected: Bool = false
//    var onDoneAction: (() -> Void)?
//    @State private var isDarkModeOn = true
//    @State private var isSettingsExpanded: Bool = true
//    @State var accounts: String = ""
//    @State var isPrivate: Bool = false
//    @State var notificationsEnabled: Bool = false
//    @State private var previewIndex = 0
//    @Binding var fetchContentTime: String
//
//    @State var model = ToggleModel()
//
//    enum ReadMode {
//        case safari
//        case webview
//    }
//
//    enum SettingItem: CaseIterable {
//        case webView
//        case darkMode
//        case batchImport
//
//        var label: String {
//            switch self {
//            case .webView: return "Read Mode"
//            case .darkMode: return "Dark Mode"
//            case .batchImport: return "Import"
//            }
//        }
//    }
//
//    var batchImportView: BatchImportView {
//        let dataSource = DataSourceService.current.rss
//        return BatchImportView(viewModel: BatchImportViewModel(dataSource: dataSource))
//    }
//
////    var dataNStorage: DataNStorageView {
////        let storage = DataNStorageView()
////        return storage
////    }
//
//    private var doneButton: some View {
//        Button(action: {
//            self.onDoneAction?()
//            self.presentationMode.wrappedValue.dismiss()
//        }) {
//            Image(systemName: "xmark")
//        }
//    }
//
//    var body: some View {
//        VStack {
//            NavigationView {
//                Form {
//                    Section(header: Text("")) {
//                        Picker(selection: $fetchContentTime, label:
//                                Text("Fetch content time")) {
//                            ForEach(ContentTimeType.allCases, id: \.self.rawValue) { type in
//                                Text(type.rawValue)
//                            }
//                        }
//                        Toggle(isOn: $notificationsEnabled) {
//                            Text("Notifications")
//                        }
//                    }.toggleStyle(SwitchToggleStyle(tint: .blue))
//
//                    Section(header: Text("Feeds")) {
//                        Group {
//                            HStack {
//                                Image(systemName: "circle.lefthalf.fill")
//                                    .frame(width: 25, height: 25)
//                                    .foregroundColor(.white)
//                                    .background(Color("bg"))
//                                    .opacity(0.9)
//                                    .clipShape(RoundedRectangle(cornerRadius: 5))
//                                Toggle(isOn: $darkMode) {
//                                             Text("Appearence")
//                                        }
//                                .toggleStyle(ToggleAppearence())
//                            }
//
//                            HStack {
//                                Image(systemName: "safari")
//                                    .frame(width: 25, height: 25)
//                                    .foregroundColor(.white)
//                                    .background(Color("tab"))
//                                    .opacity(0.9)
//                                    .clipShape(RoundedRectangle(cornerRadius: 5))
//                                ForEach([SettingItem.webView], id: \.self) { _ in
//                                        Toggle("Safari Reader", isOn: self.$isSelected)
//                                    }
//                                }.toggleStyle(SwitchToggleStyle(tint: .blue))
//
//                            HStack {
//                                NavigationLink(destination: self.batchImportView) {
//                                        HStack {
//                                        Image(systemName: "square.and.arrow.up")
//                                            .frame(width: 25, height: 25)
//                                            .foregroundColor(.white)
//                                            .background(Color("darkShadow"))
//                                            .opacity(0.9)
//                                            .clipShape(RoundedRectangle(cornerRadius: 5))
//                                        Text("Import & Export")
//                                        }
//                                    }
//                                }
//                            }
//                        }
//
//                    Section(header: Text("About")) {
//                        Group {
//                            HStack {
//                                Link(destination: URL(string: "https://github.com/tylerdlawrence/Feedit-RSS-Reader")!) {
//                                        HStack {
//                                            Image("github")
//                                                .resizable()
//                                                .aspectRatio(contentMode: .fit)
//                                                .frame(width: 25, height: 25)
//                                                .cornerRadius(3.0)
//                                        Text("GitHub")
//                                            .foregroundColor(Color("text"))
//                                        }
//                                    }
//                                }
//                            HStack {
//                                Link(destination: URL(string: "https://twitter.com/FeeditRSSReader")!) {
//                                        HStack {
//                                            Image("twitter")
//                                                .resizable()
//                                                .aspectRatio(contentMode: .fit)
//                                                .frame(width: 25, height: 25)
//                                                .cornerRadius(3.0)
//                                        Text("Twitter")
//                                            .foregroundColor(Color("text"))
//                                        }
//                                    }
//                                }
//                        }
//                    }
//                    Section(header: Text("Copyright © 2021 Tyler D Lawrence"), footer: Text("Feedit version 1.04 build 0.0027")) {
//                        Link(destination: URL(string: "https://tylerdlawrence.net")!) {
//                            HStack {
//                                Image("launch")
//                                    .resizable()
//                                    .frame(width: 35, height: 35)
//                                    .cornerRadius(3.0)
//                                Text("Website")
//                                    .foregroundColor(Color("text"))
//                            }
//                        }
//                    }
//                }
//                .listStyle(GroupedListStyle())
//                .navigationBarTitle("Settings", displayMode: .automatic)
//                .navigationBarItems(leading: doneButton)
//                .environment(\.horizontalSizeClass, .regular)
//                .preferredColorScheme(darkMode ? .dark : .light)
//            }
//            .onAppear {
//                self.isSelected = UserEnvironment.current.useSafari
//            }
//            .onDisappear {
//                UserEnvironment.current.useSafari = self.isSelected
//            }
//        }
//    }
//}

//struct SettingView_Preview: PreviewProvider {
//    static var previews: some View {
//        SettingView(icon: icon, fetchContentTime: .constant("minute1"))
//    }
//}

struct AccentColorChooserView: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        List {
            ForEach([settings.defaultAccentColor, UIColor.black, UIColor.white, UIColor.systemRed, UIColor.systemBlue, UIColor.systemGreen, UIColor.systemGray, UIColor.systemYellow, UIColor.systemTeal, UIColor.systemOrange, UIColor.systemPurple, UIColor.systemIndigo], id: \.self) { color in
                ColorIconView(color: color)
            }
        }.navigationTitle("Accent Color").listStyle(GroupedListStyle())
    }
}

struct AppIconView: View {
    var icon: AppIcon
    
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        let path = Bundle.main.resourcePath! + "/" + icon.assetName
        HStack {
            Image(uiImage: UIImage(contentsOfFile: path)!).mask(Image(systemName: "app.fill").resizable().aspectRatio(contentMode: .fit))
            VStack(alignment: .leading) {
                Text("\(icon.name)").foregroundColor(Color(UIColor.label))
                if let subtitle = icon.subtitle {
                    Text("\(subtitle)").foregroundColor(.gray)
                        .font(Font(.subheadline, sizeModifier: CGFloat(settings.textSizeModifier)))
                }
            }
            
            if settings.alternateIconName == icon.alternateIconName {
                Spacer()
                Text("\(Image(systemName: "checkmark"))").bold().foregroundColor(.accentColor)
            }
        }
    }
}

struct AppIconChooserView: View {
    @EnvironmentObject var settings: Settings
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var showAlert = false
    var body: some View {
        List {
            Button(action: {
                UIApplication.shared.setAlternateIconName(nil, completionHandler: {error in
                    guard error == nil else {
                        // show error
                        return
                    }
                    settings.alternateIconName = nil
                    try? settings.managedObjectContext?.save()
                    self.presentationMode.wrappedValue.dismiss()
                })
            }, label: {
                AppIconView(icon: AppIcon(alternateIconName: nil, name: "Feedit", assetName: "feedit@2x.png", subtitle: "")).environmentObject(settings)
            })
            Button(action: {
                UIApplication.shared.setAlternateIconName("bot", completionHandler: { error in
                    guard error == nil else {
                        showAlert = true
                        return
                    }
                    settings.alternateIconName = "bot"
                    try? settings.managedObjectContext?.save()
                    self.presentationMode.wrappedValue.dismiss()
                })
            }, label: {
                AppIconView(icon: AppIcon(alternateIconName: "bot", name: "Feed Bot", assetName: "bot@2x.png")).environmentObject(settings)
            })
        }.listStyle(GroupedListStyle()).navigationTitle("App Icon").alert(isPresented: $showAlert, content: {
            Alert(title: Text("Error"), message: Text("Unable to set icon. Try again later."), dismissButton: .default(Text("Okay")))
        })
    }
}

struct ColorIconView: View {
    var color: UIColor

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        Button(action: {
            settings.accentColorData = color.data
            try? settings.managedObjectContext?.save()
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            HStack {
                Image(systemName: "app.fill").foregroundColor(Color(color))
                Text("\(color.name ?? "Unkown")").foregroundColor(Color(UIColor.label))
                if settings.accentColor == Color(color) {
                    Spacer()
                    Text("\(Image(systemName: "checkmark"))").bold().foregroundColor(.accentColor)
                }
            }
        })
    }
}

struct SettingView: View {
    @State var mailResult: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    @State var isShowingMailViewAlert = false
    
    var twitterURL: URL {
        let twitter = URL(string: "twitter://user?screen_name=FeeditRSSReader")!
       
        if UIApplication.shared.canOpenURL(twitter) {
            return twitter
        }
        
        return URL(string: "https://twitter.com/FeeditRSSReader")!
    }
    
    var emailSubject: String {
        return
             "feedit v" + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
    }
    
    @AppStorage("darkMode") var darkMode = false
    @EnvironmentObject var settings: Settings
    @Environment(\.sizeCategory) var sizeCategory
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var quantity = 1
    @State private var isSelected: Bool = false
    var onDoneAction: (() -> Void)?
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
    
    var dataNStorage: DataNStorageView {
        let storage = DataNStorageView()
        return storage
    }

    private var doneButton: some View {
        Button(action: {
            self.onDoneAction?()
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Appearance")
                            .font(Font(.footnote))) {
                    
                    if UIApplication.shared.supportsAlternateIcons {
                        
                        NavigationLink(destination: AppIconChooserView().environmentObject(settings)
                                       , label: {
                            HStack {
                                Label(
                                    title: { Text("App Icon").foregroundColor(Color(UIColor.label)) },
                                    icon: { ZStack {
                                        Image(systemName: "app.fill").resizable().aspectRatio( contentMode: .fit).foregroundColor(settings.accentColor)
                                        
                                        Image(uiImage: UIImage(contentsOfFile: Bundle.main.resourcePath! + "/" + (settings.alternateIconName ?? "feedit") + "@2x.png")!).resizable().aspectRatio( contentMode: .fit).mask(Image(systemName: "app.fill").resizable().aspectRatio(contentMode: .fit))
                                    } }
                        ).labelStyle(HorizontallyAlignedLabelStyle())
                                
                                Spacer()
                                Text("\(settings.alternateIconName ?? "Default")").foregroundColor(.gray)
                            }
                        })
                    }
                    
                    NavigationLink(destination: AccentColorChooserView().environmentObject(settings), label: {
                        HStack {
                            ZZLabel(iconBackgroundColor: settings.accentColor, iconColor: settings.accentUIColor == .white ? .black : .white, systemImage: "paintbrush.fill", text: "Accent Color")
                            Spacer()
                            Text("\(settings.accentUIColor.name ?? "Feedit Blue")").foregroundColor(.gray)
                        }
                    })
                    
                    HStack {
                        SettingsTextSizeSlider().environmentObject(settings)
                    }
                    
                }
                Section(header: Text("Layout").font(Font(.footnote, sizeModifier: CGFloat(settings.textSizeModifier)))) {
                    SettingsLayoutSlider().environmentObject(settings)
                }
                
                Section(header: Text("Feeds")) {
                    Picker(selection: $fetchContentTime, label:
                            Text("Fetch content time")) {
                        ForEach(ContentTimeType.allCases, id: \.self.rawValue) { type in
                            Text(type.rawValue)
                        }
                    }
                    Toggle(isOn: $notificationsEnabled) {
                        Text("Notifications")
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))

                    HStack {
                        Image(systemName: "safari")
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .background(Color("tab"))
                            .opacity(0.9)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        ForEach([SettingItem.webView], id: \.self) { _ in
                                Toggle("Safari Reader", isOn: self.$isSelected)
                            }
                        }.toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    HStack {
                        Image(systemName: "circle.lefthalf.fill")
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .background(Color("bg"))
                            .opacity(0.9)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        Toggle(isOn: $darkMode) {
                                     Text("Light/Dark Mode")
                                }
                        .toggleStyle(ToggleAppearence())
                    }

                    HStack {
                        NavigationLink(destination: self.batchImportView) {
                                HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                    .background(Color("darkShadow"))
                                    .opacity(0.9)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                Text("Import & Export")
                                }
                            }
                        }
                    HStack {
                        NavigationLink(destination: self.dataNStorage) {
                            HStack {
                                Image(systemName: "tray.full")
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                    .background(Color("tab"))
                                    .opacity(0.9)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                Text("Data Storage")
                            }
                        }
                    }
                    }
                
                Section {
                    SettingsLinkView(image: "github", text: "GitHub", url: "https://github.com/tylerdlawrence/Feedit-RSS-Reader", iconColor: .black)
                    SettingsLinkView(image: "twitter", text: "Twitter", url: twitterURL.absoluteString, iconColor: .blue)
                    if MFMailComposeViewController.canSendMail() {
                        Button(action: {
                            self.isShowingMailView.toggle()
                        }, label: {
                            ZZLabel(iconBackgroundColor: .red, iconColor: .white, systemImage: "at", text: "Contact")
                        })
                    } else {
                        Button(action: {
                            self.isShowingMailViewAlert.toggle()
                        }, label: {
                            ZZLabel(iconBackgroundColor: .red, iconColor: .white, systemImage: "at", text: "Contact")
                        }).alert(isPresented: $isShowingMailViewAlert, content: {
                            Alert(title: Text("Email"), message: Text("tyler.lawrence@hey.com"), dismissButton: .default(Text("Okay")))
                        })
                    }
                    SettingsLinkView(systemImage:  "star.fill", text: "Rate", url: "https://apps.apple.com/us/app/feedit/id1527181959", iconColor: .yellow)
                }
//                Section(header: Text("Legal").font(Font(.footnote, sizeModifier: CGFloat(settings.textSizeModifier)))) {
//                    SettingsLinkView(systemImage: "doc.text.magnifyingglass", text: "Privacy Policy", url: "https://tylerdlawrence.net", iconColor: .gray)
//                    SettingsLinkView(systemImage: "doc.text", text: "Terms of Use", url: "https://tylerdlawrence.net", iconColor: .gray)
//                }
                
                Section(header: Text("Copyright © 2021 Tyler D Lawrence"), footer:  Text("Feedit V" + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String))) {
                    Link(destination: URL(string: "https://tylerdlawrence.net")!) {
                        HStack {
                            Image("launch").resizable().frame(width: 35, height: 35).cornerRadius(3.0)
                            Text("Website").foregroundColor(Color("text"))
                            
                        }
                    }
                }
            }.sheet(isPresented: $isShowingMailView) {
                MailView(isShowing: self.$isShowingMailView, result: self.$mailResult, subject: emailSubject, toReceipt: ["tyler.lawrence@hey.com"])
            }.listStyle(InsetGroupedListStyle()
            ).navigationTitle("Settings")
            .navigationBarItems(leading: doneButton)
            .environment(\.horizontalSizeClass, .regular)
            .preferredColorScheme(darkMode ? .dark : .light)
        }.environmentObject(settings)
        .onAppear {
            self.isSelected = UserEnvironment.current.useSafari
        }
        .onDisappear {
            UserEnvironment.current.useSafari = self.isSelected
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingView(fetchContentTime: .constant("minute1"))
                .environment(\.managedObjectContext, PersistenceController.random.container.viewContext).environmentObject(Settings(context: PersistenceController.random.container.viewContext))
        }.previewLayout(.sizeThatFits)

    }
}

struct SettingsLayoutSlider: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settings: Settings
    
    @StateObject var rss = RSS()
    @EnvironmentObject var rssFeedViewModel: RSSFeedViewModel
    
    @EnvironmentObject private var persistence: Persistence
    @EnvironmentObject var rssDataSource: RSSDataSource
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(1..<3) { _ in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Image("launch")
                                    .renderingMode(.original).resizable().aspectRatio(contentMode: .fit).frame(width: 25, height: 25, alignment: .center).cornerRadius(3).opacity(0.9)
                            }
                            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque ultrices sed nulla nec blandit. Suspendisse in facilisis velit.").font(Font(.body, sizeModifier: CGFloat(settings.textSizeModifier)))
                                .environmentObject(settings).allowsHitTesting(false)
                        }
                        Divider().padding(0).padding([.leading])
                    }
                }.environmentObject(settings)
            }.listStyle(PlainListStyle()).frame(height: 175).padding(0).allowsHitTesting(false).overlay(Rectangle().foregroundColor(.clear).opacity(0.0).background(LinearGradient(gradient: Gradient(colors: [Color(UIColor.secondarySystemGroupedBackground.withAlphaComponent(0.0)), Color(UIColor.secondarySystemGroupedBackground.withAlphaComponent(0.0)), Color(UIColor.secondarySystemGroupedBackground)]), startPoint: .top, endPoint: .bottom)))
            Divider().padding([.bottom], 8.0)
            HStack {
                Image(systemName: "doc.plaintext").renderingMode(.template).foregroundColor(.accentColor)
                Picker("Story Cell Layout", selection: $settings.layoutValue, content: {
                    Text("Compact").tag(Settings.Layout.compact.rawValue)
                    Text("Comfortable").tag(Settings.Layout.comfortable.rawValue)
                    Text("Default").tag(Settings.Layout.Default.rawValue)
                }).pickerStyle(SegmentedPickerStyle())
                Image(systemName: "doc.richtext").renderingMode(.template).foregroundColor(.accentColor)
            }
        }
    }
}

struct ZZLabel: View {
    var iconBackgroundColor: Color = Color.accentColor
    var iconColor: Color = Color.white
    var systemImage: String? = nil
    var image: String? = nil
    var imageFile: String? = nil
    var text: String
    var iconScale = 0.6
    
    var body: some View {
        Label(
            title: { Text(text).foregroundColor(Color(UIColor.label)) },
            icon: { ZStack {
                Image(systemName: "app.fill").resizable().aspectRatio( contentMode: .fit).foregroundColor(self.iconBackgroundColor)
                if let path = imageFile, let uiImage = UIImage(contentsOfFile: path) {
                    Image(uiImage: uiImage).resizable().aspectRatio( contentMode: .fit).scaleEffect(CGSize(width: iconScale, height: iconScale)).foregroundColor(self.iconColor)
                }
                else if let name = image {
                    Image(name).resizable().aspectRatio( contentMode: .fit).scaleEffect(CGSize(width: iconScale, height: iconScale)).foregroundColor(self.iconColor)
                } else {
                    Image(systemName: systemImage ?? "xmark.square").resizable().aspectRatio( contentMode: .fit).scaleEffect(CGSize(width: iconScale, height: iconScale)).foregroundColor(self.iconColor)
                }
            } }
).labelStyle(HorizontallyAlignedLabelStyle())
    }
}

struct HorizontallyAlignedLabelStyle: LabelStyle {
    ///https://www.hackingwithswift.com/forums/swiftui/vertical-align-icon-of-label/3346
    @Environment(\.sizeCategory) var size
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center) {
            if size >= .accessibilityMedium {
                configuration.icon
                    .frame(width: 80)
            } else {
                configuration.icon
                    .frame(width: 30)
            }
            configuration.title
        }
    }
}

struct SettingsLinkView: View {
    var systemImage: String? = nil
    var image: String? = nil
    var text: String
    var url: String
    var iconColor: Color = Color.accentColor
    
    var body: some View {
            Button(action: {
                UIApplication.shared.open(URL(string: url)!)
            }, label: {
                ZZLabel(iconBackgroundColor: iconColor, iconColor: .white, systemImage: systemImage, image: image, text: text)
        })
    }
}

struct SettingsTextSizeSlider: View {
    @EnvironmentObject var settings: Settings
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack {
            HStack {
                ZZLabel(iconBackgroundColor: Color(UIColor.darkGray), systemImage: "textformat.size", text: "Text Size")
                Spacer()
                if settings.textSizeModifier == 0 {
                    Text("System Size").foregroundColor(.gray)
                } else if settings.textSizeModifier > 0 {
                    Text("System Size +\(String(format: "%.1f", settings.textSizeModifier))").foregroundColor(.gray)
                } else {
                    Text("System Size \(String(format: "%.1f", settings.textSizeModifier))").foregroundColor(.gray)
                }
            }
            HStack {
                Button(action: {
                    if settings.textSizeModifier >= -5.0 {
                        settings.textSizeModifier -= 1.0
                    }
                    
                }, label: {
                    Text("\(Image(systemName: "minus"))").foregroundColor(.accentColor).font(.body)
                }).buttonStyle(BorderlessButtonStyle())
                
                Slider(value: $settings.textSizeModifier, in: -6.0...6.0, step: 0.5).zIndex(1.0)
                
                Button(action: {
                    if settings.textSizeModifier <= 5.0 {
                        settings.textSizeModifier += 1.0
                    }
                }, label: {
                    Text("\(Image(systemName: "plus"))").foregroundColor(.accentColor).font(.body)
                }).buttonStyle(BorderlessButtonStyle())
            }
        }
    }
}
