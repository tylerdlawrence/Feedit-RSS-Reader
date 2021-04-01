//
//  GetInfo.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 1/3/21.
//

import SwiftUI
import SwiftUIX
import Introspect
import UIKit
import MobileCoreServices
import Combine
import Foundation
import CoreData
import SDWebImageSwiftUI
import KingfisherSwiftUI

struct InfoView: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var rssDataSource: RSSDataSource
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
//    @Environment(\.managedObjectContext) var context
    @EnvironmentObject private var persistence: Persistence
    
    let rssGroup: RSSGroup
    @ObservedObject var rss: RSS
    @State private var isSelected: Bool = false
    @State private var actionSheetShown = false
    
    enum InfoItem: CaseIterable {
        case webView
        
        var label: String {
            switch self {
            case .webView: return "Read Mode"
            }
        }
    }
    
    var rssSource: RSS {
        return self.rss
    }
    
    @State var groupPickerIsPresented = false

    var body: some View {
        NavigationView{
            ZStack {
                List {
                    VStack(alignment: .center){
                        HStack {
                            KFImage(URL(string: rssSource.image))
                                .placeholder({
                                    Image("getInfo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50,alignment: .center)
                                        .cornerRadius(5)
                                        .border(Color("Color"), width: 2)
                                        .multilineTextAlignment(.center)

                                })
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50,alignment: .center)
                                .cornerRadius(5)
                                .border(Color.clear, width: 1)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.leading, 130.0)
                    .listRowBackground(Color("modalAccent"))
                    
                Section(header: Header(), footer: Footer(rss: rss)) {
                    HStack {
                        TextField(rss.title, text: $rss.title)
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                    }
                    VStack{
                        Text(rss.desc)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color("text"))
                    }
                }
                    
                HStack {
                    ForEach([InfoItem.webView], id: \.self) { _ in
                            Toggle("Safari Reader View", isOn: self.$isSelected)
                        }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    
                    Section(header: Text("Feed URL")
                            .padding(.leading).textCase(nil)) {
                    HStack{
                        Text(rss.url).textCase(.lowercase)
                            .contextMenu {
                                Button(action: {
                                    self.actionSheetShown = true
                                    UIPasteboard.general.setValue(rss.url,
                                                                  forPasteboardType: kUTTypePlainText as String)
                                }) {
                                    Text("Copy Feed URL")
                                    Image(systemName: "doc.on.clipboard")
                                }
                            }
                        }
                }
                Section(header: Text("Home Page").padding(.leading).textCase(nil)){
                    HStack{
//                        Text(rssSource.url).textCase(.lowercase)
                        LinkPresentationView(url: URL(string: rssSource.url)!)
                            .frame(width: 320, height: 70)
                            .contextMenu {
                                Button(action: {
                                    self.actionSheetShown = true
                                    UIPasteboard.general.setValue(rssSource.url,
                                                                  forPasteboardType: kUTTypePlainText as String)
                                }) {
                                    Text("Copy URL")
                                    Image(systemName: "doc.on.clipboard")
                                }
                     
                                Link(destination: URL(string: rssSource.url)!, label: {
                                    HStack {
                                        Text("Go To Website")
                                        Spacer()
                                        Image(systemName: "safari")
                                    }
                                })
                            }
                        Spacer()
//                        Link(destination: URL(string: rss.rssURL!.relativeString)!, label: {
//                            HStack {
//                                Image(systemName: "safari")
//                            }
//                        })
                        
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle(rss.title, displayMode: .inline)
            .navigationBarItems(leading:
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
            }) {
                    Image(systemName: "xmark")
                }
            , trailing:
                Button(action: { groupPickerIsPresented.toggle() }) {
                  Image(systemName: "tray.and.arrow.down.fill")
                }
              )
            }
            .accentColor(Color("tab"))
            
            .sheet(isPresented: $groupPickerIsPresented) {
                SelectGroupView(selectedGroups: (rss.groups as? Set<RSSGroup>) ?? []) {
                setGroups($0)
                groupPickerIsPresented = false
            }
        }
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    private func setGroups(_ groups: Set<RSSGroup>) {
      rss.groups = groups as NSSet
      persistence.saveChanges()
    }
}

struct Header: View {
    var body: some View {
        EmptyView()
    }
}

struct Footer: View {
    @ObservedObject var rss: RSS
    var rssSource: RSS {
        return self.rss
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    var body: some View {
        HStack {
            Text("Last Refresh: \(dateFormatter.string(from: rssSource.updateTime!))")
        }.padding(.leading)
    }
}

extension URL {
    init(_ string: StaticString) {
        self.init(string: "\(string)")!
        let twitterAvatarURL = URL(string: "https://twitter.com/twannl/photo.png?width=200&height=200")!
        print(twitterAvatarURL.path) // Prints: /twannl/photo.png
        print(twitterAvatarURL.pathComponents) // Prints: ["/", "twannl", "photo.png"]
        print(twitterAvatarURL.pathExtension) // Prints: png
        print(twitterAvatarURL.lastPathComponent) // Prints: photo.png
        
        let components = URLComponents(string: "https://twitter.com/twannl/photo.png?width=200&height=200")!
        print(components.query!) // width=200&height=200
        print(components.queryItems!) // [width=200, height=200]
        
        let width = components.queryItems!.first(where: { queryItem -> Bool in
            queryItem.name == "width"
        })!.value!
        let height = components.queryItems!.first(where: { queryItem -> Bool in
            queryItem.name == "height"
        })!.value!
        let imageSize = CGSize(width: Int(width)!, height: Int(height)!)
        print(imageSize) // Prints: (200.0, 200.0)
        
        let imageWidth = Int(components.queryItems!["width"]!)!
        let imageHeight = Int(components.queryItems!["height"]!)!
        //let size =
        _ = CGSize(width: imageWidth, height: imageHeight)
    }
}

extension Collection where Element == URLQueryItem {
    subscript(_ name: String) -> String? {
        first(where: { $0.name == name })?.value
    }
}

struct GetInfo_Previews: PreviewProvider {
    static let rss = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static let rssGroup = RSSGroup()
    
    static var previews: some View {
        let rss = RSS.create(url: "https://chorus.substack.com/people/2323141-jason-tate",
                             title: "Liner Notes",
                             desc: "Liner Notes is a weekly newsletter from Jason Tate of Chorus.fm.",
                             image: "https://bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com/public/images/8a938a56-8a1e-42dc-8802-a75c20e8df4c_256x256.png", in: Persistence.current.context)

        return
            InfoView(rssGroup: rssGroup, rss: rss)
            .environment(\.managedObjectContext, Persistence.current.context)
            
            .preferredColorScheme(.dark)
    }
}
