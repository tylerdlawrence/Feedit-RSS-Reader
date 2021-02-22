//
//  SourceListRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import CoreData
import MobileCoreServices
import SwipeCell
import KingfisherSwiftUI

struct RSSRow: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
    
    enum ActionItem {
        case info
        case url
    }
    
    @ObservedObject var rss: RSS
    @ObservedObject var imageLoader: ImageLoader
    @State private var actionSheetShown = false
    @State private var showAlert = false
    @State var infoHaptic = false
    @State private var toggle = false
    
    init(rss: RSS) {
        self.rss = rss
        self.imageLoader = ImageLoader(path: rss.image)
    }
    
    private func iconImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20,alignment: .center)
                .cornerRadius(5)
                .animation(.easeInOut)
                .border(Color("text"), width: 1)
    }
    
    var body: some View {
        
        let infoButton = SwipeCellButton(
            buttonStyle: .image,
            title: "",
            systemImage: "ellipsis",
            view: nil,
            backgroundColor: Color("tab"),
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
        let swipeSlots = SwipeCellSlot(slots: [infoButton], slotStyle: .destructive, buttonWidth: 60)
                HStack(alignment: .center){
                    KFImage(URL(string: rss.image))
                        .placeholder({
                            Image("getInfo")
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20,alignment: .center)
                                .cornerRadius(2)
                                .opacity(0.9)
                                .border(Color("text"), width: 1)
                        })
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20,alignment: .center)
                        .cornerRadius(2)
                        .border(Color("text"), width: 1)
                    Text(rss.title)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .lineLimit(1)
                        .foregroundColor(Color("text"))
                    Spacer()
//                    Text("\(rss.title.count)")
                    Text("\(rss.title.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 1)
                        .background(Color.gray.opacity(0.5))
                        .opacity(0.4)
                        .foregroundColor(Color("text"))
                        .cornerRadius(8)
                }
                .frame(height: 40)
                .onTapGesture {
                }
                .swipeCell(cellPosition: .both, leftSlot: swipeSlots, rightSlot: nil)
                .dismissSwipeCell()
                .frame(height: 25)
                .sheet(isPresented: $infoHaptic, content: { InfoView(rss: rss)
                })
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
                    }.foregroundColor(.red)
                }
                .actionSheet(isPresented: $showAlert) {
                    ActionSheet(
                        title: Text(rss.title),
                        message: nil,
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
                            .destructive(Text("Unsubscribe"), action: {
                                //self.deleteItem()
                            }),
                            .cancel(),
                        ]
                    )
                }.frame(height: 25)
    }

    func countItems() -> Int {
        return CoreDataDataSource<RSSItem>().count
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
    
struct RSSRow_Previews: PreviewProvider {
    static let rss = DataSourceService.current
    static var previews: some View {
        let rss = RSS.create(url: "https://chorus.substack.com/people/2323141-jason-tate",
                             title: "Liner Notes",
                             desc: "Liner Notes is a weekly newsletter from Jason Tate of Chorus.fm.",
                             image: "https://bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com/public/images/8a938a56-8a1e-42dc-8802-a75c20e8df4c_256x256.png", in: CoreData.stack.context)

        return
            RSSRow(rss: rss)
                .padding()
                .frame(width: 400, height: 25, alignment: .center)
            .preferredColorScheme(.dark)
    }
}
