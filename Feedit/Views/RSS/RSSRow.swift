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

struct RSSRow: View, Equatable {
    static func == (lhs: RSSRow, rhs: RSSRow) -> Bool {
           lhs.rss == rhs.rss
        }
    @State private var showMarkAllAsReadAlert = false
    
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var rssDataSource: RSSDataSource
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
    @Environment(\.editMode) var editMode
    enum ActionItem {
        case info
        case url
    }
    
    @ObservedObject var rss: RSS
    @ObservedObject var feed = RSSStore.instance

    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @State private var actionSheetShown = false
    @State private var showAlert = false
    @State private var showSheet = false
    @State var infoHaptic = false
    @State private var toggle = false
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
    
    @ObservedObject var unread = Unread(dataSource: DataSourceService.current.rssItem)
    @ObservedObject var rssFeedViewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
    
    var filteredArticles: [RSSItem] {
        return rssFeedViewModel.items.filter({ (item) -> Bool in
            return !((self.rssFeedViewModel.isOn && !item.isArchive) || (self.rssFeedViewModel.unreadIsOn && item.isRead))
        })
    }
    
    @State private var count: Int = 0
    
    var body: some View {
        
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
        let deleteButton = SwipeCellButton(
            buttonStyle: .image,
            title: "",
            systemImage: "xmark",
            titleColor: .white,
            imageColor: .white,
            view: nil,
            backgroundColor: .red,
            action: {
                showSheet.toggle()
                context.delete(rss)
                saveContext()
                try! context.save()
            },
            feedback: true
        )
        
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
//                self.editMode?.wrappedValue = .active
//            },
//            feedback: true
//        )
        
        let swipeSlots = SwipeCellSlot(slots: [infoButton], slotStyle: .destructive, buttonWidth: 60)
        
        let deleteSlot = SwipeCellSlot(slots: [deleteButton], slotStyle: .destructive, buttonWidth: 60)
                HStack(alignment: .center){
                    KFImage(URL(string: self.rss.image ?? ""))
                        .placeholder({
                            Image("all")
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 25, height: 25, alignment: .center)
                                .cornerRadius(3)
                                     .clipped()
                        })
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25,alignment: .center)
                        .cornerRadius(3)
                    
                    Text(self.rss.title)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .lineLimit(1)
                        .foregroundColor(Color("text"))
                    Spacer()
                    
                    
                    UnreadCountView(count: self.unread.filteredPosts.filter { !$0.isRead }.count)
                    
//                    UnreadCountView(count: filteredArticles.filter { !$0.isRead }.count)
//                    Text("\(rss.posts.filter { !$0.isRead }.count)")
//                        .font(.footnote)
//                        .foregroundColor(.gray)
                    
                }
                .fixedSize(horizontal: false, vertical: true).frame(height: 40)
                .onTapGesture {
                }
                .swipeCell(cellPosition: .both, leftSlot: swipeSlots, rightSlot: deleteSlot)
                .dismissSwipeCell()
                .frame(height: 25)
                .sheet(isPresented: $infoHaptic, content: { InfoView(rssGroup: rssGroup, rss: rss)})
                .actionSheet(isPresented: $showAlert, content: { self.actionSheet })
//                .sheet(isPresented: $showSheet, content: { Text("Hello world")})
                .alert(isPresented: $showSheet) {
                    Alert(
                        title: Text("Unsubscribe from \(rss.title)?"),
                        message: nil,
                        primaryButton: .destructive(
                            Text("Unsubscribe"),
                            action: {
                                showSheet.toggle()
                                context.delete(rss)
                                dismissDestructiveDelayButton()
                                saveContext()
                                try! context.save()
                                
                            }
                        ),
                        secondaryButton: .cancel({ dismissDestructiveDelayButton() })
                    )
                }
                .contextMenu {
                    Button(action: {
                        infoHaptic.toggle()
                    }, label: {
                        Label("Get Info", systemImage: "info")
                    })
                
                    Divider()
                                    
                    Button(action: {
                        UIPasteboard.general.setValue(self.rss.url,
                                                      forPasteboardType: kUTTypePlainText as String)
                    }) {
                        Text("Copy Feed URL")
                        Image(systemName: "doc.on.clipboard.fill")
                    }
                    
                    Button(action: {
                        UIPasteboard.general.setValue(self.rss.url,
                                                      forPasteboardType: kUTTypePlainText as String)
                    }) {
                        Text("Copy Website URL")
                        Image(systemName: "doc.on.clipboard.fill")
                    }
                    
                    Divider()
                    
                    Button(action: {
                        showMarkAllAsReadAlert.toggle()
                        rssFeedViewModel.items.forEach { (rss) in
                        rss.isRead = true
                        rssFeedViewModel.items.removeAll()
                        saveContext()
                        }
                    }) {
                        Label("Mark All As Read in \(rss.title)", image: "Symbol")
                    }
                    
                    Divider()

                    Button(action: {
                        showSheet.toggle()
                        context.delete(rss)
                        saveContext()
                        try! context.save()
                    }, label: {
                        Label("Unsubscribe from \(rss.title)?", systemImage: "xmark")
                    })
                }
                
    }
    private func saveContext() {
        do {
            try Persistence.current.context.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved Error: \(error)")
        }
    }
}

#if DEBUG
@available(iOS 14.0, *)
struct RSSRow_Previews: PreviewProvider {
    static let rss = RSS(context: Persistence.current.context)
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static var previews: some View {
        return
            NavigationView {
                List {
                    ForEach(0..<7, id: \.self) { rss in
                        
                        RSSRow(rss: RSS.simple())
                            
                            .environmentObject(DataSourceService.current.rss)
                            .environmentObject(DataSourceService.current.rssItem)
                            .environment(\.managedObjectContext, Persistence.current.context)
                }
            }
        }.preferredColorScheme(.dark)
    }
}
#endif
