//
//  RSSItemRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//  View once you choose Feed on Main Screen

import SwiftUI
import UIKit
import Combine
import SwiftUIX
import ASCollectionView
import SwipeableView
import Introspect
import SwipeCellKit
import FeedKit
import KingfisherSwiftUI
import SDWebImageSwiftUI
import SwipeCellKit
import Intents

struct RSSItemRow: View {

    @Environment(\.managedObjectContext) var managedObjectContext

    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    @ObservedObject var itemWrapper: RSSItem
    var contextMenuAction: ((RSSItem) -> Void)?
    var imageLoader: ImageLoader!
    var isDone: (() -> Void)? //((RSSItem) -> Void)?
    @State private var selectedItem: RSSItem?
    @ObservedObject static var container = SwManager()
    
    init(rssViewModel: RSSFeedViewModel, wrapper: RSSItem, isRead: (() -> Void)? = nil, menu action: ((RSSItem) -> Void)? = nil) {
        //self.text = ""
        self.rssFeedViewModel = rssViewModel
        itemWrapper = wrapper
        isDone = isRead
        contextMenuAction = action
        self.model = GroupModel(icon: "text.justifyleft", title: "")
    }
    
    var model: GroupModel

    private var pureTextView: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack{
                KFImage(URL(string: rssSource.imageURL))
                    .placeholder({
                    Image(systemName: model.icon)
                        .imageScale(.medium)
                        .font(.system(size: 16, weight: .heavy))
                        //.layoutPriority(10)
                        .foregroundColor(.white)
                        .background(
                            Rectangle().fill(model.color)
                                .opacity(0.6)
                                .frame(width: 25, height: 25) //,alignment: .center)
                                .cornerRadius(3)
                        )})
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25,alignment: .center)
                        .cornerRadius(3)
                        //.border(Color.clear, width: 1)
                if itemWrapper.isArchive {
                    Image(systemName: "star.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        //.foregroundColor(Color("text"))
                        .frame(width: 12, height: 12)
                        .opacity(0.7)
                    }
                }
                .padding(.top, 3.0)
            VStack(alignment: .leading, spacing: 4) {
                Text(itemWrapper.title)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    //.font(.headline)
                    .lineLimit(3)
                Text(itemWrapper.desc.trimHTMLTag.trimWhiteAndSpace)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    //.font(.subheadline)
                    .opacity(0.7)
                    .foregroundColor(Color.gray)
                    .lineLimit(1)
                HStack{
                    if itemWrapper.isDone {
                        MarkAsRead(isRead: false)
                    }
                    Text("\(itemWrapper.createTime?.string() ?? "")")
                        //.font(.custom("Gotham", size: 14))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
//                    if itemWrapper.isArchive {
//                        Image(systemName: "star.fill")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            //.foregroundColor(Color("text"))
//                            .frame(width: 12, height: 12)
//                            .opacity(0.7)
//                        }
                    }
                }
            }
        }
    }


    
    @State var value:CGFloat = 0.0
    @State var didSwipe:Bool = false
    

    
    var body: some View{

    
//        let drag = DragGesture()
//            .onEnded{ (dragValue) in
//                didSwipe = abs(dragValue.translation.width) > 30
//            }
//            .onChanged{ (dragValue) in self.value = dragValue.translation.width}
        
//        let left = [
//            Action(title: "", iconName: "star.fill", bgColor: Color("Color"), onAction: {self.contextMenuAction?(self.itemWrapper)})
//                    //{self.isDone?()})
//        ]
//
//        let right = [
//            Action(title: "", iconName: "circle", bgColor: Color("Color"), onAction: {self.contextMenuAction?(self.itemWrapper)})
//        ]
        
//        VStack(alignment: .leading) {
//            HStack(alignment: .top) {
//                VStack{
//                    Button(action: {
//                        self.itemWrapper.isDone.toggle()
//                    }) {
//                        MarkAsRead(isRead: itemWrapper.isDone)
//                            .font(.caption)
//                        }
//                    }
                    //.padding(.top, 5.0)
        
            pureTextView
                //.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
//                .gesture(drag)
//                .onTapGesture {
//                    self.value = 0
//                    didSwipe = false
//                }
//                SwipeableView(content: {
////                    GroupBox {
//                    pureTextView
//                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
////                        .gesture(drag)
////                        .onTapGesture {
////                            self.value = 0
////                            didSwipe = false
////                        }
////                    }
//                },
//                leftActions: left,
//                rightActions: right,
//                rounded: true,
//                container: RSSItemRow.container
//                ).frame(height: 75) //90
                
                //.gesture(DragGesture(minimumDistance: 30, coordinateSpace: .local))
                
                    .contextMenu {
                        ActionContextMenu(
                            label: itemWrapper.isArchive ? "Unstar" : "Star",
                            systemName: "star.\(itemWrapper.isArchive ? "fill" : "")",
                            onAction: {
                                self.contextMenuAction?(self.itemWrapper)
                            }
                        )
                    }
                    .contextMenu {
                        ActionContextMenu(
                            label: itemWrapper.isDone ? "Mark As Unread" : "Mark As Read",
                            systemName: "circle.fill\(itemWrapper.isDone ? "" : "circle")",
                            onAction: {
                                self.contextMenuAction?(self.itemWrapper)
                            }
                        )
                    }
//            }
//        }
    }
}

