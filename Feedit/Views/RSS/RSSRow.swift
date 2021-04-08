//
//  SourceListRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import UIKit
import CoreData
import Introspect
import MobileCoreServices
import SwipeCell
import KingfisherSwiftUI

struct RSSRow: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var rssDataSource: RSSDataSource
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
    @Environment(\.editMode) var editMode
    @ObservedObject var viewModel: RSSListViewModel
    enum ActionItem {
        case info
        case url
    }
    
    @ObservedObject var rss: RSS
//    @ObservedObject var imageLoader: ImageLoader
    @State private var actionSheetShown = false
    @State private var showAlert = false
    @State private var showSheet = false
    @State var infoHaptic = false
    @State private var toggle = false
//    @State var selection: Set<RSS>
    @EnvironmentObject var persistence: Persistence
    let rssGroup = RSSGroup()
    
    var actionSheet: ActionSheet {
        ActionSheet(
            title: Text(rss.title),
            message: Text(rss.desc),
            buttons: [
                .default(Text("Get Info"), action: {
                    infoHaptic.toggle()
                }),
                .default(Text("Go To Website"), action: {
                    openURL(URL(string: rss.url)!)
                }),
                .default(Text("Copy Feed URL"), action: {
                    self.actionSheetShown = true
                    UIPasteboard.general.setValue(rss.url,
                                                  forPasteboardType: kUTTypePlainText as String)
                }),
                .default(Text("Copy Website URL"), action: {
                    self.actionSheetShown = true
                    UIPasteboard.general.setValue(rss.url,
                                                  forPasteboardType: kUTTypePlainText as String)
                }),
                .destructive(Text("Unsubscribe from \(rss.title)?"), action: {
//                    deleteRow()
                    dismissDestructiveDelayButton()
                    showSheet.toggle()
//                    self.delete(rss)
                    
                }),
                .cancel(),
            ]
        )
    }
//    init(rss: RSS, viewModel: RSSListViewModel) {
//        self.rss = rss
//        imageLoader = ImageLoader(urlString: rss.url)
//        self.viewModel = viewModel
//    }
    
    
    @ObservedObject var unread = Unread(dataSource: DataSourceService.current.rssItem)
    @ObservedObject var rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    
    var filteredArticles: [RSSItem] {
        return rssFeedViewModel.items.filter({ (item) -> Bool in
            return !((self.rssFeedViewModel.isOn && !item.isArchive) || (self.rssFeedViewModel.unreadIsOn && item.isRead))
        })
    }
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @State private var count: Int = 0
    
//    private var urlButton: some View{
//        Button("") {
//            openURL(URL(string: (rssSource.rssURL?.host!)!)!)
//        }
//    }
    
    var body: some View {
//        let _:String = rssSource.rssURL!.absoluteString
//        let _:String = (rssSource.rssURL?.absoluteStringWithoutScheme!)!
//
//        let stringToURL = URL(string: (rssSource.rssURL?.host!)!)
//        let urlToString = stringToURL?.baseURL
        
//        let unreadCount = unread.items.filter { !$0.isRead }.count
        
        let infoButton = SwipeCellButton(
            buttonStyle: .image,
            title: "",
            systemImage: "ellipsis.circle",
            view: nil,
            backgroundColor: Color("tab"),
            action: { showAlert.toggle()
            },
            feedback: true
        )
        
//        let clipboardButton = SwipeCellButton(
//            buttonStyle: .image,
//            title: "",
//            systemImage: "doc.on.clipboard",
//            imageColor: .white,
//            view: nil,
//            backgroundColor: .gray,
//            action: { UIPasteboard.general.setValue(rss.url,
//                                                    forPasteboardType: kUTTypePlainText as String)
//            }
//        )
//        let deleteButton = SwipeCellButton(
//            buttonStyle: .image,
//            title: "",
//            systemImage: "xmark",
//            titleColor: .white,
//            imageColor: .white,
//            view: nil,
//            backgroundColor: .red,
//            action: {
//                deleteRow()
////                dismissDestructiveDelayButton()
////                showSheet.toggle()
////                self.delete(rss)
//            },
//            feedback: true
//        )
        
//        let editButton = SwipeCellButton(
//            buttonStyle: .image,
//            title: "",
//            systemImage: "rectangle.and.pencil.and.ellipsis",
//            titleColor: .white,
//            imageColor: .white,
//            view: nil,
//            backgroundColor: .yellow,
//            action: {
//                editMode?.wrappedValue = editMode?.wrappedValue == .active ? .inactive : .active
////                self.editMode?.wrappedValue = .active
//            },
//            feedback: true
//        )
        
        let swipeSlots = SwipeCellSlot(slots: [infoButton], slotStyle: .destructive, buttonWidth: 60)
        
//        let deleteSlot = SwipeCellSlot(slots: [deleteButton], slotStyle: .destructive, buttonWidth: 60)
                HStack(alignment: .center){
                    
                    KFImage(URL(string: rss.image))
                        .placeholder({
                            Image("getInfo")
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25,alignment: .center)
                                .cornerRadius(3)
                                .opacity(0.9)
                        })
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25,alignment: .center)
                        .cornerRadius(3)
                    
                    Text(rss.title)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .lineLimit(1)
                        .foregroundColor(Color("text"))
                    Spacer()
                    
//                    UnreadCountView(count: filteredArticles.count)
//                    Text("\(unread.items.count)")
                }
//                .onAppear {
//                    self.viewModel.fetchUnreadCount()
//                }
                .frame(height: 40)
                .onTapGesture {
                }
                .swipeCell(cellPosition: .both, leftSlot: swipeSlots, rightSlot: nil)
                .dismissSwipeCell()
                .frame(height: 25)
                .sheet(isPresented: $infoHaptic, content: { InfoView(rssGroup: rssGroup, rss: rss)})
                .actionSheet(isPresented: $showAlert, content: { self.actionSheet })

//                .sheet(isPresented: $showSheet, content: { Text("Hello world")})
//                .alert(isPresented: $showSheet) {
//                    Alert(
//                        title: Text("Unsubscribe from \(rss.title)?"),
//                        message: nil,
//                        primaryButton: .destructive(
//                            Text("Unsubscribe"),
//                            action: {
////                                deleteRow()
//                                dismissDestructiveDelayButton()
//                                showSheet.toggle()
//                                self.delete(rss)
//                            }
//                        ),
//                        secondaryButton: .cancel({ dismissDestructiveDelayButton() })
//                    )
//                }
                .contextMenu {
                    Button(action: {
                        infoHaptic.toggle()
                    }, label: {
                        Label("Get Info", systemImage: "info")
                    })
                
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
//                    if self.rss.filter({ !$0.isRead }).count == 0 {
//                    Text("")
//                    }
//                    else {
//                        self.rss.filter { !$0.isRead }.count
//                            .font(.footnote)
//                            .foregroundColor(Color("tab"))
//                    }
                    }, label: {
                        Label("Mark All As Read in \(rss.title)", image: "Symbol")
                    })
                    
                    Divider()

                    Button(action: {
                        showSheet.toggle()
                        context.delete(rss)
                        try! context.save()
                    }, label: {
                        Label("Unsubscribe from \(rss.title)?", systemImage: "xmark")
                    })
                }
                
    }

}
    
//#if DEBUG
//struct RSSRow_Previews: PreviewProvider {
//    static let rss = DataSourceService.current
//    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
//    
//    static var previews: some View {
//        return RSSRow(viewModel: self.viewModel, rss: RSS())
//            .previewLayout(.fixed(width: 400, height: 30))
//            .preferredColorScheme(.dark)
//    }
//}
//#endif
