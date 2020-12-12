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
    
    init(wrapper: RSSItem, rss: RSS, rssItem: RSSItem, onArchiveAction: (() -> Void)? = nil) {
        let viewModel = WKWebViewModel(rssItem: rssItem)
        itemWrapper = wrapper
        self.rss = rss
        self.imageLoader = ImageLoader(path: rss.imageURL)
        self.rssItem = rssItem
        self.viewModel = viewModel
        self.onArchiveAction = onArchiveAction
        self.webViewWrapper = WKWebViewWrapper(viewModel: viewModel)
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
    private func iconImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
        .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25,alignment: .center)
            .cornerRadius(5)
            .animation(.easeInOut)
            .border(Color.clear, width: 1)
        
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
//        VStack(alignment: .leading) {
//            webViewWrapper
//            HStack(alignment: .top, spacing: 30) {
//                makeFeatureItemView(
//                    imageName: FeatureItem.goBack.icon,
//                    disable: !self.viewModel.canGoBack,
//                    action: self.onGoBackAction
//                )
//                makeFeatureItemView(
//                    imageName: FeatureItem.goForward.icon,
//                    disable: !self.viewModel.canGoForward,
//                    action: self.onGoForwardAction
//                )
//                makeFeatureItemView(imageName: FeatureItem.archive(self.rssItem.isArchive).icon, action: self.onArchiveAction)
//
//                if !self.viewModel.progressHide {
//                    VStack(alignment: .center) {
//                        ProgressBar(
//                            boardWidth: 6,
//                            font: Font.system(size: 12),
//                            color: .blue, progress:
//                            self.$viewModel.progress
//                        )
//                        .padding(10)
//                    }
//                    .frame(width: 50, height: 50, alignment: .center)
//                }
//
//                Spacer()
//            }
//        }
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                HStack{
                    if
                        self.imageLoader.image != nil {
                        iconImageView(self.imageLoader.image!)
                            .frame(width: 25, height: 25,alignment: .center)
                            .layoutPriority(10)
                            .offset(x: 10, y: 8)

                        pureTextView
                        
                    } else {
                        
                        Image("smartFeedUnread")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(.body)
                            .frame(width: 25, height: 25,alignment: .center)
                            .cornerRadius(5)
                            .opacity(0.8)
                            .border(Color.clear, width: 1)
                            .layoutPriority(10)
                            .animation(.easeInOut)
                            .offset(x: 10, y: 8)

                        pureTextView
                    }
//                    Image("launch")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 25, height: 25, alignment: .center)
//                        .cornerRadius(3.0)
//                        .offset(x: 10, y: 8)
                    Text("\(itemWrapper.createTime?.string() ?? "")")
                        .font(.headline)
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.leading)
                        .offset(x: 15, y: 8)
                        //.frame(width: 87, height: 20.5)
                }
                .padding(.top)
                Text(itemWrapper.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .offset(x: 10, y: 56.5)
                    .padding(.trailing, 50.0)
                    //.frame(width: 90, height: 21)
                Text(rss.imageURL)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .offset(x: 20, y: 74.5)
                    .frame(width: 136, height: 33.5)
                Text(itemWrapper.desc.trimHTMLTag.trimWhiteAndSpace)
                    .font(.headline)
                    .padding(.trailing, 50.0)
                    .offset(x: 10, y: 100)
                    .frame(width: 400, height: 550) //, height: 20.5)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        }
//        VStack {
                //webViewWrapper
            HStack(alignment: .bottom) { //(alignment: .center, spacing: 30) {
                    makeFeatureItemView(
                        imageName: FeatureItem.goBack.icon,
                        disable: !self.viewModel.canGoBack,
                        action: self.onGoBackAction
                    )
                    //.padding(.trailing)
                    makeFeatureItemView(
                        imageName: FeatureItem.goForward.icon,
                        disable: !self.viewModel.canGoForward,
                        action: self.onGoForwardAction
                    )
                    .padding(.trailing)
                    if !self.viewModel.progressHide {
                        VStack { //(alignment: .center) {
                            ProgressBar(
                                boardWidth: 6,
                                font: Font.system(size: 10),
                                color: .blue, progress:
                                self.$viewModel.progress
                            )
                            .padding(7)
                        }
                        .frame(width: 50, height: 50) //, alignment: .center)
                    }
                    makeFeatureItemView(imageName: FeatureItem.archive(self.rssItem.isArchive).icon, action: self.onArchiveAction)

                    Link(destination: URL(string: itemWrapper.url)!) {
                        Image(systemName: "safari")
                            .foregroundColor(.blue)
                            .frame(width: 50.0, height: 50.0)
                            .imageScale(.medium)

//                    }
                }
            }
//            .frame(width: 400.0, height: 90.0)
//            .background(Color("background"))
//            .ignoresSafeArea(.keyboard, edges: .bottom)

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
            .foregroundColor(disable ? Color.blue : Color.blue)
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

        return WebView(wrapper: simple!, rss: RSS.simple(), rssItem: simple!, onArchiveAction: {

        })
        .preferredColorScheme(.dark)
        
    }
}