struct MarkAsRead: View {
    
    let isRead: Bool;
    
    var body: some View {
        Text("")
//        Image(isRead ? "" : "smartFeedUnread")
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: 15, height: 15, alignment: .center)
//            .foregroundColor(isRead ? .clear : .blue)
    }
}
 
//struct MarkAsRead_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            MarkAsRead(isRead: true)
//            MarkAsRead(isRead: false)
//        }
//        .padding()
//        .previewLayout(.sizeThatFits)
//        }
//    }
struct GroupModel: Identifiable
{
    var icon: String
    var title: String
    var contentCount: Int? = Int.random(in: 0 ... 20)
    var color: Color = [Color.red, Color.orange, Color.blue, Color.purple].randomElement()!

    static var demo = GroupModel(icon: "globe", title: "Feed Demo", contentCount: 19)

    var id: String { title }
}
struct GroupSmall: View {
    var model: GroupModel

    var body: some View
    {
        HStack(alignment: .center)
        {
            Image(systemName: model.icon)
                .font(.system(size: 16, weight: .regular))
                .padding(14)
                .foregroundColor(.white)
                .background(
                    Circle().fill(model.color)
                )

            Text(model.title)
                .multilineTextAlignment(.leading)
                .foregroundColor(Color(.label))

            Spacer()
            model.contentCount.map
            {
                Text("\($0)")
            }
        }
        .padding(10)
    }
}

struct GroupSmall_Previews: PreviewProvider
{
    static var previews: some View
    {
        GroupSmall(model: .demo)
    }
}

public class SWViewModel: ObservableObject {
    let id: UUID = UUID.init()
    @Published var state: ViewState {
        didSet {
            if state != .center {
                self.stateDidChange.send(self)
            }
        }
    }
    
    @Published var onChangeSwipe: OnChangeSwipe = .noChange
    @Published var dragOffset: CGSize
    
    let stateDidChange = PassthroughSubject<SWViewModel, Never>()
    let otherActionTapped = PassthroughSubject<Bool, Never>()
    
    init(state: ViewState, size: CGSize) {
        self.state = state
        self.dragOffset = size
    }
    
    public func otherTapped(){
        self.otherActionTapped.send(true)
    }
    
    public func goToCenter(){
        self.dragOffset = .zero
        self.state = .center
        self.onChangeSwipe = .noChange
    }
}

public class SwManager: ObservableObject {
    private var views: [SWViewModel]
    private var subscriptions = Set<AnyCancellable>()
    
    public init() {
        views = []
    }
    
    public func hideAllViews() {
        self.views.forEach {
            $0.goToCenter()
        }
    }
    
    public func addView(_ view: SWViewModel) {
        views.append(view)
        view.stateDidChange.sink(receiveValue: { vm in
            if self.views.count != 0 {
                self.views.forEach {
                    if vm.id != $0.id && $0.state != .center{
                        $0.goToCenter()
                    }
                }
            }
        }).store(in: &subscriptions)
        
        view.otherActionTapped.sink(receiveValue: { _ in
            if self.views.count != 0 {
                self.views.forEach {
                    $0.goToCenter()
                }
            }
        }).store(in: &subscriptions)
    }
}

