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

struct NavigationBarColor: ViewModifier {

  init(backgroundColor: UIColor, tintColor: UIColor) {
    let coloredAppearance = UINavigationBarAppearance()
    coloredAppearance.configureWithOpaqueBackground()
    coloredAppearance.backgroundColor = backgroundColor
    coloredAppearance.titleTextAttributes = [.foregroundColor: tintColor]
    coloredAppearance.largeTitleTextAttributes = [.foregroundColor: tintColor]
                   
    UINavigationBar.appearance().standardAppearance = coloredAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    UINavigationBar.appearance().compactAppearance = coloredAppearance
    UINavigationBar.appearance().tintColor = tintColor
  }

  func body(content: Content) -> some View {
    content
  }
}
extension View {
  func navigationBarColor(backgroundColor: UIColor, tintColor: UIColor) -> some View {
    self.modifier(NavigationBarColor(backgroundColor: backgroundColor, tintColor: tintColor))
  }
}

struct NavigationBarModifier: ViewModifier {
        
    var backgroundColor: UIColor?
    
    init( backgroundColor: UIColor?) {
        self.backgroundColor = backgroundColor
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = .clear
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = .white

    }
    
    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    Color(self.backgroundColor ?? .clear)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}

extension View {
 
    func navigationBarColor(_ backgroundColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor))
    }
}

extension View {
  func background(with color: Color) -> some View {
    background(GeometryReader { geometry in
      Rectangle().path(in: geometry.frame(in: .local)).foregroundColor(color)
    })
  }
}

extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.backgroundColor = UIColor(Color("accent"))
        
        let compactAppearance = UINavigationBarAppearance()
        compactAppearance.backgroundColor = UIColor(Color("accent"))
        
        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.backgroundColor = UIColor(Color("accent"))
        
        navigationBar.standardAppearance = standardAppearance
        navigationBar.compactAppearance = compactAppearance
        navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
    }
}

extension View {
    func phoneOnlyStackNavigationView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return AnyView(self.navigationViewStyle(StackNavigationViewStyle()))
        } else {
            return AnyView(self)
        }
    }
}
