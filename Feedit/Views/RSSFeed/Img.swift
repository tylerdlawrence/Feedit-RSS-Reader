//
//  Img.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 12/14/20.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct Img: View {
        
    @ObservedObject var imageManager: ImageManager
    
    @State var isAnimating: Bool = true
    
    var body: some View {

        Group {
            if imageManager.image != nil {
                Image(uiImage: imageManager.image!)
            } else {
                Rectangle().fill(Color.gray)
            }
        }
        // Trigger image loading when appear
        .onAppear { self.imageManager.load() }
        // Cancel image loading when disappear
        .onDisappear { self.imageManager.cancel() }

        }
    }

struct Img_Previews: PreviewProvider {
    static var previews: some View {
//        Img(imageManager: ImageManager(url: URL(string: "https://via.placeholder.com/200x200.jpg")))
        Group {
            WebImage(url: URL(string: "https://raw.githubusercontent.com/SDWebImage/SDWebImage/master/SDWebImage_logo.png"))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
        }
    }
}
