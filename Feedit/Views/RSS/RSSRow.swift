//
//  SourceListRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
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

    @State private var showFavoritesOnly = false
//    var rssIndex: Int {
//        $modelData.firstIndex(where: { $0.id == rss.id })!
//    }
    var filteredFeeds: [RSS] {
        RSSRow.viewModel.items.filter { rss in
            (!showFavoritesOnly || rss.isFavorite)
        }
    }
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @State private var showInfoSheet = false
    @ObservedObject var imageLoader: ImageLoader
//    @ObservedObject var coordinator = Coordinator()
    @EnvironmentObject var observer : SwipeObserver
    @State var direction = ""
    @ObservedObject var rss: RSS
    
    @State var showActionSheet: Bool = false
    
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
        self.imageLoader = ImageLoader(urlString: rss.imageURL)
//        contextMenuAction = action
    }

    private func iconImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
        .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25,alignment: .center)
            .cornerRadius(5)
            .animation(.easeInOut)
            .border(Color.clear, width: 1)
        
    }
    
    let didChange = PassthroughSubject<RSSStore, Never>()

    private var pureTextView: some View {
        ZStack {
//            swipeView()
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center){
                    Text(rss.title)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .lineLimit(1)
                        .foregroundColor(Color("text"))
                    Spacer()
                }
            }
        }
    }

    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    static var viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
    @State private var useReadText = false
