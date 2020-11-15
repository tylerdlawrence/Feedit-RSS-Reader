//
//  WebView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI

struct WebView: View {
    
    enum FeatureItem {
        case goBack
        case goForward
        case archive(Bool)
        
        var icon: String {
            switch self {
            case .goBack: return "chevron.backward.circle"
            case .goForward: return "chevron.forward.circle"
            case .archive(let isArchived):
                return "tag\(isArchived ? ".fill" : "")"
            }
        }
    }
    
    @ObservedObject var viewModel: WKWebViewModel
    @ObservedObject var rssItem: RSSItem
    var webViewWrapper: WKWebViewWrapper
    var onArchiveAction: (() -> Void)?
    
    init(rssItem: RSSItem, onArchiveAction: (() -> Void)? = nil) {
        let viewModel = WKWebViewModel(rssItem: rssItem)
        self.rssItem = rssItem
        self.viewModel = viewModel
        self.onArchiveAction = onArchiveAction
        self.webViewWrapper = WKWebViewWrapper(viewModel: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            webViewWrapper
            HStack(alignment: .top, spacing: 30) {
                makeFeatureItemView(
                    imageName: FeatureItem.goBack.icon,
                    disable: !self.viewModel.canGoBack,
                    action: self.onGoBackAction
                )
                makeFeatureItemView(
                    imageName: FeatureItem.goForward.icon,
                    disable: !self.viewModel.canGoForward,
                    action: self.onGoForwardAction
                )
                makeFeatureItemView(imageName: FeatureItem.archive(self.rssItem.isArchive).icon, action: self.onArchiveAction)
                
                if !self.viewModel.progressHide {
                    VStack(alignment: .center) {
                        ProgressBar(
                            boardWidth: 6,
                            font: Font.system(size: 12),
                            color: .blue, progress:
                            self.$viewModel.progress
                        )
                        .padding(10)
                    }
                    .frame(width: 50, height: 50, alignment: .center)
                }
                
                Spacer()
            }
        }
        .onAppear {
            
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
}

extension WebView {
    
    func makeFeatureItemView(imageName: String, disable: Bool = false, action: (() -> Void)?) -> some View {
        Image(systemName: imageName)
            .foregroundColor(disable ? Color.gray : Color.gray)
            .frame(width: 50, height: 50, alignment: .center)
            .onTapGesture {
                action?()
            }
            .disabled(disable)
    }
}

struct WebView_Previews: PreviewProvider {
    
    static var previews: some View {
        let simple = DataSourceService.current.rssItem.simple()
        return WebView(rssItem: simple!, onArchiveAction: {
            
        })
    }
}
