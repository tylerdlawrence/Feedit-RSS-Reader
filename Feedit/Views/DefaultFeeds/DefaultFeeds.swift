//
//  DefaultFeeds.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 12/5/20.
//

import Foundation
import SwiftUI
import Combine
import FeedKit
import UIKit
import KingfisherSwiftUI
import Foundation
import RSCore

struct DefaultFeeds: Codable, Identifiable {
    let id: String
    let desc: String
    let htmlUrl: String
    let xmlUrl: String
    
    var displayName: String {
        "\(id)"
    }
    
    var description: String {
        "\(desc)"
    }
    
    var xml: String {
        "\(xmlUrl)"
    }
}

struct DefaultFeedsListView: View {
    

//    @ObservedObject var imageLoader: ImageLoader
//    @ObservedObject var rss: RSS
    
    var contextMenuAction: ((RSS) -> Void)?
    @State private var selectedItem: DefaultFeeds?

//    init(rss: RSS, menu action: ((RSS) -> Void)? = nil) {
//        self.rss = rss
//        contextMenuAction = action
//        self.imageLoader = ImageLoader(path: rss.imageURL)
//        //WORKING^
//    }
    @State var sources: [DefaultFeeds] = []

    let defaultFeeds: [DefaultFeeds] = Bundle.main.decode("DefaultFeeds.json")
    
//    private func iconImageView(_ image: UIImage) -> some View {
//        Image(uiImage: image)
//        .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: 25, height: 25,alignment: .center)
//            .cornerRadius(5)
//            .animation(.easeInOut)
//            .border(Color.clear, width: 1)
//        
//    }
    
    var body: some View {
        Form {
            ForEach(0 ..< 17) { defaultFeeds in
                Text("Row \(0)")
//        List(defaultFeeds) { defaultFeeds in
//            Section(header: Text("\(defaultFeeds.displayName)")) {                NavigationLink(destination: Text(defaultFeeds.xmlUrl)) {
                    
//                }
//            }
//            .navigationTitle("Default Feeds")
            
            }
        }
    }
}

//struct DefaultFeedsListView_Previews: PreviewProvider {
//
//    static let defaultFeeds: [DefaultFeeds] = Bundle.main.decode("DefaultFeeds.json")
//
//    @State var sources: [DefaultFeeds] = []
//
//    static var previews: some View {
//        DefaultFeedsListView(sources: defaultFeeds)
//    }
//}
