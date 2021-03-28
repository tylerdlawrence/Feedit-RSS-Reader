//
//  ToolbarModifier.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/25/21.
//

//import SwiftUI
//import Combine
//import Foundation
//
//struct ToolbarModifier: ViewModifier {
//    
////    @EnvironmentObject private var sceneModel: SceneModel
////    @EnvironmentObject private var timelineModel: TimelineModel
//    
//    @EnvironmentObject private var rss: RSS
//    @EnvironmentObject var rssDataSource: RSSDataSource
//    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
//    
//    @Environment(\.presentationMode) var presentationMode
//    #if os(iOS)
//    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
//    #endif
//    @State private var isReadFiltered: Bool? = nil
//    
//    func body(content: Content) -> some View {
//        content
//            .toolbar {
//                #if os(iOS)
//                ToolbarItem(placement: .primaryAction) {
//                    Button {
//                        if let filter = isReadFiltered {
//                            rssFeedViewModel.changeReadFilterSubject.send(!filter)
//                        }
//                    } label: {
//                        if isReadFiltered ?? false {
////                            AppAssets.filterActiveImage.font(.headline)
//                        } else {
////                            AppAssets.filterInactiveImage.font(.headline)
//                        }
//                    }
//                    .onReceive(rssFeedViewModel.readFilterAndFeedsPublisher!) { (_, filtered) in
//                        isReadFiltered = filtered
//                    }
//                    .hidden(isReadFiltered == nil)
//                    .help(isReadFiltered ?? false ? "Show Read Articles" : "Filter Read Articles")
//                }
//                
//                ToolbarItem(placement: .bottomBar) {
//                    Button {
//                        rssFeedViewModel.markAllAsRead()
//                        #if os(iOS)
//                        if horizontalSizeClass == .compact {
//                            presentationMode.wrappedValue.dismiss()
//                        }
//                        #endif
//                    } label: {
//                        Label("Mark All As Read in \(rss.title)", image: "Symbol")
////                        AppAssets.markAllAsReadImage
//                    }
////                    .disabled(sceneModel.markAllAsReadButtonState == nil)
//                    .help("Mark All As Read")
//                }
//                
//                ToolbarItem(placement: .bottomBar) {
//                    Spacer()
//                }
//                #endif
//            }
//    }
//    
//}
//
//
//class RefreshProgressModel: ObservableObject {
//    
//    enum State {
//        case refreshProgress(Float)
//        case lastRefreshDateText(String)
//        case none
//    }
//        
//    @Published var state = State.none
//    
//    private static var dateFormatter: RelativeDateTimeFormatter = {
//        let formatter = RelativeDateTimeFormatter()
//        formatter.dateTimeStyle = .named
//        
//        return formatter
//    }()
//        
//    private static let lastRefreshDateTextUpdateInterval = 60
//    private static let lastRefreshDateTextRelativeDateFormattingThreshold = 60.0
//    
//    func startup() {
////        updateState()
//        observeRefreshProgress()
//        scheduleLastRefreshDateTextUpdate()
//    }
//    
//    // MARK: Observing account changes
//    
//    private func observeRefreshProgress() {
//        NotificationCenter.default.addObserver(self, selector: #selector(accountRefreshProgressDidChange), name: .AccountRefreshProgressDidChange, object: nil)
//    }
//    
//    // MARK: Refreshing state
//    
//    @objc private func accountRefreshProgressDidChange() {
//        CoalescingQueue.standard//(self, #selector(updateState))
//    }
//
////    @objc private func updateState() {
////        let progress = Persistence.shared.combinedRefreshProgress
////
////        if !progress.isComplete {
////            let fractionCompleted = Float(progress.numberCompleted) / Float(progress.numberOfTasks)
////            self.state = .refreshProgress(fractionCompleted)
////        } else if let lastRefreshDate = AccountManager.shared.lastArticleFetchEndTime {
////            let text = localizedLastRefreshText(lastRefreshDate: lastRefreshDate)
////            self.state = .lastRefreshDateText(text)
////        } else {
////            self.state = .none
////        }
////    }
//    
//    private func scheduleLastRefreshDateTextUpdate() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Self.lastRefreshDateTextUpdateInterval)) {
////            self.updateState()
//            self.scheduleLastRefreshDateTextUpdate()
//        }
//    }
//    
//    private func localizedLastRefreshText(lastRefreshDate: Date) -> String {
//        let now = Date()
//        
//        if now > lastRefreshDate.addingTimeInterval(Self.lastRefreshDateTextRelativeDateFormattingThreshold) {
//            let localizedDate = Self.dateFormatter.localizedString(for: lastRefreshDate, relativeTo: now)
//            let formatString = NSLocalizedString("Updated %@", comment: "Updated") as NSString
//            
//            return NSString.localizedStringWithFormat(formatString, localizedDate) as String
//        } else {
//            return NSLocalizedString("Updated Just Now", comment: "Updated Just Now")
//        }
//    }
//        
//}
//
//struct QueueCall: Equatable {
//
//    weak var target: AnyObject?
//    let selector: Selector
//
//    func perform() {
//
//        let _ = target?.perform(selector)
//    }
//
//    static func ==(lhs: QueueCall, rhs: QueueCall) -> Bool {
//
//        return lhs.target === rhs.target && lhs.selector == rhs.selector
//    }
//}
//
//@objc public final class CoalescingQueue: NSObject {
//
//    public static let standard = CoalescingQueue(name: "Standard", interval: 0.05, maxInterval: 0.1)
//    public let name: String
//    public var isPaused = false
//    private let interval: TimeInterval
//    private let maxInterval: TimeInterval
//    private var lastCallTime = Date.distantFuture
//    private var timer: Timer? = nil
//    private var calls = [QueueCall]()
//
//    public init(name: String, interval: TimeInterval = 0.05, maxInterval: TimeInterval = 2.0) {
//        self.name = name
//        self.interval = interval
//        self.maxInterval = maxInterval
//    }
//
//    public func add(_ target: AnyObject, _ selector: Selector) {
//        let queueCall = QueueCall(target: target, selector: selector)
//        add(queueCall)
//        if Date().timeIntervalSince1970 - lastCallTime.timeIntervalSince1970 > maxInterval {
//            timerDidFire(nil)
//        }
//    }
//
//    public func performCallsImmediately() {
//        guard !isPaused else { return }
//        let callsToMake = calls // Make a copy in case calls are added to the queue while performing calls.
//        resetCalls()
//        callsToMake.forEach { $0.perform() }
//    }
//    
//    @objc func timerDidFire(_ sender: Any?) {
//        lastCallTime = Date()
//        performCallsImmediately()
//    }
//    
//}
//
//private extension CoalescingQueue {
//
//    func add(_ call: QueueCall) {
//        restartTimer()
//
//        if !calls.contains(call) {
//            calls.append(call)
//        }
//    }
//
//    func resetCalls() {
//        calls = [QueueCall]()
//    }
//
//    func restartTimer() {
//        invalidateTimer()
//        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timerDidFire(_:)), userInfo: nil, repeats: false)
//    }
//
//    func invalidateTimer() {
//        if let timer = timer, timer.isValid {
//            timer.invalidate()
//        }
//        timer = nil
//    }
//}
//
//public extension Notification.Name {
//    static let UserDidAddAccount = Notification.Name("UserDidAddAccount")
//    static let UserDidDeleteAccount = Notification.Name("UserDidDeleteAccount")
//    static let AccountRefreshDidBegin = Notification.Name(rawValue: "AccountRefreshDidBegin")
//    static let AccountRefreshDidFinish = Notification.Name(rawValue: "AccountRefreshDidFinish")
//    static let AccountRefreshProgressDidChange = Notification.Name(rawValue: "AccountRefreshProgressDidChange")
//    static let AccountDidDownloadArticles = Notification.Name(rawValue: "AccountDidDownloadArticles")
//    static let AccountStateDidChange = Notification.Name(rawValue: "AccountStateDidChange")
//    static let StatusesDidChange = Notification.Name(rawValue: "StatusesDidChange")
//}
//
//public extension Notification.Name {
//    static let UnreadCountDidInitialize = Notification.Name("UnreadCountDidInitialize")
//    static let UnreadCountDidChange = Notification.Name(rawValue: "UnreadCountDidChange")
//}
//
//public protocol UnreadCountProvider {
//
//    var unreadCount: Int { get }
//
//    func postUnreadCountDidChangeNotification()
//    func calculateUnreadCount<T: Collection>(_ children: T) -> Int
//}
//
//
//public extension UnreadCountProvider {
//    
//    func postUnreadCountDidInitializeNotification() {
//        NotificationCenter.default.post(name: .UnreadCountDidInitialize, object: self, userInfo: nil)
//    }
//
//    func postUnreadCountDidChangeNotification() {
//        NotificationCenter.default.post(name: .UnreadCountDidChange, object: self, userInfo: nil)
//    }
//
//    func calculateUnreadCount<T: Collection>(_ children: T) -> Int {
//        let updatedUnreadCount = children.reduce(0) { (result, oneChild) -> Int in
//            if let oneUnreadCountProvider = oneChild as? UnreadCountProvider {
//                return result + oneUnreadCountProvider.unreadCount
//            }
//            return result
//        }
//
//        return updatedUnreadCount
//    }
//}
//
//
