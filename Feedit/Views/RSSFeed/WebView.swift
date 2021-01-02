//
//  WebView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import NavigationStack
import KingfisherSwiftUI
import Combine
import CoreData

struct WebView: View {
    
    let url: URL

    @State var showSheetView = false
    
    @Environment(\.managedObjectContext) var managedObjectContext

    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var rssDataSource: RSSDataSource
    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
    
    var rssSource: RSS {
        return self.rssFeedViewModel.rss
    }
    
    enum FeatureItem {
        case goBack
        case goForward
        case archive(Bool)
        
        var icon: String {
            switch self {
            case .goBack: return "chevron.backward"
            case .goForward: return "chevron.forward"
            case .archive(let isArchived):
                return "star\(isArchived ? ".fill" : "")"
            }
        }
    }
    
    @ObservedObject var itemWrapper: RSSItem
    @ObservedObject var imageLoader: ImageLoader
    @ObservedObject var rss: RSS
    @ObservedObject var viewModel: WKWebViewModel
    @ObservedObject var rssItem: RSSItem
    var webViewWrapper: WKWebViewWrapper
    
    var onArchiveAction: (() -> Void)?
    var onDoneAction: (() -> Void)?

    init(rssViewModel: RSSFeedViewModel, wrapper: RSSItem, rss: RSS, rssItem: RSSItem, onArchiveAction: (() -> Void)? = nil, url:URL) {
        self.url = url

        self.rssFeedViewModel = rssViewModel
        let viewModel = WKWebViewModel(rssItem: rssItem)
        itemWrapper = wrapper
        self.rss = rss
        self.imageLoader = ImageLoader(path: rss.imageURL)
        self.rssItem = rssItem
        self.viewModel = viewModel
        self.onArchiveAction = onArchiveAction
        self.webViewWrapper = WKWebViewWrapper(viewModel: viewModel)
        self.showSheetView = showSheetView


    }
    
//    private var bottomView: some View {
//        HStack(alignment: .bottom) {
//            makeFeatureItemView(
//                imageName: FeatureItem.goBack.icon,
//                disable: !self.viewModel.canGoBack,
//                action: self.onGoBackAction)
//            makeFeatureItemView(
//                imageName: FeatureItem.goForward.icon,
//                disable: !self.viewModel.canGoForward,
//                action: self.onGoForwardAction
//                )
//            makeFeatureItemView(
//                imageName: FeatureItem.archive(self.rssItem.isArchive).icon,
//                action: self.onArchiveAction
//            )
//            if !self.viewModel.progressHide {
//                VStack(alignment: .center) {
//                    ProgressBar(
//                        boardWidth: 6,
//                        font: Font.system(size: 12),
//                        color: .blue, progress:
//                        self.$viewModel.progress
//                    )
//                    .padding(10)
//                }
//                .frame(width: 50, height: 50, alignment: .center)
//            }
//            Link(destination: URL(string: itemWrapper.url)!) {
//                Image(systemName: "safari")
//                    .foregroundColor(.blue)
//                    .frame(width: 50.0, height: 50.0)
//                    .imageScale(.medium)
//
//            }
//        }
//    }
    
    private var doneButton: some View {
        Button(action: {
            self.onDoneAction?()
            self.presentationMode.wrappedValue.dismiss()
                
        }) {
            //Image(systemName: "chevron.left") //systemName: "chevron.left")
            Text("")
        }
    }

    private func iconImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
        .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25,alignment: .center)
            .cornerRadius(5)
            .animation(.easeInOut)
            .border(Color.clear, width: 1)
        
    }
    

    
    private var imageView: some View {
        KFImage(URL(string: self.rssSource.imageURL))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 75, height: 75)
            .cornerRadius(5.0)
    }
    
    private var pureTextView: some View {
        VStack(spacing: 0.0) {
            Text(rss.desc)
                .font(.custom("Gotham", size: 16))
                .multilineTextAlignment(.leading)
                .lineLimit(1)
        }
    }
    

    


    
    var body: some View {

        VStack(alignment: .leading) {
            webViewWrapper
//            SafariView(url: url)

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
                
                makeFeatureItemView(imageName: FeatureItem.archive(self.rssItem.isArchive).icon, action: self.onArchiveAction)

                Link(destination: URL(string: itemWrapper.url)!) {
                    Image(systemName: "safari")
                        .imageScale(.large)
                }
                .frame(width: 50, height: 50, alignment: .center)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(leading: doneButton)
//                    .toolbar {
//                        ToolbarItem(placement: .bottomBar) {
//                            makeFeatureItemView(
//                                imageName: FeatureItem.goBack.icon,
//                                disable: !self.viewModel.canGoBack,
//                                action: self.onGoBackAction)
//                        }
//                        ToolbarItem(placement: .bottomBar) {
//                            makeFeatureItemView(
//                                imageName: FeatureItem.goForward.icon,
//                                disable: !self.viewModel.canGoForward,
//                                action: self.onGoForwardAction)
//                        }
////                        ToolbarItem(placement: .bottomBar) {
////                            Spacer()
////                        }
//                        ToolbarItem(placement: .bottomBar) {
//                            makeFeatureItemView(imageName: FeatureItem.archive(self.rssItem.isArchive).icon, action: self.onArchiveAction)
//                        }
//                        ToolbarItem(placement: .bottomBar) {
//                            if !self.viewModel.progressHide {
//                                VStack(alignment: .center) {
//                                    ProgressBar(
//                                        boardWidth: 6,
//                                        font: Font.system(size: 12),
//                                        color: .blue, progress:
//                                        self.$viewModel.progress
//                                    )
//                                    .padding(10)
//                                }
//                                .frame(width: 50, height: 50, alignment: .center)
//                            }
//                        }
//                        ToolbarItem(placement: .bottomBar) {
//                            Link(destination: URL(string: itemWrapper.url)!) {
//                                Image(systemName: "safari").font(.system(size: 14, weight: .bold)).foregroundColor(.blue)
//                            }
//                        }
//                    }


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
            .foregroundColor(disable ? Color.secondary : Color.primary)
            .frame(width: 50, height: 50, alignment: .center)
            .onTapGesture {
                action?()
            }
            .disabled(disable)
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        SafariView(url:URL(string: "https://google.com")!)
            .previewDevice(.init(stringLiteral: "iPhone X"))
    }
}
