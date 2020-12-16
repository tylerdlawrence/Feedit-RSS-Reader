//
//  SafariView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//
//
import SwiftUI
import SafariServices
import WebKit

struct SafariView: UIViewControllerRepresentable {
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func makeUIViewController(context: Context) -> WebviewController {
        return WebviewController()
    }
    
    func updateUIViewController(_ webviewController: WebviewController, context: Context) {
        var request = URLRequest(url: self.url, cachePolicy: .returnCacheDataElseLoad)
        request.httpShouldHandleCookies = false
        webviewController.webview.load(request)
    }
}

class WebviewController: UIViewController {
    lazy var webview: WKWebView = WKWebView()
    lazy var progressbar: UIProgressView = UIProgressView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webview.frame = self.view.frame
        self.view.addSubview(self.webview)

        self.view.addSubview(self.progressbar)
        self.progressbar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
            self.progressbar.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.progressbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.progressbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])

        self.progressbar.progress = 0.1
        webview.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "estimatedProgress":
            if self.webview.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, animations: { () in
                    self.progressbar.alpha = 0.0
                }, completion: { finished in
                    self.progressbar.setProgress(0.0, animated: false)
                })
            } else {
                self.progressbar.isHidden = false
                self.progressbar.alpha = 1.0
                progressbar.setProgress(Float(self.webview.estimatedProgress), animated: true)
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

#if DEBUG

struct SafariView_Previews: PreviewProvider {
    static var previews: some View {
        SafariView(url: URL(string: "https://www.github.com")!)
    }
}

#endif