public struct Action: Identifiable {
    public init(title: String, iconName: String, bgColor: Color, onAction: @escaping () -> ()?) {
        self.title = title
        self.iconName = iconName
        self.bgColor = bgColor
        self.onAction = onAction
    }
    
    public let id: UUID = UUID.init()
    let title: String
    let iconName: String
    let bgColor: Color
    let onAction: () -> ()?
}

open class EditActionsVM: ObservableObject {
    let actions: [Action]
    public init(_ actions: [Action], maxActions: Int) {
        self.actions = Array(actions.prefix(maxActions))
    }
}

enum ActionSide: CaseIterable {
    case left
    case right
}

public struct EditActions: View {
    
    @ObservedObject var viewModel: EditActionsVM
    @Binding var offset: CGSize
    @Binding var state: ViewState
    @Binding var onChangeSwipe: OnChangeSwipe
    @State var side: ActionSide
    @State var rounded: Bool
    
    
    fileprivate func makeActionView(_ onAction: Action, height: CGFloat) -> some View {
        return VStack (alignment: .center, spacing: 0){
            #if os(macOS)
            Image(onAction.iconName)
                .font(.system(size: 20))
                .padding(.bottom, 8)
            #endif
            #if os(iOS)
            if getWidth() > 35 {
                Image(systemName: onAction.iconName)
                    .font(.system(size: 20))
                    .padding(.bottom, 8)
                    .opacity(getWidth() < 30 ? 0.1 : 1 )
            }
            
            #endif
            if viewModel.actions.count < 4 && height > 50 {
                
                Text(getWidth() > 70 ? onAction.title : "")
                    .font(.system(size: 10, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .frame(width: 80)
            }
        }
        .padding()
        .frame(width: getWidth(), height: height)
        .background(onAction.bgColor.opacity(getWidth() < 30 ? 0.1 : 1 ))
        .cornerRadius(rounded ? 10 : 0)
        
    }
    private func getWidth() -> CGFloat {
        
        let width = CGFloat(offset.width / CGFloat(viewModel.actions.count))
        // - left / + right
        switch side {
        case .left:
            if width < 0 {
                return addPaddingsIfNeeded(width: abs(width))
            } else {
                return 0
            }
        case .right:
            if width > 0 {
                return addPaddingsIfNeeded(width: abs(width))
            } else {
                return 0
            }
        }
        
    }
    
    private func addPaddingsIfNeeded(width:CGFloat) -> CGFloat {
        if rounded {
            return width - 5 > 0 ? width - 5 : 0
        } else {
            return width
        }
    }
    
    private func makeView(_ geometry: GeometryProxy) -> some View {
        #if DEBUG
        print("EditActions: = \(geometry.size.width) , \(geometry.size.height)")
        #endif
        
        return HStack(alignment: .center, spacing: rounded ? 5 : 0) {
            ForEach(viewModel.actions) { action in
                Button(action: {
                    action.onAction()
                    
                    withAnimation(.easeOut) {
                        self.offset = CGSize.zero
                        self.state = .center
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(Animation.easeOut) {
                            if self.state == .center {
                                self.onChangeSwipe = .noChange
                            }
                        }
                    }
                    
                }, label: {
                    #if os(iOS)
                    self.makeActionView(action, height: geometry.size.height)
                        .accentColor(.white)
                    #endif
                    
                    #if os(macOS)
                    self.makeActionView(action, height: geometry.size.height)
                        .colorMultiply(.white)
                    #endif

                    
                })
            }
        }
    }
    
    public var body: some View {
        
        GeometryReader { reader in
            HStack {
                if self.side == .left { Spacer () }
                
                self.makeView(reader)
                
                if self.side == .right { Spacer () }
            }
            
        }
    }
}

struct EditActions_Previews: PreviewProvider {
    
    static var actions = [
        Action(title: "No interest", iconName: "trash", bgColor: .red, onAction: {}),
        Action(title: "Request offer", iconName: "doc.text", bgColor: .yellow, onAction: {}),
        Action(title: "Order", iconName: "doc.text.fill", bgColor: .red, onAction: {}),
        Action(title: "Order provided", iconName: "car", bgColor: .green, onAction: {}),
    ]
    static var previews: some View {
        Group {
            
            EditActions(viewModel: EditActionsVM(actions, maxActions: 4), offset: .constant(CGSize.init(width: 300, height: 10)), state: .constant(.center), onChangeSwipe: .constant(.noChange), side: .right, rounded: false)
                .previewLayout(.fixed(width: 450, height: 400))
            
            EditActions(viewModel: EditActionsVM(actions, maxActions: 4), offset: .constant(CGSize.init(width: -300, height: 10)), state: .constant(.center), onChangeSwipe: .constant(.noChange), side: .left, rounded: false)
                .previewLayout(.fixed(width: 450, height: 100))
            
            EditActions(viewModel: EditActionsVM(actions, maxActions: 2), offset: .constant(CGSize.init(width: -300, height: 10)), state: .constant(.center), onChangeSwipe: .constant(.noChange), side: .left, rounded: false)
                .previewLayout(.fixed(width: 450, height: 150))
            
            EditActions(viewModel: EditActionsVM(actions, maxActions: 3), offset: .constant(CGSize.init(width: 300, height: 10)), state: .constant(.center), onChangeSwipe: .constant(.noChange), side: .right, rounded: true)
                .previewLayout(.fixed(width: 450, height: 100))
            
            EditActions(viewModel: EditActionsVM(actions, maxActions: 4), offset: .constant(CGSize.init(width: -300, height: 10)), state: .constant(.center), onChangeSwipe: .constant(.noChange), side: .left, rounded: true)
                .previewLayout(.fixed(width: 550, height: 180))
            
            
        }
    }
}


public enum ViewState: CaseIterable {
    case left
    case right
    case center
}

enum OnChangeSwipe {
    case leftStarted
    case rightStarted
    case noChange
}

public struct SwipeableView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: SWViewModel
    var container: SwManager?
    var rounded: Bool
    var leftActions: EditActionsVM
    var rightActions: EditActionsVM
    let content: Content
    
    @State var finishedOffset: CGSize = .zero
    
    public init(@ViewBuilder content: () -> Content, leftActions: [Action], rightActions: [Action], rounded: Bool = false, container: SwManager? = nil ) {
        
        self.content = content()
        self.leftActions = EditActionsVM(leftActions, maxActions: leftActions.count)
        self.rightActions = EditActionsVM(rightActions, maxActions: rightActions.count)
        self.rounded = rounded
        
        viewModel = SWViewModel(state: .center, size: .zero)
        self.container = container
        
        container?.addView(viewModel)
        
        
    }
    
    private func makeView(_ geometry: GeometryProxy) -> some View {
        return content
    }
    
    public var body: some View {
        
        let dragGesture = DragGesture(minimumDistance: 1.0, coordinateSpace: .global)
            .onChanged(self.onChanged(value:))
            .onEnded(self.onEnded(value:))
        
        return GeometryReader { reader in
            self.makeLeftActions()
            self.makeView(reader)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: self.viewModel.dragOffset.width)
                .zIndex(100)
                .onTapGesture(count: 1, perform: { self.toCenterWithAnimation()})
                .highPriorityGesture( dragGesture )
            self.makeRightActions()
        }
    }
    
