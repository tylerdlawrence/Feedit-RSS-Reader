//
//  SourceListRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import UIKit
import SwipeCellKit
import CoreData
import Introspect
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
    @State private var showSheet = false
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
            systemImage: "ellipsis.circle",
            view: nil,
            backgroundColor: Color("tab"),
            action: { showAlert.toggle()
            },
            feedback: true
        )
        
        let clipboardButton = SwipeCellButton(
            buttonStyle: .image,
            title: "",
            systemImage: "doc.on.clipboard",
            imageColor: .white,
            view: nil,
            backgroundColor: .systemGray2,
            action: { UIPasteboard.general.setValue(rss.url,
                                                    forPasteboardType: kUTTypePlainText as String)
            }
        )
        let deleteButton = SwipeCellButton(
            buttonStyle: .image,
            title: "",
            systemImage: "xmark",
            titleColor: .white,
            imageColor: .white,
            view: nil,
            backgroundColor: .red,
            action: { showSheet.toggle() },
            feedback: true
        )
        
        let swipeSlots = SwipeCellSlot(slots: [clipboardButton, infoButton], slotStyle: .destructive, buttonWidth: 60)
        
        let deleteSlot = SwipeCellSlot(slots: [deleteButton], slotStyle: .destructive, buttonWidth: 60)
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
//                        .font(.caption)
//                        .fontWeight(.bold)
//                        .padding(.horizontal, 7)
//                        .padding(.vertical, 1)
//                        .background(Color.gray.opacity(0.5))
//                        .opacity(0.4)
//                        .foregroundColor(Color("text"))
//                        .cornerRadius(8)
                }
                .frame(height: 40)
                .onTapGesture {
                }
                .swipeCell(cellPosition: .both, leftSlot: swipeSlots, rightSlot: deleteSlot)
                .dismissSwipeCell()
                .frame(height: 25)
                .sheet(isPresented: $infoHaptic, content: { InfoView(rss: rss)})
//                .sheet(isPresented: $showSheet, content: { Text("Hello world")})
                .alert(isPresented: $showSheet) {
                    Alert(
                        title: Text("Unsubscribe from \(rss.title)?"),
                        message: nil,
                        primaryButton: .destructive(
                            Text("Unsubscribe"),
                            action: {
                                print("deleted")
                                dismissDestructiveDelayButton()
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
                        dismissDestructiveDelayButton()
//                        self.deleteItems()
//                        withAnimation(.easeIn){deleteItem()}
                    }, label: {
                        Label("Unsubscribe from \(rss.title)?", systemImage: "xmark")
                    })
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
                                dismissDestructiveDelayButton()
                            }),
                            .cancel(),
                        ]
                    )
                }.frame(height: 25)
    }
}
    
struct RSSRow_Previews: PreviewProvider {
    static let rss = DataSourceService.current
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    static var previews: some View {
        let rss = RSS.create(url: "https://chorus.substack.com/people/2323141-jason-tate",
                             title: "Liner Notes",
                             desc: "Liner Notes is a weekly newsletter from Jason Tate of Chorus.fm.",
                             image: "https://bucketeer-e05bbc84-baa3-437e-9518-adb32be77984.s3.amazonaws.com/public/images/8a938a56-8a1e-42dc-8802-a75c20e8df4c_256x256.png", in: Persistence.current.context)

        return
            RSSRow(rss: rss)
                .padding()
                .frame(width: 400, height: 25, alignment: .center)
            .preferredColorScheme(.dark)
    }
}

class IndicatorView: UIView {
    var color = UIColor.clear {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        color.set()
        UIBezierPath(ovalIn: rect).fill()
    }
}

enum ActionDescriptor {
    case read, unread, more, flag, trash
    
    func title(forDisplayMode displayMode: ButtonDisplayMode) -> String? {
        guard displayMode != .imageOnly else { return nil }
        
        switch self {
        case .read: return "Read"
        case .unread: return "Unread"
        case .more: return "More"
        case .flag: return "Flag"
        case .trash: return "Trash"
        }
    }
    
    func image(forStyle style: ButtonStyle, displayMode: ButtonDisplayMode) -> UIImage? {
        guard displayMode != .titleOnly else { return nil }
        
        let name: String
        switch self {
        case .read: name = "Read"
        case .unread: name = "Unread"
        case .more: name = "More"
        case .flag: name = "Flag"
        case .trash: name = "Trash"
        }
        
    #if canImport(Combine)
        if #available(iOS 13.0, *) {
            let name: String
            switch self {
            case .read: name = "envelope.open.fill"
            case .unread: name = "envelope.badge.fill"
            case .more: name = "ellipsis.circle.fill"
            case .flag: name = "flag.fill"
            case .trash: name = "trash.fill"
            }
            
            if style == .backgroundColor {
                let config = UIImage.SymbolConfiguration(pointSize: 23.0, weight: .regular)
                return UIImage(systemName: name, withConfiguration: config)
            } else {
                let config = UIImage.SymbolConfiguration(pointSize: 22.0, weight: .regular)
                let image = UIImage(systemName: name, withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysTemplate)
                return circularIcon(with: color(forStyle: style), size: CGSize(width: 50, height: 50), icon: image)
            }
        } else {
            return UIImage(named: style == .backgroundColor ? name : name + "-circle")
        }
    #else
        return UIImage(named: style == .backgroundColor ? name : name + "-circle")
    #endif
    }
    
    func color(forStyle style: ButtonStyle) -> UIColor {
    #if canImport(Combine)
        switch self {
        case .read, .unread: return UIColor.systemBlue
        case .more:
            if #available(iOS 13.0, *) {
                if UITraitCollection.current.userInterfaceStyle == .dark {
                    return UIColor.systemGray
                }
                return style == .backgroundColor ? UIColor.systemGray3 : UIColor.systemGray2
            } else {
                return #colorLiteral(red: 0.7803494334, green: 0.7761332393, blue: 0.7967314124, alpha: 1)
            }
        case .flag: return UIColor.systemOrange
        case .trash: return UIColor.systemRed
        }
    #else
        switch self {
        case .read, .unread: return #colorLiteral(red: 0, green: 0.4577052593, blue: 1, alpha: 1)
        case .more: return #colorLiteral(red: 0.7803494334, green: 0.7761332393, blue: 0.7967314124, alpha: 1)
        case .flag: return #colorLiteral(red: 1, green: 0.5803921569, blue: 0, alpha: 1)
        case .trash: return #colorLiteral(red: 1, green: 0.2352941176, blue: 0.1882352941, alpha: 1)
        }
    #endif
    }
    
    func circularIcon(with color: UIColor, size: CGSize, icon: UIImage? = nil) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        UIBezierPath(ovalIn: rect).addClip()

        color.setFill()
        UIRectFill(rect)

        if let icon = icon {
            let iconRect = CGRect(x: (rect.size.width - icon.size.width) / 2,
                                  y: (rect.size.height - icon.size.height) / 2,
                                  width: icon.size.width,
                                  height: icon.size.height)
            icon.draw(in: iconRect, blendMode: .normal, alpha: 1.0)
        }

        defer { UIGraphicsEndImageContext() }

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
enum ButtonDisplayMode {
    case titleAndImage, titleOnly, imageOnly
}

enum ButtonStyle {
    case backgroundColor, circular
}

class MailTableViewController: UITableViewController {
    var items: [RSS] = []
    
    var defaultOptions = SwipeOptions()
    var isSwipeRightEnabled = true
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    var buttonStyle: ButtonStyle = .backgroundColor
    var usesTallCells = false
}
