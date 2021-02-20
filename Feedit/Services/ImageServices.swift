//
//  ImageServices.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import UIKit
import CoreData
import Combine

public class ImageService {
    public static let shared = ImageService()

    public enum ImageError: Error {
        case decodingError
    }
    
    public func fetchImage(url: URL) -> AnyPublisher<UIImage?, Never> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> UIImage? in
                return UIImage(data: data)
        }.catch { error in
            return Just(nil)
        }
        .eraseToAnyPublisher()
    }
}

public class ImageLoaderCache {
    public static let shared = ImageLoaderCache()
    
    private var loaders: NSCache<NSString, ImageLoader> = NSCache()
            
    public func loaderFor(path: String?) -> ImageLoader {
        let key = NSString(string: "\(path ?? "missing")")
        if let loader = loaders.object(forKey: key) {
            return loader
        } else {
            let loader = ImageLoader(path: path)
            loaders.setObject(loader, forKey: key)
            return loader
        }
    }
}

public final class ImageLoader: ObservableObject {
    public let path: String?
    
    public var objectWillChange: AnyPublisher<UIImage?, Never> = Publishers.Sequence<[UIImage?], Never>(sequence: []).eraseToAnyPublisher()
    
    @Published public var image: UIImage? = nil
    
    public var cancellable: AnyCancellable?
        
    public init(path: String?) {
        self.path = path
        
        self.objectWillChange = $image.handleEvents(receiveSubscription: { [weak self] sub in
            self?.loadImage()
        }, receiveCancel: { [weak self] in
            self?.cancellable?.cancel()
        }).eraseToAnyPublisher()
    }
    
    private func loadImage() {
        guard let poster = path, let url = URL(string: poster), image == nil else {
            return
        }
        cancellable = ImageService.shared.fetchImage(url: url)
            .receive(on: DispatchQueue.main)
            .assign(to: \ImageLoader.image, on: self)
    }
    
