//
//  RSSFeedDetailView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/12/21.
//

import SwiftUI
import FeedKit
import Parma
import Foundation
import Combine
import CoreMotion
import KingfisherSwiftUI
import SDWebImageSwiftUI
import libcmark

struct RSSFeedDetailView: View {
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
    @EnvironmentObject private var persistence: Persistence
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var rssDataSource: RSSDataSource
    
    @AppStorage("darkMode") var darkMode = false
    @ObservedObject var rssItem: RSSItem
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @State private var isSelected: Bool = false
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    private var bottomButtons: some View {
        HStack(alignment: .center, spacing: 75) {
            MarkAsReadButton(isSet: $rssItem.isRead)
            
            MarkAsStarredButton(isSet: $rssItem.isArchive)
            
            ForEach([SettingItem.webView], id: \.self) { _ in
                NavigationLink(destination: WebView(rssItem: rssItem, onCloseClosure: {})) {
                    ReaderModeButton(isSet: $isSelected)
                }
            }
            
            NavigationLink(destination: WebView(rssItem: rssItem, onCloseClosure: {})) {
                Image(systemName: "chevron.right")
                    .foregroundColor(Color("tab"))
                    .font(.system(size: 20, weight: .regular, design: .default))
            }
        }
    }
    
    private var trailingButtons: some View {
        HStack(spacing: 30) {
            DarkmModeSettingView(darkMode: $darkMode)
            Button(action: {
                //shareSheet not working w/ UIApplication.shared
                //Feedit.actionSheet()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .imageScale(.medium)
                    .foregroundColor(Color("tab"))
                    .font(.system(size: 20, weight: .regular, design: .default))
            }
        }
    }
    
    @State var markdown: String = ""
    var rss = RSS()
    
    init(withURL url:String, rssItem: RSSItem, rssFeedViewModel: RSSFeedViewModel) {
        self.rssItem = rssItem
        self.rssFeedViewModel = rssFeedViewModel
    }
        
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    Divider().padding(0)
                    HStack {
                        VStack(alignment: .leading) {
                            NavigationLink(destination: WebView(rssItem: rssItem, onCloseClosure: {})) {
                                Text(rssSource.title)
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                            }
                            Text(rssSource.desc.tagsStripped)
                                .font(.system(size: 16, weight: .medium, design: .rounded)).foregroundColor(.gray)
                                .lineLimit(2)
                            Text(rssItem.author?.description ?? "")
                                .font(.system(size: 16, weight: .medium, design: .rounded)).foregroundColor(.gray).lineLimit(1)
                        }
                        Spacer()
                                                
                        KFImage(URL(string: rssSource.image ?? ""))
                            .placeholder({
                                Image("getInfo")
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60,alignment: .center)
                                    .cornerRadius(7)
                            })
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60,alignment: .center)
                            .cornerRadius(5)
                            .padding(.bottom)
                        
                    }.padding(.top)
                    
                    Divider()
                    
                    Text(verbatim: rssItem.title)
                        .font(.system(size: 26, weight: .medium, design: .rounded))
                        .padding(.top)

                    HStack {
                        Text("\(rssItem.createTime?.string() ?? "")")
                            .textCase(.uppercase)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                            .padding(.bottom)
                        Spacer()
                    }.padding(.top, 3)
                                                           
                    //Parma(rssItem.debugDescription)
                    Parma(rssItem.desc.tagsStripped.trimHTMLTag.decodedURLString ?? "" , render: MyRenderer())
                    
                    NavigationLink(destination: WebView(rssItem: rssItem, onCloseClosure: {})) {
                        Text("View Full Article")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    NavigationLink(destination: WebView(rssItem: rssItem, onCloseClosure: {})) {
                        Text(rssItem.url)
                            .font(.system(size: 16, weight: .medium, design: .rounded)).padding(.top)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {Text("")}
                    ToolbarItem(placement: .navigationBarTrailing) { trailingButtons }
                }
                .padding(EdgeInsets(top: 200.0, leading: 16.0, bottom: 0.0, trailing: 16.0))
                .offset(x: 0, y: -200.0)
            }
        }.environmentObject(DataSourceService.current.rss)
        Spacer()
        bottomButtons
    }
    func actionSheet() {
        guard let urlShare = URL(string: rssItem.url) else { return }
           let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
        UIApplication.init().windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
       }
}

#if DEBUG
struct RSSFeedDetailView_Previews: PreviewProvider {
    static var rss = RSS()
    static var rssFeedViewModel = RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem)

    static var previews: some View {
        NavigationView {
            /*
            RSSFeedDetailView(withURL: "", rssItem: RSSItem.create(uuid: UUID(), title: "title", desc: "description", author: "author", url: "https://",image: "all", in: Persistence.current.context), rssFeedViewModel: self.rssFeedViewModel)

            .environment(\.managedObjectContext, Persistence.current.context).environmentObject(DataSourceService.current.rss).environmentObject(DataSourceService.current.rssItem)
             */
            ParmaDetailView()
        }.environment(\.colorScheme, .dark)
    }
}
#endif

struct MyRenderer: ParmaRenderable {
    
    func link(textView: Text, destination: String?) -> Text {
        textView.bold()
            .foregroundColor(Color("tab"))
    }
    
    func imageView(with urlString: String, altTextView: AnyView?) -> AnyView {
        AnyView(ArticleImageView(imageSrc: urlString))
    }
    
    func code(_ text: String) -> Text {
        return plainText(text).baselineOffset(10.0)
    }
    
    func heading(level: HeadingLevel?, textView: Text) -> Text {
        switch level {
        case .one:
            return textView.font(.system(.largeTitle, design: .serif)).bold()
        case .two:
            return textView.font(.system(.title, design: .serif)).bold()
        case .three:
            return textView.font(.system(.title2)).bold()
        default:
            return textView.font(.system(.title3)).bold()
        }
    }
    
    func headingBlock(level: HeadingLevel?, view: AnyView) -> AnyView {
        switch level {
        case .one, .two:
            return AnyView(
                VStack(alignment: .leading, spacing: 2) {
                    view
                        .padding(.top, 4)
                    Rectangle()
                        .foregroundColor(.pink)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 1, alignment: .center)
                        .padding(.bottom, 8)
                }
            )
        default:
            return AnyView(view.padding(.bottom, 4))
        }
    }
    
    public func paragraphBlock(view: AnyView) -> AnyView {
        struct ExpandableView: View {
            @State var lineLimit: Int? = nil
            let view: AnyView
            
            var body: some View {
                view
                    .font(.system(size: 17, weight: .regular, design: .rounded)).foregroundColor(Color("text")).lineLimit(lineLimit).padding(.horizontal).padding(.bottom)
                    .onTapGesture {
                        if lineLimit == nil {
                            lineLimit = 1
                        } else {
                            lineLimit = nil
                    }
                }
            }
        }
        return AnyView(ExpandableView(view: view))
    }
    
    func listItem(view: AnyView) -> AnyView {
        let bullet = "•"
        return AnyView(
            HStack(alignment: .top, spacing: 8) {
                Text(bullet)
                view.fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 4)
        )
    }
}

struct ArticleImageView: View {
    
    var imageSrc: String
    var body: some View {
        
        WebImage(url: URL(string: imageSrc)!)
            .placeholder {
                ProgressView().progressViewStyle(LinearProgressViewStyle())
            }
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            .onTapGesture {
                //detailImageModel.imageStr = imageSrc
                //detailImageModel.show = true
            }
    }
}
