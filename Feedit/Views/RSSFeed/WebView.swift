//
//  WebView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import Combine
import CoreData

struct WebView: View {
    enum FeatureItem {
        case close
        case goBack
        case goForward
        case archive(Bool)
        case read(Bool)
//        case starred(Bool)
        
        var icon: String {
            switch self {
            case .close: return "xmark"
            case .goBack: return "chevron.backward"
            case .goForward: return "chevron.forward"
            case .archive(let isArchived):
//                return "tray.and.arrow.\(isArchived ? "up" : "down")"
                return "star\(isArchived ? ".fill" : "")"
            case .read(let isRead):
                return "circle\(isRead ? ".fill" : "")"
//            case .starred(let isStarred):
//                return "star.\(isStarred ? "" : "fill")"
            }
        }
    }
    @ObservedObject var viewModel: WKWebViewModel
    @ObservedObject var rssItem: RSSItem
    var webViewWrapper: WKWebViewWrapper
    
    var onCloseClosure: (() -> Void)?
    var onArchiveClosure: (() -> Void)?
    var onReadAction: (() -> Void)?
    var onDoneAction: (() -> Void)?
    
    init(rssItem: RSSItem, onCloseClosure: @escaping (() -> Void), onArchiveClosure: (() -> Void)? = nil, onReadAction: (() -> Void)? = nil) {
        let viewModel = WKWebViewModel(rssItem: rssItem)
        self.rssItem = rssItem
        self.viewModel = viewModel
        self.onCloseClosure = onCloseClosure
        self.onArchiveClosure = onArchiveClosure
        self.onReadAction = onReadAction
        self.webViewWrapper = WKWebViewWrapper(viewModel: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            webViewWrapper
            HStack(alignment: .top, spacing: 30) {
                if !self.viewModel.canGoBack {
                    makeFeatureItemView(
                        imageName: FeatureItem.close.icon,
                        disable: true,
                        action: self.onGoBackAction
                    )
                } else {
                    makeFeatureItemView(
                        imageName: FeatureItem.goBack.icon,
                        disable: true,
                        action: self.onGoBackAction
                    )
                }
                makeFeatureItemView(
                    imageName: FeatureItem.goForward.icon,
                    disable: !self.viewModel.canGoForward,
                    action: self.onGoForwardAction
                )
                makeFeatureItemView(imageName: FeatureItem.archive(self.rssItem.isArchive).icon, action: self.onArchiveClosure)
                
                makeFeatureItemView(imageName: FeatureItem.read(self.rssItem.isRead).icon, action: self.onReadAction)
                
//                if !self.viewModel.progressHide {
                    VStack(alignment: .center) {
                        ProgressBar(
                            boardWidth: 7,
                            font: Font.system(size: 10),
                            color: Color("tab"), progress:
                            self.$viewModel.progress
                        )
                        .padding(10)
                    }
                    .frame(width: 40, height: 50, alignment: .center)
//                }
//                Spacer()
            }
        }
    }
}

extension WebView {
    func onGoBackAction() {
        webViewWrapper.webView.goBack()
    }
    
    func onGoForwardAction() {
        webViewWrapper.webView.goForward()
    }
    
    func onCloseAction() {
//        webViewWrapper.webView.
        self.onCloseClosure?()
    }
}

extension WebView {
    
    func makeFeatureItemView(imageName: String, disable: Bool = false, action: (() -> Void)?) -> some View {
        Image(systemName: imageName)
            .foregroundColor(disable ? Color.gray : Color("tab"))
            .frame(width: 50, height: 50, alignment: .center)
            .onTapGesture {
                action?()
            }
//            .disabled(disable)
    }
}

struct WebActions_Previews: PreviewProvider {

    static var previews: some View {
        let simple = DataSourceService.current.rssItem.simple()
        return WebView(rssItem: simple!, onCloseClosure: {

        }, onArchiveClosure: {

        })
        .preferredColorScheme(.dark)
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        SafariView(url:URL(string: "https://google.com")!)
            .previewDevice(.init(stringLiteral: "iPhone X"))
    }
}