    private func makeRightActions() -> AnyView {
        
        return AnyView(EditActions(viewModel: rightActions,
                                   offset: .init(get: {self.viewModel.dragOffset}, set: {self.viewModel.dragOffset = $0}),
                                   state: .init(get: {self.viewModel.state}, set: {self.viewModel.state = $0}),
                                   onChangeSwipe: .init(get: {self.viewModel.onChangeSwipe}, set: {self.viewModel.onChangeSwipe = $0}),
                                   side: .right,
                                   rounded: rounded)
                        .animation(.easeInOut))
    }
    
    private func makeLeftActions() -> AnyView {
        
        return AnyView(EditActions(viewModel: leftActions,
                                   offset: .init(get: {self.viewModel.dragOffset}, set: {self.viewModel.dragOffset = $0}),
                                   state: .init(get: {self.viewModel.state}, set: {self.viewModel.state = $0}),
                                   onChangeSwipe: .init(get: {self.viewModel.onChangeSwipe}, set: {self.viewModel.onChangeSwipe = $0}),
                                   side: .left,
                                   rounded: rounded)
                        .animation(.easeInOut))
    }
    
    private func toCenterWithAnimation() {
        withAnimation(.easeOut) {
            self.viewModel.dragOffset = CGSize.zero
            self.viewModel.state = .center
            self.viewModel.onChangeSwipe = .noChange
            self.viewModel.otherTapped()
        }
    }
    
