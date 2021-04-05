//
//  RSSFeedDetailView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/12/21.
//

import SwiftUI
import Foundation
import Combine
import CoreMotion
import KingfisherSwiftUI

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
                    
                    ReaderModeButton(isSet: self.$isSelected)
                }
            }
            
            NavigationLink(destination: WebView(rssItem: rssItem, onCloseClosure: {})) {
                Image(systemName: "chevron.right.circle")
                    .foregroundColor(Color("tab"))
                    .font(.system(size: 20, weight: .regular, design: .default))
            }
        }
    }
    
    private var trailingButtons: some View {
        HStack {
//            DarkmModeSettingView(darkMode: $darkMode)
            Button(action: actionSheet) {
                Image(systemName: "square.and.arrow.up")
                    .imageScale(.medium)
                    .foregroundColor(Color("tab"))
                    .font(.system(size: 20, weight: .regular, design: .default))
            }
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    Divider().padding(0)
                    HStack {
                        VStack(alignment: .leading) {
                            Text(rssSource.title)
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                            Text(rssSource.desc)
                                .font(.system(size: 16, weight: .medium, design: .rounded)).foregroundColor(.gray)
                                .lineLimit(2)
                            Text(rssItem.author)
                                .font(.system(size: 16, weight: .medium, design: .rounded)).foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        KFImage(URL(string: rssSource.image))
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
                    
                    Text(rssItem.desc.trimHTMLTag.trimWhiteAndSpace)
                        .font(.system(size: 17, weight: .medium, design: .rounded)).foregroundColor(.gray)
                        .padding(.bottom)
                    
                    NavigationLink(destination: WebView(rssItem: rssItem, onCloseClosure: {})) {
                        Text("View Full Article")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
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
           UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
       }
}

#if DEBUG
struct RSSFeedDetailView_Previews: PreviewProvider {
    static var rss = RSS()
    static var rssFeedViewModel = RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem)

    static var previews: some View {
        return RSSFeedDetailView(rssItem: RSSItem(), rssFeedViewModel: self.rssFeedViewModel)//.environment(\.managedObjectContext, Persistence.current.context).environmentObject(DataSourceService.current.rss)
            .environment(\.colorScheme, .dark)
    }
}
#endif

struct MarkAsStarredButton: View {
    @Binding var isSet: Bool

    var body: some View {
        Button(action: {
            isSet.toggle()
        }) {
            Image(systemName: isSet ? "star.fill" : "star")
                .imageScale(.medium)
                .foregroundColor(Color("tab"))
                .font(.system(size: 20, weight: .regular, design: .default))
        }
    }
}

struct MarkAsStarredButton_Previews: PreviewProvider {
    static var previews: some View {
        MarkAsStarredButton(isSet: .constant(true))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

struct ReaderModeButton: View {
    @Binding var isSet: Bool
//    @Binding var isSelected: Bool
    var body: some View {
        Button(action: {
            isSet.toggle()
//            self.isSelected.toggle()
        }) {
            
            Image(systemName: isSet ? "doc.plaintext.fill" : "doc.plaintext")
                .imageScale(.medium)
                .foregroundColor(Color("tab"))
                .font(.system(size: 20, weight: .regular, design: .default))
        }
    }
}

struct ReaderModeButton_Previews: PreviewProvider {
    static var previews: some View {
        ReaderModeButton(isSet: .constant(true))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

struct MarkAsReadButton: View {
    @Binding var isSet: Bool

    var body: some View {
        Button(action: {
            isSet.toggle()
        }) {
            Image(systemName: isSet ? "circle.fill" : "circle")
                .imageScale(.medium)
                .foregroundColor(Color("tab"))
                .font(.system(size: 20, weight: .regular, design: .default))
        }
    }
}

struct MarkAsReadButton_Previews: PreviewProvider {
    static var previews: some View {
        MarkAsReadButton(isSet: .constant(true))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