//    @State private var isRead = false
    @State private var showSheet = false
    @State private var bookmark = false
    @State private var unread = false
    @State private var showAlert = false
    @State var indices : [Int] = []
    func deleteItems(at offsets: IndexSet) {
        RSSRow.viewModel.items.remove(atOffsets: offsets)
    }

    var body: some View {
        //Configure button
        let button1 = SwipeCellButton(
            buttonStyle: .image,
            title: "Mark",
            systemImage: "bookmark",
            titleColor: .white,
            imageColor: .white,
            view: nil,
            backgroundColor: .green,
            action: { bookmark.toggle() },
            feedback: true
        )
        let editInfo = SwipeCellButton(
            buttonStyle: .image,
            title: "",
            systemImage: "rectangle.and.pencil.and.ellipsis",
            view: nil,
            backgroundColor: .gray,
            action: { showSheet.toggle() }
        )
        let button3 = SwipeCellButton(
            buttonStyle: .view,
            title: "",
            systemImage: "",
            view: {
                AnyView(
                    Group {
                        if unread {
                            Image(systemName: "largecircle.fill.circle")
                                .foregroundColor(.white)
                                .font(.title)
                        }
                        else {
                            Image(systemName: "circle")
                                .foregroundColor(.white)
                                .font(.title)
                        }
                    }
                )
            },
            backgroundColor: Color("footnoteColor"),
            action: { unread.toggle() },
            feedback: false
        )

        let deleteButton = SwipeCellButton(
            buttonStyle: .image,
            title: "",
            systemImage: "trash",
            titleColor: .white,
            imageColor: .white,
            view: nil,
            backgroundColor: .red,
            action: {
                showAlert.toggle()
                deleteItems(at: IndexSet())
                
            },
            feedback: true
        ) //, deleteButton
        let slot3 = SwipeCellSlot(slots: [editInfo], slotStyle: .destructive, buttonWidth: 70)
//        let slot4 = SwipeCellSlot(slots: [button3], slotStyle: .normal, buttonWidth: 60)
//        let slot5 = SwipeCellSlot(slots: [button2, button5], slotStyle: .destructiveDelay)

        return
//            NavigationView {
//                List {
            VStack(alignment: .leading) {
                HStack(alignment: .center){
//                    demo1()
//                        .onTapGesture {
//                            print("test")
//                        }
//                        .swipeCell(cellPosition: .right, leftSlot: nil, rightSlot: slot1)
//                    Button(action: { print("button") }) {
//                        demo2()
//                    }
//                    .swipeCell(cellPosition: .both, leftSlot: slot1, rightSlot: slot1)

                    publishedRow()
                        .onTapGesture {
                            print("test")
                        }
                        .swipeCell(cellPosition: .both, leftSlot: slot3, rightSlot: nil)
                        .dismissSwipeCellForScrollViewForLazyVStack()

//                    demo4()
//                        .onTapGesture {
//                            print("test")
//                        }
//                        .swipeCell(cellPosition: .left, leftSlot: slot2, rightSlot: nil)
//
//                    demo5()
//                        .onTapGesture {
//                            print("test")
//                        }
//                        .swipeCell(cellPosition: .left, leftSlot: slot4, rightSlot: nil)
//
//                    demo6()
//                        .onTapGesture {
//                            print("test")
//                        }
//                        .swipeCell(
//                            cellPosition: .both,
//                            leftSlot: slot1,
//                            rightSlot: slot1,
//                            swipeCellStyle: SwipeCellStyle(
//                                alignment: .leading,
//                                dismissWidth: 20,
//                                appearWidth: 20,
//                                destructiveWidth: 240,
//                                vibrationForButton: .error,
//                                vibrationForDestructive: .heavy,
//                                autoResetTime: 3
//                            )
//                        )
//                    demo7()
//                        .onTapGesture {
//                            print("test")
//                        }
//                        .swipeCell(cellPosition: .right, leftSlot: nil, rightSlot: slot5)
//                        .alert(isPresented: $showAlert) {
//                            Alert(
//                                title: Text("Are you sure"),
//                                message: nil,
//                                primaryButton: .destructive(
//                                    Text("Delete"),
//                                    action: {
//                                        print("deleted")
//                                        dismissDestructiveDelayButton()
//                                    }
//                                ),
//                                secondaryButton: .cancel({ dismissDestructiveDelayButton() })
//                            )
//                        }
//                    DemoShowStatus()
                
//                    NavigationLink("ScrollView LazyVStack", destination: demo9())
//                    NavigationLink("ScrollView single Cell", destination: Demo8())
//                }
//                .navigationBarTitle("SwipeCell Demo", displayMode: .inline)
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
            .dismissSwipeCell()
            .sheet(isPresented: $showSheet, content: { InfoView(rss: rss) })

    }

//    func demo1() -> some View {
//        HStack {
//            KFImage(URL(string: rss.imageURL))
//                .placeholder({
//                    Image("default-icon")
//                        .renderingMode(.original)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 25, height: 25,alignment: .center)
//                        .cornerRadius(2)
//                        .border(Color.clear, width: 1)
//                })
//                .renderingMode(.original)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 25, height: 25,alignment: .center)
//                .cornerRadius(2)
//                .border(Color.clear, width: 1)
//            pureTextView
////            Spacer()
////            Text("← Swipe left")
//            if bookmark {
//                Image(systemName: "star.fill")
//                    .font(.body)
//                    .foregroundColor(.yellow)
//            }
//            else {
//                Image(systemName: "star")
//                    .font(.caption)
//                    .foregroundColor(.yellow)
//            }
//            Spacer()
//        }
//        .frame(height: 25)
//    }

//    func demo2() -> some View {
//        HStack {
////            Spacer()
////            Text("← → Sliding on both sides")
//            KFImage(URL(string: rss.imageURL))
//                .placeholder({
//                    Image("default-icon")
//                        .renderingMode(.original)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 25, height: 25,alignment: .center)
//                        .cornerRadius(2)
//                        .border(Color.clear, width: 1)
//                })
//                .renderingMode(.original)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 25, height: 25,alignment: .center)
//                .cornerRadius(2)
//                .border(Color.clear, width: 1)
//            pureTextView
//            if bookmark {
//                Image(systemName: "bookmark.fill")
//                    .font(.largeTitle)
//                    .foregroundColor(.green)
//            }
//            else {
//                Image(systemName: "bookmark")
//                    .font(.largeTitle)
//                    .foregroundColor(.green)
//            }
//            Spacer()
//        }
//        .frame(height: 25)
//    }

    func publishedRow() -> some View {
        HStack {
            KFImage(URL(string: rss.imageURL))
                .placeholder({
                    Image("default-icon")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25,alignment: .center)
                        .cornerRadius(2)
                        .border(Color.clear, width: 1)
                })
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25,alignment: .center)
                .cornerRadius(2)
                .border(Color.clear, width: 1)
            pureTextView
            Spacer()
//            VStack {
//                Text("⇠ Swipe left")
//                Text("MutliButton with destructive button")
//            }
            Spacer()
        }
        .frame(height: 30)
        .actionSheet(isPresented: $showAlert) {
            ActionSheet(
                title: Text("Are You Sure?"),
                message: Text("Unsubscribe from \(rss.title)?"),
                buttons: [
                    .cancel { print(self.showActionSheet) },
                    .destructive(Text("Unsubscribe"))
//                    .default(Text("Action")),
//                    .destructive(Text("Unsubscribe"))
                ]
            )
            

        }
    }

    private func destinationView(rss: RSS) -> some View {
        RSSFeedListView(withURL: "", rssViewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem))
            .environmentObject(DataSourceService.current.rss)
    }

