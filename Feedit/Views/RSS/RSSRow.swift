//
//  SourceListRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import Foundation
import MobileCoreServices
import SDWebImageSwiftUI
import SwipeCell
import UIKit
import Combine
import AudioToolbox
import Foundation
import FeedKit
import KingfisherSwiftUI

var reporter = PassthroughSubject<String, Never>()

struct RSSRow: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL

    enum ActionItem {
        case info
        case url
    }
    
    @ObservedObject var rss: RSS
    @ObservedObject var imageLoader: ImageLoader
    @State var showActionSheet: Bool = false
    @State private var actionSheetShown = false
    @State private var showAlert = false
    @State var infoHaptic = false
    @State private var toggle = false
//    var rssSource: RSS {
//        return self.rssFeedViewModel.rss
//    }
    var actionSheet: ActionSheet {
        ActionSheet(title: Text("Action Sheet"), message: Text("Choose Option"), buttons: [
            .default(Text("Save")),
            .default(Text("Delete")),
            .destructive(Text("Cancel"))
        ])
    }
    


    var contextMenuAction: ((RSS) -> Void)?
    var isRead: ((RSS) -> Void)?
    init(rss: RSS) {
        self.rss = rss
//        self.imageLoader = ImageLoader(urlString: rss.imageURL)
        self.imageLoader = ImageLoader(path: rss.image)
//        rssItemDataSource = rssItem
//        let db = DataSourceService.current
//        dataViewModel = DataNStorageViewModel(rss: db.rss, rssItem: db.rssItem)
    }
    
    private func iconImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20,alignment: .center)
                .cornerRadius(5)
                .animation(.easeInOut)
                .border(Color.clear, width: 1)
    }
    
    let didChange = PassthroughSubject<RSSStore, Never>()
    var imageURL: URL?
    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
//    static var viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
    var body: some View {
        
        let infoButton = SwipeCellButton(
            buttonStyle: .image,
            title: "",
            systemImage: "ellipsis",
            view: nil,
            backgroundColor: Color("accent"),
            action: { showAlert.toggle()
            }
        )
//        let deleteButton = SwipeCellButton(
//            buttonStyle: .image,
//            title: "",
//            systemImage: "xmark",
//            titleColor: .white,
//            imageColor: .white,
//            view: nil,
//            backgroundColor: .red,
//            action: {
//                showAlert.toggle()
//            },
//            feedback: true
//        )
        let swipeSlots = SwipeCellSlot(slots: [infoButton], slotStyle: .destructive, buttonWidth: 70)
                HStack(alignment: .center){
                    KFImage(URL(string: rss.image))
                        .placeholder({
                            Image("Thumbnail")
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20,alignment: .center)
                                .cornerRadius(2)
                                .opacity(0.9)
                                .border(Color.clear, width: 1)
                        })
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20,alignment: .center)
                        .cornerRadius(2)
                        .border(Color.clear, width: 1)
                    Text(rss.title)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .lineLimit(1)
                        .foregroundColor(Color("text"))
