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
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var viewModel: AddRSSViewModel
    var onDoneAction: (() -> Void)?
    var onCancelAction: (() -> Void)?
    
    private var doneButton: some View {
        Button(action: {
            self.viewModel.commitCreateNewRSS()
            self.onDoneAction?()
            do {
                try self.managedObjectContext.save()
            } catch {
                print(error)
                print(self.feedTitle)
            }
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
                    Text("Search").font(.system(size: 17, weight: .medium, design: .rounded))
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

    init(viewModel: AddRSSViewModel,
         onDoneAction: (() -> Void)? = nil,
         onCancelAction: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onDoneAction = onDoneAction
        self.onCancelAction = onCancelAction
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text("Supports RSS, Atom & JSON").padding(.leading)) {
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
            .navigationBarTitle("Add Feed")
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
            .animation(Animation.easeIn(duration: 0.1))
            .animation(Animation.easeIn(duration: 0.5))
        }
        .onDisappear {
            self.viewModel.cancelCreateNewRSS()
        }
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
    static var previews: some View {
        AddRSSView(viewModel: AddRSSViewModel(dataSource: DataSourceService.current.rss))
            .preferredColorScheme(.dark)
    }
}

#endif



struct WideButton: View {
    
    var action: () -> Void
    var label: Label<Text, Image>
    var backgroundColor: UIColor
    
    init(_ label: Label<Text, Image>, backgroundColor: UIColor = .tertiarySystemBackground, action: @escaping () -> Void) {
        self.action = action
        self.label = label
        self.backgroundColor = backgroundColor
    }
    
    init(_ label: Label<Text, Image>, backgroundColor: UIColor = .tertiarySystemBackground, withAnimation animation: Animation?, action: @escaping () -> Void) {
        self.action = { withAnimation(animation, action) }
        self.label = label
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            label.roundedRectangleBackground(color: backgroundColor)
        }.buttonStyle(SquashableButtonStyle())
    }
}

extension WideButton {
    init(_ titleKey: LocalizedStringKey, systemImage iconName: String, backgroundColor: UIColor = .tertiarySystemBackground, action: @escaping () -> Void) {
        self.action = action
        self.label = Label(titleKey, systemImage: iconName)
        self.backgroundColor = backgroundColor
    }
    
    init(_ titleKey: LocalizedStringKey, systemImage iconName: String, backgroundColor: UIColor = .tertiarySystemBackground, withAnimation animation: Animation?, action: @escaping () -> Void) {
        self.action = { withAnimation(animation, action) }
        self.label = Label(titleKey, systemImage: iconName)
        self.backgroundColor = backgroundColor
    }
}

struct SquashableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.75 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

extension View {
    func roundedRectangleBackground(color uiColor: UIColor = .tertiarySystemBackground) -> some View {
        self.font(Font.body.weight(.semibold))
            .foregroundColor(.accentColor)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct ButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}

extension URL {
    var components: URLComponents? {
        URLComponents(url: self, resolvingAgainstBaseURL: false)
    }
}

enum RSSHub {
    static var defaultBaseURLString: String = "https://rsshub.example.com"
    static var officialDemoBaseURLString: String = "https://rsshub.app"
}

extension RSSHub {
    @propertyWrapper struct BaseURL: DynamicProperty {
        @AppStorage("baseURLString", store: RSSBud.userDefaults) var string: String = RSSHub.defaultBaseURLString
        
        var wrappedValue: URLComponents {
            get {
                URLComponents(string: string)!
            }
        }
        
        func validate(string: String) -> Bool {
            URLComponents(string: string)?.host != nil
        }
    }
    
    struct AccessControl: DynamicProperty {
        static let valetKey: String = "rssHubAccessKey"
        
        @AppStorage("isRSSHubAccessControlEnabled", store: RSSBud.userDefaults) var isAccessControlEnabled: Bool = false
        @Binding var accessKey: String
        @State private var viewRefresher = false
        
        init() {
            _accessKey = .constant("")
            update()
        }
        
        mutating func update() {
            _accessKey = Binding<String>(
                get: { [_viewRefresher] in
                    let _ = _viewRefresher.wrappedValue
                    return (try? RSSBud.valet.string(forKey: AccessControl.valetKey)) ?? ""
                }, set: { [_viewRefresher] newValue in
                    if !newValue.isEmpty {
                        try? RSSBud.valet.setString(newValue, forKey: AccessControl.valetKey)
                    } else {
                        try? RSSBud.valet.removeObject(forKey: AccessControl.valetKey)
                    }
                    _viewRefresher.wrappedValue.toggle()
                }
            )
        }
        
        func accessCodeQueryItem(for route: String) -> [URLQueryItem] {
            if isAccessControlEnabled {
                return [URLQueryItem(name: "code", value: (route + accessKey).md5())]
            } else {
                return []
            }
        }
    }
}

extension String {
    public func md5() -> String {
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
        return digest.lazy.map { String(format: "%02hhx", $0) }.joined()
    }
}

enum RSSBud {
    static let appGroupIdentifier: String = "group.com.tylerdlawrence.RSSBud"
    static let userDefaults: UserDefaults = UserDefaults(suiteName: appGroupIdentifier)!
    static let valet = Valet.sharedGroupValet(with: SharedGroupIdentifier(groupPrefix: "group", nonEmptyGroup: "com.tylerdlawrence.RSSBud")!, accessibility: .whenUnlocked)
}
