//
//  ListSeperator.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/16/21.
//

//  https://github.com/SchmidtyApps/SwiftUIListSeparator

import UIKit
import SwiftUI

extension View {
    /// Sets the separator style on Lists within this View
    /// - Parameters:
    ///   - style: Style of List separator
    ///   - color: Color of the List separator
    ///   - inset: Edge insets of the List separator
    /// - Returns: The List with the separator modified
    public func listSeparatorStyle(_ style: ListSeparatorStyle, color: UIColor? = nil, inset: EdgeInsets? = nil) -> some View {
        self.modifier(ListSeparatorModifier(style: style, color: color, inset: inset, hideOnEmptyRows: false))
    }
    
    /// Sets the separator style on Lists within this View
    /// - Parameters:
    ///   - style: Style of List separator
    ///   - color: Color of the List separator
    ///   - inset: Edge insets of the List separator
    ///   - hideOnEmptyRows: If true hides divders on any empty rows ie rows shown in the footer
    /// - Returns: The List with the separator modified
    @available(iOS, obsoleted:14.0, message:"hideOnEmptyRows is no longer needed because SwiftUI as of iOS14 always hides empty row separators in the footer")
    public func listSeparatorStyle(_ style: ListSeparatorStyle, color: UIColor? = nil, inset: EdgeInsets? = nil, hideOnEmptyRows: Bool) -> some View {
        self.modifier(ListSeparatorModifier(style: style, color: color, inset: inset, hideOnEmptyRows: hideOnEmptyRows))
    }
}

public enum ListSeparatorStyle {
    case none
    case singleLine
}

private enum ListConstants {
    static let maxDividerHeight: CGFloat = 2
    static let customDividerTag = 8675309
}

/// Modifier to set the separator style on List
private struct ListSeparatorModifier: ViewModifier {
    
    private let style: ListSeparatorStyle
    private let color: UIColor?
    private let inset: UIEdgeInsets?
    private let hideOnEmptyRows: Bool
    
    public init(style: ListSeparatorStyle, color: UIColor?, inset: EdgeInsets?, hideOnEmptyRows: Bool) {
        self.style = style
        self.color = color
        
        if let inset = inset {
            self.inset = UIEdgeInsets(top: inset.top, left: inset.leading, bottom: inset.bottom, right: inset.trailing)
        } else {
            self.inset = nil
        }
        
        self.hideOnEmptyRows = hideOnEmptyRows
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay(dividerSeeker())
    }
    
    private func dividerSeeker() -> some View {
        DividerLineSeekerView(divider: { divider in
            //If we encounter a separator view in this heirachy hide it
            switch self.style {
            case .none:
                divider.isHidden = true
                divider.backgroundColor = .clear
            case .singleLine:
                guard divider.tag != ListConstants.customDividerTag else { return  }

                //Hide the system divider
                divider.isHidden = true
                divider.backgroundColor = .clear

                //TODO: only add the custom divider 1 time
                //Add our custom divider which we have more control over
                let customDivider = UIView()
                customDivider.frame = divider.frame
                customDivider.tag = ListConstants.customDividerTag

                divider.superview?.addSubview(customDivider)
                self.adjust(divider: customDivider)
                
            }
            
        }, table: { table in
            
            if self.hideOnEmptyRows {
                table.tableFooterView = UIView()
            }
            
            if #available(iOS 14, *) {
                table.separatorStyle = .none
                table.separatorColor = .clear
            } else {
                switch self.style {
                case .none:
                    table.separatorStyle = .none
                    table.separatorColor = .clear
                case .singleLine:
                    table.separatorStyle = .singleLine

                    if let color = self.color {
                        table.separatorColor = color
                    }

                    if let inset = self.inset {
                        table.separatorInset = inset
                    }
                }
            }
        })
        //Set frame to +1 of max divider height that way we dont also attempt to change this view
        .frame(width: 1, height: ListConstants.maxDividerHeight + 1, alignment: .leading)
    }
    
    private func adjust(divider: UIView) {
        divider.backgroundColor = self.color ?? .lightGray
        
        if let inset = self.inset {
            let leftInset = inset.left
            //So we dont continually trigger layout subviews
            guard divider.frame.origin.x != leftInset else { return }
            
            divider.frame.origin.x = leftInset
            
            guard let parentWidth = divider.superview?.frame.size.width else { return }
            
            let width = parentWidth - inset.left - inset.right
            
            guard divider.frame.size.width != width else { return }
            divider.frame.size.width = width
        }
    }
}

private struct DividerLineSeekerView : UIViewRepresentable {
    
    var divider: (UIView) -> Void
    var table: (UITableView) -> Void
    
    func makeUIView(context: Context) -> InjectView  {
        let view = InjectView(divider: divider, table: table)
        return view
    }
    
