//
//  ViewExtensions.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 10/27/20.
//

//#if canImport(UIKit) && os(iOS)

import SwiftUI
import Combine
import MessageUI
import CoreMotion
import FeedKit
import CoreData
import Foundation

struct ScrollCell: ViewModifier {
    func body(content: Content) -> some View {
        Group {
            content
            Divider()
        }
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

extension UIFont {
    public var weight: UIFont.Weight {
        guard let weightNumber = traits[.weight] as? NSNumber else { return self.weight2 }
            let weightRawValue = CGFloat(weightNumber.doubleValue)
            let weight = UIFont.Weight(rawValue: weightRawValue)
            return weight
        }

        private var traits: [UIFontDescriptor.TraitKey: Any] {
            return fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any]
                ?? [:]
        }
    private var weight2: UIFont.Weight {
        let fontAttributeKey = UIFontDescriptor.AttributeName.init(rawValue: "NSCTFontUIUsageAttribute")
        if let fontWeight = self.fontDescriptor.fontAttributes[fontAttributeKey] as? String {
            switch fontWeight {
            case "CTFontBoldUsage":
                return UIFont.Weight.bold

            case "CTFontBlackUsage":
                return UIFont.Weight.black

            case "CTFontHeavyUsage":
                return UIFont.Weight.heavy

            case "CTFontUltraLightUsage":
                return UIFont.Weight.ultraLight

            case "CTFontThinUsage":
                return UIFont.Weight.thin

            case "CTFontLightUsage":
                return UIFont.Weight.light

            case "CTFontMediumUsage":
                return UIFont.Weight.medium

            case "CTFontDemiUsage":
                return UIFont.Weight.semibold

            case "CTFontRegularUsage":
                return UIFont.Weight.regular

            default:
                return UIFont.Weight.regular
            }
        }
        return .regular
    }
    
    public var fontWeight: Font.Weight {
        switch self.weight {
        case .regular:
            return .regular
        case .black:
            return .black
        case .bold:
            return .bold
        case .heavy:
            return .heavy
        case .thin:
            return .thin
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        default:
            return .regular
        }
    }
}

extension Font.TextStyle {
    var uiStyle: UIFont.TextStyle {
        switch(self) {
        case .body: return .body
        case .callout: return .callout
        case .largeTitle:
            return .largeTitle
        case .title:
            return .title1
        case .title2:
            return .title2
        case .title3:
            return .title3
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .footnote:
            return .footnote
        case .caption:
            return .caption1
        case .caption2:
            return .caption2
        @unknown default:
            return .body
        }
    }
}
extension Font {
    init(_ style: Font.TextStyle, sizeModifier: CGFloat = 0.0, weight: Font.Weight? = nil, design: Font.Design = .default) {
        let base = UIFont.preferredFont(forTextStyle: style.uiStyle)
        let weight = weight ?? base.fontWeight
        self = Font.system(size: base.pointSize + sizeModifier, weight: weight, design: design)
    }
}

extension View {
  func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}

private struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

enum Appearance: String, Codable, CaseIterable, Identifiable {
  case dark
  case light
  case system

  var id: String { rawValue }
}

struct Preferences: Codable {
  var appearance: Appearance

  static let defaultValue = Preferences(appearance: .system)
}

// MARK: ContentView
class ContentViewModel: ObservableObject {
  @Published("userPreferences") var preferences: Preferences = .defaultValue
}

struct ContentExtView: View {
  @StateObject var model = ContentViewModel()

  var body: some View {
    Picker("Appearance", selection: $model.preferences.appearance) {
      ForEach(Appearance.allCases, id: \.self) {
        Text(verbatim: $0.rawValue)
      }
    }.pickerStyle(SegmentedPickerStyle())
  }
}

// MARK: Published+UserDefaults
private var cancellableSet: Set<AnyCancellable> = []

extension Published where Value: Codable {
  init(wrappedValue defaultValue: Value, _ key: String, store: UserDefaults? = nil) {
    let _store: UserDefaults = store ?? .standard

    if
      let data = _store.data(forKey: key),
      let value = try? JSONDecoder().decode(Value.self, from: data) {
      self.init(initialValue: value)
    } else {
      self.init(initialValue: defaultValue)
    }

    projectedValue
      .sink { newValue in
        let data = try? JSONEncoder().encode(newValue)
        _store.set(data, forKey: key)
      }
      .store(in: &cancellableSet)
  }
}

// MARK: Published+UISceneSession
extension Published where Value: Codable {
  init(wrappedValue defaultValue: Value, _ key: String, session: UISceneSession) {
    if
      let data = session.userInfo?[key] as? Data,
      let value = try? JSONDecoder().decode(Value.self, from: data) {
      self.init(initialValue: value)
    } else {
      self.init(initialValue: defaultValue)
    }

    projectedValue
      .sink { newValue in
        let data = try? JSONEncoder().encode(newValue)
        session.userInfo?[key] = data
      }
      .store(in: &cancellableSet)
  }
}


