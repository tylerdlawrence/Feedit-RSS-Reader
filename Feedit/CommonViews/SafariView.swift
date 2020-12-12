//
//  SafariView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

//import SwiftUI
//import SafariServices
//
//struct SafariView: UIViewControllerRepresentable {
//
//    let url: URL
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
//        let config = SFSafariViewController.Configuration()
//        config.entersReaderIfAvailable = true
//        return SFSafariViewController(url: url, configuration: config)
//    }
//
//    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
//
//    }
//}
import SwiftUI
import SafariServices


private final class Safari: UIViewControllerRepresentable {
    
    var urlToLoad: URL
    
    init(url: URL) {
        self.urlToLoad = url
    }
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let viewController = SFSafariViewController(url: urlToLoad)
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var parent: Safari
            
        init(_ parent: Safari) {
            self.parent = parent
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            
        }
        
    }
    
}

struct SafariView: View {
    
    var url: URL
    
    var body: some View {
        Safari(url: url)
    }
}

#if DEBUG

struct SafariView_Previews: PreviewProvider {
    static var previews: some View {
        SafariView(url: URL(string: "https://www.github.com")!)
    }
}

#endif