    deinit {
        cancellable?.cancel()
    }
}
//import SwiftUI
//import FeedKit
//import Combine
//import Foundation
//import UIKit
//import CoreData
//
//public class RSSFeedImage {
//
//    /// The URL of a GIF, JPEG or PNG image that represents the channel.
//    public var url: String?
//
//    /// Describes the image, it's used in the ALT attribute of the HTML `<img>`
//    /// tag when the channel is rendered in HTML.
//    public var title: String?
//
//    /// The URL of the site, when the channel is rendered, the image is a link
//    /// to the site. (Note, in practice the image `<title>` and `<link>` should
//    /// have the same value as the channel's `<title>` and `<link>`.
//    public var link: String?
//
//    /// Optional element `<width>` indicating the width of the image in pixels.
//    /// Maximum value for width is 144, default value is 88.
//    public var width: Int?
//
//    /// Optional element `<height>` indicating the height of the image in pixels.
//    /// Maximum value for height is 400, default value is 31.
//    public var height: Int?
//
//    /// Contains text that is included in the TITLE attribute of the link formed
//    /// around the image in the HTML rendering.
//    public var description: String?
//
//    public init() { }
//
//}
//
//// MARK: - Equatable
//
//extension RSSFeedImage: Equatable {
//
//    public static func ==(lhs: RSSFeedImage, rhs: RSSFeedImage) -> Bool {
//        return
//            lhs.url == rhs.url &&
//            lhs.title == rhs.title &&
//            lhs.link == rhs.link &&
//            lhs.width == rhs.width &&
//            lhs.height == rhs.height &&
//            lhs.description == rhs.description
//    }
//
//}
//
//
//public class ImageService {
//
//    public static let shared = ImageService()
//
//    public enum ImageError: Error {
//        case decodingError
//    }
//
//    public func fetchImage(url: URL) -> AnyPublisher<UIImage?, Never> {
//        return URLSession.shared.dataTaskPublisher(for: url)
//            .tryMap { (data, response) -> UIImage? in
//                return UIImage(data: data)
//        }.catch { error in
//            return Just(nil)
//        }
//        .eraseToAnyPublisher()
//    }
//}
//
//public class ImageLoaderCache {
//    public static let shared = ImageLoaderCache()
//
//    private var loaders: NSCache<NSString, ImageLoader> = NSCache()
//
//    func loaderFor(path: String?) -> ImageLoader {
//        let key = NSString(string: "\(path ?? "missing")")
//        if let loader = loaders.object(forKey: key) {
//            return loader
//        } else {
//            let loader = ImageLoader(urlString: path!)
//            loaders.setObject(loader, forKey: key)
//            return loader
//        }
//    }
//}
//class ImageLoader: ObservableObject {
//    var dataPublisher = PassthroughSubject<Data, Never>()
//    var data = Data() {
//        didSet {
//            dataPublisher.send(data)
//        }
//     }
//init(urlString:String) {
//        guard let url = URL(string: urlString) else { return }
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//        guard let data = data else { return }
//        DispatchQueue.main.async {
//           self.data = data
//        }
//    }
//    task.resume()
//  }
//}
//struct ImageView: View {
//    @ObservedObject var imageLoader:ImageLoader
//    @State var image:UIImage = UIImage()
//    var rssSource: RSS {
//        return self.rssFeedViewModel.rss
//    }
//    @ObservedObject var rssFeedViewModel: RSSFeedViewModel
//
//init(withURL url:String,rssViewModel: RSSFeedViewModel) {
//    imageLoader = ImageLoader(urlString:url)
//    self.rssFeedViewModel = rssViewModel
//    }
//var body: some View {
//    VStack {
//        Image(uiImage: image)
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width:100, height:100)
//    }.onReceive(imageLoader.dataPublisher) { data in
//        self.image = UIImage(data: data) ?? UIImage()
//    }
//  }
//}
//struct ImageView_Previews: PreviewProvider {
//    static let rssFeedViewModel = RSSFeedViewModel(rss: RSS(context: Persistence.current.context), dataSource: DataSourceService.current.rssItem)
//    static var previews: some View {
//        ImageView(withURL: "https://macstories.net/feed", rssViewModel: self.rssFeedViewModel)
//    }
//}
////public final class ImageLoader: ObservableObject {
////
////    var didChange = PassthroughSubject<Data, Never>()
////    var data = Data() {
////        didSet {
////            didChange.send(data)
////        }
////    }
////
////    public let path: String?
////
////    public var objectWillChange: AnyPublisher<UIImage?, Never> = Publishers.Sequence<[UIImage?], Never>(sequence: []).eraseToAnyPublisher()
////
////    @Published public var imageURL: UIImage? = nil
////
////    public var cancellable: AnyCancellable?
////
////    public init(path:String) {
////        self.path = path
////
////        self.objectWillChange = $imageURL.handleEvents(receiveSubscription: { [weak self] sub in
////            self?.loadImage()
////        }, receiveCancel: { [weak self] in
////            self?.cancellable?.cancel()
////        }).eraseToAnyPublisher()
////
////        guard let url = URL(string: path) else { return }
////        let task = URLSession.shared.dataTask(with: url) { data, response, error in
////            guard let data = data else { return }
////            DispatchQueue.main.async {
////                self.data = data
////            }
////        }
////        task.resume()
////    }
////
////    private func loadImage() {
////        guard let poster = path, let url = URL(string: poster), imageURL == nil else {
////            return
////        }
////        cancellable = ImageService.shared.fetchImage(url: url)
////            .receive(on: DispatchQueue.main)
////            .assign(to: \ImageLoader.imageURL, on: self)
////    }
////
////    deinit {
////        cancellable?.cancel()
////    }
////}
//
//
//
//
//class UrlImageModel: ObservableObject {
//    @Published var imageURL: UIImage?
//    var path: String?
//    var imageCache = ImageCache.getImageCache()
//
//    init(urlString: String?) {
//        self.path = urlString
//        loadImage()
//    }
//
//    func loadImage() {
//        if loadImageFromCache() {
//            print("Cache hit")
//            return
//        }
//
//        print("Cache miss, loading from url")
//        loadImageFromUrl()
//    }
//
//    func loadImageFromCache() -> Bool {
//        guard let urlString = path else {
//            return false
//        }
//
//        guard let cacheImage = imageCache.get(forKey: urlString) else {
//            return false
//        }
//
//        imageURL = cacheImage
//        return true
//    }
//
//    func loadImageFromUrl() {
//        guard let urlString = path else {
//            return
//        }
//
//        let url = URL(string: urlString)!
//        let task = URLSession.shared.dataTask(with: url, completionHandler: getImageFromResponse(data:response:error:))
//        task.resume()
//    }
//
//
//    func getImageFromResponse(data: Data?, response: URLResponse?, error: Error?) {
//        guard error == nil else {
//            print("Error: \(error!)")
//            return
//        }
//        guard let data = data else {
//            print("No data found")
//            return
//        }
//
//        DispatchQueue.main.async {
//            guard let loadedImage = UIImage(data: data) else {
//                return
//            }
//
//            self.imageCache.set(forKey: self.path!, image: loadedImage)
//            self.imageURL = loadedImage
//        }
//    }
//}
//
//class ImageCache {
//    var cache = NSCache<NSString, UIImage>()
//
//    func get(forKey: String) -> UIImage? {
//        return cache.object(forKey: NSString(string: forKey))
//    }
//
//    func set(forKey: String, image: UIImage) {
//        cache.setObject(image, forKey: NSString(string: forKey))
//    }
//}
//
//extension ImageCache {
//    private static var imageCache = ImageCache()
//    static func getImageCache() -> ImageCache {
//        return imageCache
//    }
//}