    func updateUIView(_ uiView: InjectView, context: Context) {
        uiView.dividerHandler.updateDividers()
    }
}

//View to inject so we can access UIKit views
class InjectView: UIView {
    var divider: (UIView) -> Void
    var table: (UITableView) -> Void
    
    //So we only inject the handler once
    private var didInjectDividerHandler: Bool = false
    //KVO on ScrollView so we can trigger continuing to update dividers on scroll
    private var scrollViewContentObserver: NSKeyValueObservation?
    
    lazy var dividerHandler: DividerHandlingView = {
        let dividerHandler = DividerHandlingView(divider: self.divider, table: self.table)
        dividerHandler.backgroundColor = .clear
        dividerHandler.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        return dividerHandler
    }()
    
    init(divider: @escaping (UIView) -> Void, table: @escaping (UITableView) -> Void) {
        self.divider = divider
        self.table = table
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        injectDividerHandler()
    }
    
    private func injectDividerHandler() {
        self.dividerHandler.updateDividers()
        
        guard !didInjectDividerHandler, let parentVC = findViewController(), let scrollView = findScrollView(in: parentVC.view) else { return }
        
        scrollView.addSubview(dividerHandler)
        scrollView.bringSubviewToFront(dividerHandler)
        
        //Update the dividers anytime content offset changes indicating a scroll event
        self.scrollViewContentObserver = scrollView.observe(\UIScrollView.contentOffset, options: .new) { (_, _) in

            //TODO: this happens for every offset change including fast scroll/fling. We should make it more performant
            self.dividerHandler.updateDividers()
        }
        
        self.didInjectDividerHandler = true
    }
    
    //Recursive search for scroll view in subviews
    private func findScrollView(in view: UIView) -> UIScrollView? {
        
        //Found the scrollview so just retunr it
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        
        //Continue to iterate thru subview hierarchy
        for subview in view.subviews {
            return findScrollView(in: subview)
        }
        
        return nil
    }
}

//View that will be injected into the scroll view and handles modifying divider lines
class DividerHandlingView: UIView {
    var divider: (UIView) -> Void
    var table: (UITableView) -> Void
    
    init(divider: @escaping (UIView) -> Void, table: @escaping (UITableView) -> Void) {
        self.divider = divider
        self.table = table
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateDividers()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateDividers()
    }
    
    func updateDividers() {
        guard let hostingView = self.getHostingView(view: self) else { return }
        self.handleDividerLineSubviews(of: hostingView)
    }
    
    func getHostingView(view: UIView) -> UIView? {
        findViewController()?.view
    }
    
    /// If we encounter a separator view in this heirachy hide it
    func handleDividerLineSubviews<T : UIView>(of view:T) {
        
        if view.frame.height < ListConstants.maxDividerHeight {
            divider(view)
        }
        
        if let table = view as? UITableView {
            self.table(table)
        }
        
        //Continue to iterate thru subview hierarchy
        for subview in view.subviews {
            handleDividerLineSubviews(of: subview)
        }
    }
}

private extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}



@available(iOS 13.0, macOS 10.15, *)
class RefreshData: ObservableObject {
    @Binding var isDone: Bool
    
    @Published var showText: String
    @Published var showRefreshView: Bool {
        didSet {
            self.showText = "Loading"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if self.showRefreshView {
                    self.showRefreshView = false
                    self.showDone = true
                    self.showText = "Done"
                }
            }
        }
    }
    @Published var pullStatus: CGFloat
    @Published var showDone: Bool {
        didSet {
            if self.showDone && self.isDone {
                self.showDone = false
                self.showText = "Pull to refresh"
            }
            print(self.isDone)
        }
    }
    
    init(isDone:Binding<Bool>) {
        self._isDone = isDone
        self.showText = "Pull to refresh"
        self.showRefreshView = false
        self.pullStatus = 0
        self.showDone = false
    }
}


@available(iOS 13.0, macOS 10.15, *)
public struct RefreshableNavigationView<Content: View>: View {
    let content: () -> Content
    let action: () -> Void
    private var title: String
    @Binding var isDone: Bool

    @ObservedObject var data: RefreshData

    public init(title:String, action: @escaping () -> Void,isDone: Binding<Bool> ,@ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.action = action
        self.content = content
        self._isDone = isDone
        self.data = RefreshData(isDone: isDone)
    }
    
//    public init<leadingItem: View>(title:String, action: @escaping () -> Void ,@ViewBuilder content: @escaping () -> Content, @ViewBuilder leadingItem: @escaping () -> leadingItem) {
//        self.title = title
//        self.action = action
//        self.content = content
//        self.leadingItem = leadingItem
//    }
    
    public var body: some View {
        NavigationView{
            RefreshableList(data: data, action: self.action) {
                self.content()
            }.navigationBarTitle(title)
        }
    }
}

