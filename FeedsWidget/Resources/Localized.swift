// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Plural format key: "%#@localized_count@"
  internal static func localizedCount(_ p1: Int) -> String {
    return L10n.tr("Localizable", "LocalizedCount", p1)
  }
  /// Your smart feeds, summarized.
  internal static let smartFeedSummaryWidgetDescription = L10n.tr("Localizable", "View your smart folder counts")
  /// Your Smart Feed Summary
  internal static let smartFeedSummaryWidgetTitle = L10n.tr("Localizable", "Smart Folders")
  /// Starred
  internal static let starred = L10n.tr("Localizable", "Starred")
  /// A sneak peek at your starred articles.
  internal static let starredWidgetDescription = L10n.tr("Localizable", "View your starred articles")
  /// When you mark articles as Starred, they'll appear here.
  internal static let starredWidgetNoItems = L10n.tr("Localizable", "No starred articles")
  /// Starred
  internal static let starredWidgetNoItemsTitle = L10n.tr("Localizable", "Starred")
  /// Your Starred Articles
  internal static let starredWidgetTitle = L10n.tr("Localizable", "Starred Articles")
  /// Plural format key: "%#@starred_count@"
  internal static func starredCount(_ p1: Int) -> String {
    return L10n.tr("Localizable", "StarredCount", p1)
  }
  /// Today  
  internal static let today = L10n.tr("Localizable", "All")
  /// A sneak peek at recently published unread articles.
  internal static let todayWidgetDescription = L10n.tr("Localizable", "Most recent articles")
  /// There are no recent unread articles left to read.
  internal static let todayWidgetNoItems = L10n.tr("Localizable", "You're up to date!")
  /// Today
  internal static let todayWidgetNoItemsTitle = L10n.tr("Localizable", "All Articles")
  /// Your Today Articles
  internal static let todayWidgetTitle = L10n.tr("Localizable", "All Articles")
  /// Plural format key: "%#@today_count@"
  internal static func todayCount(_ p1: Int) -> String {
    return L10n.tr("Localizable", "TodayCount", p1)
  }
  /// Unread
  internal static let unread = L10n.tr("Localizable", "Unread")
  /// A sneak peek at your unread articles.
  internal static let unreadWidgetDescription = L10n.tr("Localizable", "Most recent unread articles")
  /// There are no unread articles left to read.
  internal static let unreadWidgetNoItems = L10n.tr("Localizable", "You're up to date!")
  /// Unread
  internal static let unreadWidgetNoItemsTitle = L10n.tr("Localizable", "Unread")
  /// Your Unread Articles
  internal static let unreadWidgetTitle = L10n.tr("Localizable", "Unread")
  /// Plural format key: "%#@unread_count@"
  internal static func unreadCount(_ p1: Int) -> String {
    return L10n.tr("Localizable", "UnreadCount", p1)
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type