//    func demo4() -> some View {
//        HStack {
////            Spacer()
////            VStack {
////                Text("⇢ Swipe right")
////                Text("One destructive button")
////            }
//            KFImage(URL(string: rss.imageURL))
//                .placeholder({
//                    Image("default-icon")
//                        .renderingMode(.original)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 25, height: 25,alignment: .center)
//                        .cornerRadius(2)
//                        .border(Color.clear, width: 1)
//                })
//                .renderingMode(.original)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 25, height: 25,alignment: .center)
//                .cornerRadius(2)
//                .border(Color.clear, width: 1)
//            pureTextView
//            Spacer()
//        }
//        .frame(height: 25)
//    }

//    func demo5() -> some View {
//        HStack {
//            KFImage(URL(string: rss.imageURL))
//                .placeholder({
//                    Image("default-icon")
//                        .renderingMode(.original)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 25, height: 25,alignment: .center)
//                        .cornerRadius(2)
//                        .border(Color.clear, width: 1)
//                })
//                .renderingMode(.original)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 25, height: 25,alignment: .center)
//                .cornerRadius(2)
//                .border(Color.clear, width: 1)
//            pureTextView
////            Spacer()
////            VStack {
////                Text("→ Swipe right")
////                Text("Dynamic Button")
////            }
//            Spacer()
//        }
//        .frame(height: 25)
//    }