@available(iOS 13.0, macOS 10.15, *)
public struct RefreshableNavigationViewWithItem<Content: View, LeadingItem: View, TrailingItem: View>: View {
    let content: () -> Content
    let leadingItem: () -> LeadingItem
    let trailingItem: () -> TrailingItem
    let action: () -> Void
    private var title: String
    @Binding var isDone: Bool

    @ObservedObject var data: RefreshData

//    public init(title:String, action: @escaping () -> Void ,@ViewBuilder content: @escaping () -> Content) {
//        self.title = title
//        self.action = action
//        self.content = content
//    }
    
    public init(title:String, action: @escaping () -> Void, isDone: Binding<Bool> ,@ViewBuilder leadingItem: @escaping () -> LeadingItem, @ViewBuilder trailingItem: @escaping () -> TrailingItem, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.action = action
        self.content = content
        self.leadingItem = leadingItem
        self.trailingItem = trailingItem
        self._isDone = isDone
        self.data = RefreshData(isDone: isDone)
    }
    
    public var body: some View {
        NavigationView{
            RefreshableList(data: data, action: self.action) {
                self.content()
            }.navigationBarTitle(title)
             .navigationBarItems(leading: self.leadingItem(), trailing: self.trailingItem())
        }
    }
}

@available(iOS 13.0, macOS 10.15, *)
public struct RefreshableList<Content: View>: View {
    @ObservedObject var data: RefreshData
    
    let action: () -> Void
    let content: () -> Content
    
    init(data: RefreshData, action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.data = data
        self.action = action
        self.content = content
        UITableViewHeaderFooterView.appearance().tintColor = UIColor.clear
    }
    
    public var body: some View {
        
        List{
            Section(header: PullToRefreshView(data: self.data)) {
             content()
            }
        }
        .offset(y: -40)
        .onPreferenceChange(RefreshableKeyTypes.PrefKey.self) { values in
            guard let bounds = values.first?.bounds else { return }
            self.data.pullStatus = CGFloat((bounds.origin.y - 106) / 80)
            self.refresh(offset: bounds.origin.y)
        }
    }
    
    func refresh(offset: CGFloat) {
        if offset > 185 && !self.data.showRefreshView && !self.data.showDone {
            self.data.showRefreshView = true
            DispatchQueue.main.async {
                self.action()
            }
            
        }
    }
}

@available(iOS 13.0, macOS 10.15, *)
struct Spinner: View {
    @Binding var percentage: CGFloat
    
    var body: some View {
        GeometryReader{ geometry in
            ForEach(1...10, id: \.self) { i in
                Rectangle()
                    .fill(Color.gray)
                    .cornerRadius(1)
                    .frame(width: 2.5, height: 8)
                    .opacity(self.percentage * 10 >= CGFloat(i) ? Double(i)/10.0 : 0)
                    .offset(x: 0, y: -8)
                    .rotationEffect(.degrees(Double(36 * i)), anchor: .bottom)
            }.offset(x: 20, y: 12)
        }.frame(width: 40, height: 40)
    }
}

@available(iOS 13.0, macOS 10.15, *)
struct RefreshView: View {
    @ObservedObject var data: RefreshData
    
    var body: some View {
        HStack() {
            VStack(alignment: .center){
                if self.data.showDone {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(Color.green)
                        .imageScale(.large)
                } else if (!data.showRefreshView) {
                    Spinner(percentage: self.$data.pullStatus)
                } else {
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                }
                Text(self.data.showText).font(.caption)
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, *)
struct PullToRefreshView: View {
    @ObservedObject var data: RefreshData
    var body: some View {
        GeometryReader{ geometry in
            RefreshView(data: self.data)
                .opacity(Double((geometry.frame(in: CoordinateSpace.global).origin.y - 106) / 80)).preference(key: RefreshableKeyTypes.PrefKey.self, value: [RefreshableKeyTypes.PrefData(bounds: geometry.frame(in: CoordinateSpace.global))])
                .offset(y: -70)
        }
        .offset(y: -20)
    }
}

@available(iOS 13.0, macOS 10.15, *)
struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

@available(iOS 13.0, macOS 10.15, *)
struct RefreshableKeyTypes {
    
    struct PrefData: Equatable {
        let bounds: CGRect
    }

    struct PrefKey: PreferenceKey {
        static var defaultValue: [PrefData] = []

        static func reduce(value: inout [PrefData], nextValue: () -> [PrefData]) {
            value.append(contentsOf: nextValue())
        }

        typealias Value = [PrefData]
    }
}

@available(iOS 13.0, macOS 10.15, *)
struct Spinner_Previews: PreviewProvider {
    static var previews: some View {
        Spinner(percentage: .constant(1))
    }
}
