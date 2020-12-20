//
//  Img.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 12/14/20.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI
import URLImage

struct Img: View {
        
//    @ObservedObject var imageManager: ImageManager
//
//    @State var isAnimating: Bool = true
//
//    var body: some View {
//
//        Group {
//            if imageManager.image != nil {
//                Image(uiImage: imageManager.image!)
//            } else {
//                Rectangle().fill(Color.gray)
//            }
//        }
//        // Trigger image loading when appear
//        .onAppear { self.imageManager.load() }
//        // Cancel image loading when disappear
//        .onDisappear { self.imageManager.cancel() }
//
//        }
//    }
//
//struct Img_Previews: PreviewProvider {
//    static var previews: some View {
////        Img(imageManager: ImageManager(url: URL(string: "https://via.placeholder.com/200x200.jpg")))
//        Group {
//            WebImage(url: URL(string: "https://raw.githubusercontent.com/SDWebImage/SDWebImage/master/SDWebImage_logo.png"))
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .padding()
//        }
//    }
//}
        let url: URL
        let id: UUID

        init(url: URL, id: UUID) {
            self.url = url
            self.id = id

            formatter = NumberFormatter()
            formatter.numberStyle = .percent
        }
        
        private let formatter: NumberFormatter // Used to format download progress as percentage. Note: this is only for example, better use shared formatter to avoid creating it for every view.
        
        var body: some View {
            URLImage(url: url,
                     options: URLImageOptions(
                        identifier: id.uuidString,      // Custom identifier
                        expireAfter: 300.0,             // Expire after 5 minutes
                        cachePolicy: .returnCacheElseLoad(cacheDelay: nil, downloadDelay: 0.25) // Return cached image or download after delay
                     ),
                     empty: {
                        Text("Nothing here")            // This view is displayed before download starts
                     },
                     inProgress: { progress -> Text in  // Display progress
                        if let progress = progress {
                            return Text(formatter.string(from: progress as NSNumber) ?? "Loading...")
                        }
                        else {
                            return Text("Loading...")
                        }
                     },
                     failure: { error, retry in         // Display error and retry button
                        VStack {
                            Text(error.localizedDescription)
                            Button("Retry", action: retry)
                        }
                     },
                     content: { image in                // Content view
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                     })
        }
    }