//    func demo6() -> some View {
//        HStack {
////            Spacer()
////            VStack {
////                Text("← You can set the auto reset duration ")
////                Text("please wait 3 sec")
////            }
//            KFImage(URL(string: rss.imageURL))
//                .placeholder({
//                    Image("default-icon")
//                        .renderingMode(.original)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 25, height: 25,alignment: .center)
//                        .cornerRadius(2)
//                        .border(Color.clear, width: 1)
//                })
//                .renderingMode(.original)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 25, height: 25,alignment: .center)
//                .cornerRadius(2)
//                .border(Color.clear, width: 1)
//            pureTextView
//            Spacer()
//        }
//        .frame(height: 25)
//    }

    func demo7() -> some View {
        HStack {
//            Spacer()
//            VStack {
//                Text("← destructiveDelay Button")
//                Text("click delete")
//            }
            KFImage(URL(string: rss.imageURL))
                .placeholder({
                    Image("default-icon")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25,alignment: .center)
                        .cornerRadius(2)
                        .border(Color.clear, width: 1)
                })
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25,alignment: .center)
                .cornerRadius(2)
                .border(Color.clear, width: 1)
            pureTextView
            Spacer()
        }
        .frame(height: 25)
    }

    func demo9() -> some View {
        let button4 = SwipeCellButton(
            buttonStyle: .titleAndImage,
            title: "Star",
            systemImage: "star.fill",
            titleColor: .white,
            imageColor: .white,
            view: nil,
            backgroundColor: .yellow,
            action: {},
            feedback: true
        )

        let button5 = SwipeCellButton(
            buttonStyle: .titleAndImage,
            title: "",
            systemImage: "trash",
            titleColor: .white,
            imageColor: .white,
            view: nil,
            backgroundColor: .red,
            action: {
                
                },
            feedback: true
        )
        let slot = SwipeCellSlot(slots: [button4, button5])
        let lists = (0...100).map { $0 }
        return ScrollView {
            LazyVStack {
                ForEach(lists, id: \.self) { item in
                    Text("Swipe in scrollView:\(item)")
                        .frame(height: 80)
                        .swipeCell(cellPosition: .both, leftSlot: slot, rightSlot: slot)
                        .dismissSwipeCellForScrollViewForLazyVStack()
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
//                    pureTextView
//                    } else {
//                        KFImage(URL(string: rss.imageURL))
//                            .placeholder({
//                                Image("default-icon")
//                                    .renderingMode(.original)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 25, height: 25,alignment: .center)
//                                    .cornerRadius(2)
//                                    .border(Color.clear, width: 1)
//                            })
//                            .renderingMode(.original)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 25, height: 25,alignment: .center)
//                            .cornerRadius(2)
//                            .border(Color.clear, width: 1)
//                        pureTextView
//                    }
//                }
//                .offset(self.offset)
//                .animation(.spring())
//                .gesture(DragGesture()
//                            .onChanged { gestrue in
//                                self.offset.width = gestrue.translation.width
//                            }
//                            .onEnded { _ in
//                                if self.offset.width < -50 {
//                                        self.scale = 1
//                                    self.offset.width = -120
//                                    self.offsetY = -20
//                                } else {
//                                        self.scale = 0.5
//                                    self.offset = .zero
//                                    self.offsetY = 0
//
//                                }
//                            }
//                )
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
        
        
    }
}
struct RSSRow_Previews: PreviewProvider {
    static let rss = DataSourceService.current
    static var previews: some View {
        let rss = RSS.create(url: "https://",
                             title: "The GitHub Blog",
                             desc: "Updates, ideas, and inspiration from GitHub to help developers build and design software.",
                             imageURL: "https://github.blog/wp-content/uploads/2019/01/cropped-github-favicon-512.png?fit=32%2C32", in: Persistence.current.context)

        return
            
            HStack {
                RSSRow(rss: rss)
                    .padding()
                    .frame(width: 400, height: 25, alignment: .center)
            }
        
    }
}

struct Demo8: View {
    let button1 = SwipeCellButton(
        buttonStyle: .view,
        title: "",
        systemImage: "",
        view: {
            AnyView(
                Circle()
                    .fill(Color.blue)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "arrowshape.turn.up.left.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                    )
            )
        },
        backgroundColor: .clear,
        action: {}
    )

    let button2 = SwipeCellButton(
        buttonStyle: .view,
        title: "",
        systemImage: "",
        view: {
            AnyView(
                Circle()
                    .fill(Color.orange)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "flag.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                    )
            )
        },
        backgroundColor: .clear,
        action: {}
    )

    let button3 = SwipeCellButton(
        buttonStyle: .view,
        title: "",
        systemImage: "",
        view: {
            AnyView(
                Circle()
                    .fill(Color.red)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "trash.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                    )
            )
        },
        backgroundColor: .clear,
        action: {}
    )

    let button4 = SwipeCellButton(
        buttonStyle: .view,
        title: "",
        systemImage: "",
        view: {
            AnyView(
                Circle()
                    .fill(Color.blue)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "envelope.badge.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                    )
            )
        },
        backgroundColor: .clear,
        action: {}
    )

    var body: some View {
        let rightSlot = SwipeCellSlot(slots: [button1, button2, button3], buttonWidth: 50)
        let leftSlot = SwipeCellSlot(slots: [button4], buttonWidth: 50)
        ScrollView {
            VStack {
                Text("SwipeCell in ScrollView")
                    .dismissSwipeCellForScrollView()  //目前在ScrollView下注入的方式在iOS14下有点问题,所以必须将dissmissSwipeCellForScrollView放置在ScrollView内部
                //dismissSwipeCellForScrollView 只能用于 VStack, 如果是LazyVStack请使用dismissSwipeCellForScrollViewForLazyVStack
                ForEach(0..<40) { _ in
                    Text("mail content....")
                }
                Text("End")
            }
            //.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .swipeCell(cellPosition: .both, leftSlot: leftSlot, rightSlot: rightSlot, clip: false)
    }
}
struct Demo8_Previews: PreviewProvider {
    static var previews: some View {
        Demo8()
    }
}


struct DemoShowStatus:View{

    let button = SwipeCellButton(
        buttonStyle: .titleAndImage,
        title: "Mark",
        systemImage: "bookmark",
        titleColor: .white,
        imageColor: .white,
        view: nil,
        backgroundColor: .green,
        action: { },
        feedback: true
    )

    var slot:SwipeCellSlot{
        SwipeCellSlot(slots: [button])
    }

    @State var status:CellStatus = .showCell

    var body: some View{
        HStack{
            Text("Cell Status:")
            Text(status.rawValue)
                .foregroundColor(.red)
                //get the cell status from Environment
                .transformEnvironment(\.cellStatus, transform: { cellStatus in
                    let temp = cellStatus
                    DispatchQueue.main.async {
                        self.status = temp
                    }
                })
        }
        .frame(maxWidth:.infinity,alignment: .center)
        .frame(height:25)
        .swipeCell(cellPosition: .both, leftSlot: slot, rightSlot: slot)
    }
}
struct DemoShowStatus_Previews: PreviewProvider {
    static var previews: some View {
        DemoShowStatus()
    }
}