    private func onChanged(value: DragGesture.Value) {
        
        if self.viewModel.state == .center {
            
            if value.translation.width <= 0  {
                //&& value.translation.height > -60 && value.translation.height < 60
                self.viewModel.onChangeSwipe = .leftStarted
                self.viewModel.dragOffset.width = value.translation.width
                
            } else if self.viewModel.dragOffset.width >= 0 {
                //&& value.translation.height > -60 && value.translation.height < 60
                
                self.viewModel.onChangeSwipe = .rightStarted
                self.viewModel.dragOffset.width = value.translation.width
            }
        } else {
            // print(value.translation.width)
            if self.viewModel.dragOffset.width != .zero {
                self.viewModel.dragOffset.width = finishedOffset.width + value.translation.width
                //  print(self.viewModel.dragOffset.width)
            } else {
                self.viewModel.onChangeSwipe = .noChange
                self.viewModel.state = .center
            }
        }
    }
    
    private func onEnded(value: DragGesture.Value) {
        
        finishedOffset = value.translation
        
        if self.viewModel.dragOffset.width <= 0 {
            // left
            if self.viewModel.state == .center && value.translation.width <= -50 {
                
                var offset = (CGFloat(min(4, self.leftActions.actions.count)) * -80)
                
                if self.rounded {
                    offset -= CGFloat(min(4, self.leftActions.actions.count)) * 5
                }
                withAnimation(.easeOut) {
                    self.viewModel.dragOffset = CGSize.init(width: offset, height: 0)
                    self.viewModel.state = .left
                }
                
            } else {
                self.toCenterWithAnimation()
                finishedOffset = .zero
            }
            
            
        } else if self.viewModel.dragOffset.width >= 0 {
            // right
            if self.viewModel.state == .center && value.translation.width > 50{
                
                var offset = (CGFloat(min(4, self.rightActions.actions.count)) * +80)
                if self.rounded {
                    offset += CGFloat(min(4, self.rightActions.actions.count)) * 5
                }
                withAnimation(.easeOut) {
                    self.viewModel.dragOffset = (CGSize.init(width: offset, height: 0))
                    self.viewModel.state = .right
                }
            } else {
                self.toCenterWithAnimation()
            }
        }
    }
    
    
}

@available(iOS 14.0, *)
struct SwipebleView_Previews: PreviewProvider {
    @ObservedObject static var container = SwManager()
    static var previews: some View {
        
        let left = [
            Action(title: "Note", iconName: "pencil", bgColor: .red, onAction: {}),
            Action(title: "Edit doc", iconName: "doc.text", bgColor: .yellow, onAction: {}),
            Action(title: "New doc", iconName: "doc.text.fill", bgColor: .green, onAction: {})
        ]
        
        let right = [
            Action(title: "Note", iconName: "pencil", bgColor: .blue, onAction: {}),
            Action(title: "Edit doc", iconName: "doc.text", bgColor: .yellow, onAction: {})
        ]
        
        return GeometryReader { reader in
            ScrollView {
                Spacer()
                HStack {
                    Text("Independed view:")
                        .bold()
                    Spacer()
                }
                SwipeableView(content: {
                    GroupBox {
                        Text("View content")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                },
                leftActions: left,
                rightActions: right,
                rounded: true
                ).frame(height: 90)
                HStack {
                    Text("Container:")
                        .bold()
                    Spacer()
                }
                
                
                SwipeableView(content: {
                    Text("View content")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.blue.opacity(0.5))
                },
                leftActions: left,
                rightActions: right,
                rounded: false,
                container: container
                ).frame(height: 90)
                
                SwipeableView(content: {
                    Text("View content")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.blue.opacity(0.5))
                },
                leftActions: left,
                rightActions: right,
                rounded: false,
                container: container
                ).frame(height: 90)
                
                Spacer()
            }.padding()
        }
        
    }
}
