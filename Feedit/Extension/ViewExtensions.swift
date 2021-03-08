//
//  ViewExtensions.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 10/27/20.
//

#if canImport(UIKit) && os(iOS)

import SwiftUI

@available(iOS 13.0, tvOS 13.0, *)
public struct ActivityIndicator: UIViewRepresentable {
    @Binding
    var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    public init(isAnimating: Binding<Bool>, style: UIActivityIndicatorView.Style) {
        self._isAnimating = isAnimating
        self.style = style
    }

    public func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

#endif

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct IfLet<T, Content: View>: View {
    let value: T?
    let content: (T) -> Content

    public init(_ value: T?, @ViewBuilder content: @escaping (T) -> Content) {
        self.value = value
        self.content = content
    }

    public var body: some View {
        if let value = value {
            content(value)
        }
    }
}

extension Bool: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        switch value.lowercased() {
        case "nope":
            self = false
        case "yep":
            self = true
        case "maybe", "🤷🏼‍♂️":
            self = [true, false].randomElement() ?? false
        default:
            self = false
        }
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct MakeView<Content: View>: View {
    let content: Content

    public init(@ViewBuilder make: () -> Content) {
        self.content = make()
    }

    public var body: some View {
        content
    }
}

#if canImport(AppKit)

public struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    public init(
        material: NSVisualEffectView.Material = .contentBackground,
        blendingMode: NSVisualEffectView.BlendingMode = .withinWindow
    ) {
        self.material = material
        self.blendingMode = blendingMode
    }

    public func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = NSVisualEffectView.State.active
        return visualEffectView
    }

    public func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}

#else

public struct VisualEffectView: UIViewRepresentable {
    let effect: UIVisualEffect

    public init(effect: UIVisualEffect) {
        self.effect = effect
    }

    public func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView()
    }

    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}

#endif

extension View {
    func phoneOnlyStackNavigationView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return AnyView(self.navigationViewStyle(StackNavigationViewStyle()))
        } else {
            return AnyView(self)
        }
    }
}

extension CATransition {
    func fadeTransition() -> CATransition {
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromRight

        return transition
    }
}

extension DisclosureGroup where Label == Text {
  public init<V: Hashable, S: StringProtocol>(
    _ label: S,
    tag: V,
    selection: Binding<V?>,
    content: @escaping () -> Content) {
    let boolBinding: Binding<Bool> = Binding(
      get: { selection.wrappedValue == tag },
      set: { newValue in
        if newValue {
          selection.wrappedValue = tag
        } else {
          selection.wrappedValue = nil
        }
      }
    )

    self.init(
      label,
      isExpanded: boolBinding,
      content: content
    )
  }
}

struct ListSeparatorStyle: ViewModifier {
    
    let style: UITableViewCell.SeparatorStyle
    
    func body(content: Content) -> some View {
        content
            .onAppear() {
                UITableView.appearance().separatorStyle = self.style
            }
    }
}
 
extension View {
    
    func listSeparatorStyle(style: UITableViewCell.SeparatorStyle) -> some View {
        ModifiedContent(content: self, modifier: ListSeparatorStyle(style: style))
    }
}