//                    Spacer()
//                    Text("\(self.rssFeedViewModel.items.count)")
//                        .font(.caption)
//                        .fontWeight(.bold)
//                        .padding(.horizontal, 7)
//                        .padding(.vertical, 1)
//                        .background(Color.gray.opacity(0.5))
//                        .opacity(0.4)
//                        .foregroundColor(Color("text"))
//                        .cornerRadius(8)
                }
                .frame(height: 25)
                .onTapGesture {
                }
                .swipeCell(cellPosition: .both, leftSlot: swipeSlots, rightSlot: nil)
                .dismissSwipeCell()
                .frame(height: 25)
                .sheet(isPresented: $infoHaptic, content: { InfoView(rss: rss) })

                .contextMenu {
                    Button(action: {
                        infoHaptic.toggle()
                    }) {
                        Text("Get Info")
                        Image(systemName: "info")
                    }
                
                    Divider()
                    
                    Button(action: {
        //                    if self.rss.filter({ !$0.isRead }).count == 0 {
        //                    Text("")
        //                    }
        //                    else {
        //                        self.rss.filter { !$0.isRead }.count
        //                            .font(.footnote)
        //                            .foregroundColor(Color("tab"))
        //                    }
                    }) {
                    Text("Mark All As Read in \(rss.title)")
                    Image("Symbol").font(.system(size: 6, weight: .thin, design: .rounded))
                }
                    
                    Divider()
                
                    Button(action: {
                        UIPasteboard.general.setValue(rss.url,
                                                      forPasteboardType: kUTTypePlainText as String)
                    }) {
                        Text("Copy Feed URL")
                        Image(systemName: "doc.on.clipboard.fill")
                    }
                    
                    Button(action: {
                        UIPasteboard.general.setValue(rss.url,
                                                      forPasteboardType: kUTTypePlainText as String)
                    }) {
                        Text("Copy Website URL")
                        Image(systemName: "doc.on.clipboard.fill")
                    }
                    
                    Divider()
                    

                
                Button(action: {
//                    withAnimation(.easeIn){rss.deleteItem()}
                }) {
                    Text("Unsubscribe from \(rss.title)?")
                    Image(systemName: "xmark")
                }
            }
            .actionSheet(isPresented: $showAlert) {
                ActionSheet(
                    title: Text(rss.title),
                    message: nil,
                    buttons: [
                        .default(Text("Get Info").foregroundColor(Color("tab")), action: {
                            infoHaptic.toggle()
                        }),
                        .default(Text("Go To Website").foregroundColor(Color("tab")), action: {
                            openURL(URL(string: rss.url)!)
                        }
                        ),
                        .default(Text("Copy Feed URL").foregroundColor(Color("tab")), action: {
                            self.actionSheetShown = true
                            UIPasteboard.general.setValue(rss.url,
                                                          forPasteboardType: kUTTypePlainText as String)
                        }),
                        .default(Text("Copy Website URL").foregroundColor(Color("tab")), action: {
                            self.actionSheetShown = true
                            UIPasteboard.general.setValue(rss.url,
                                                          forPasteboardType: kUTTypePlainText as String)
                        }),
//                        .default(Text("Unsubscribe").foregroundColor(.red), action: {
////                            self.deleteItem()
//                        }),
                        .cancel(Text("Cancel").foregroundColor(.red)),
                    ]
                )
            }.frame(height: 25)
    }
    private func destinationView(rss: RSS) -> some View {
        RSSFeedListView(viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), rss: rss)
            .environmentObject(DataSourceService.current.rss)
    }
}

struct customMenu: View {

    var onDelete: (() -> Void)?

    init(onDelete: @escaping () -> Void) {
        self.onDelete = onDelete;
    }

    var body: some View {
        VStack {
            if (self.onDelete != nil) {
                Button(action: self.onDelete!) {
                    HStack {
                        Text("delete")
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
}
    
//        VStack(alignment: .leading) {
//            HStack(alignment: .center) {
//                if
//                    self.imageLoader.imageURL != nil {
//                    iconImageView(self.imageLoader.imageURL!)
//                        .frame(width: 25, height: 25,alignment: .center)
//                        .layoutPriority(10)
//                    } else {
//                        KFImage(URL(string: rss.imageURL))
//                            .placeholder({
//                                Image("Thumbnail")
//                                    .renderingMode(.original)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 20, height: 20,alignment: .center)
//                                    .cornerRadius(2)
//                                    .border(Color.clear, width: 1)
//                            })
//                            .renderingMode(.original)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 20, height: 20,alignment: .center)
//                            .cornerRadius(2)
//                            .border(Color.clear, width: 1)
//                    }
//                }
//            }
//            .contextMenu {
//                Button(action: {
//                    self.showInfoSheet = true
//                }) {
//                    Text("Edit")
//                    Image(systemName: "rectangle.and.pencil.and.ellipsis").font(.system(size: 16, weight: .medium))
//                }
//                Button(action: {
//                    self.showActionSheet.toggle()
//                }) {
//                    Text("Display Action Sheet")
//                }
//                .actionSheet(isPresented: $showActionSheet, content: {
//                    self.actionSheet })
//            }
//    }
//}
struct RSSRow_Previews: PreviewProvider {
    static let db = DataSourceService.current
    static var dataViewModel = DataNStorageViewModel(rss: db.rss, rssItem: db.rssItem)
    static let rss = DataSourceService.current
    static let rssFeedViewModel = RSSFeedViewModel(rss: RSS(context: Persistence.current.context), dataSource: DataSourceService.current.rssItem)

    static var previews: some View {
        let rss = RSS.create(url: "https://",
                             title: "The GitHub Blog",
                             desc: "Updates, ideas, and inspiration from GitHub to help developers build and design software.",
                             image: "https://github.blog/wp-content/uploads/2019/01/cropped-github-favicon-512.png?fit=32%2C32", in: Persistence.current.context)

        return

//            NavigationView {
//                HStack {
                    RSSRow(rss: rss)
                        .padding()
                        .frame(width: 400, height: 25, alignment: .center)
//                }
//            }
    }
}
