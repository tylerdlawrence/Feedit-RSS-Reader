//
//  ImageServices.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import UIKit
import CoreData
import Combine
import SwiftUI
import Foundation

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




//class UrlImageModel: ObservableObject {
//    @Published var image: UIImage?
//    var urlString: String?
//    var imageCache = ImageCache.getImageCache()
//
//    init(urlString: String?) {
//        self.urlString = urlString
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
//        guard let urlString = urlString else {
//            return false
//        }
//
//        guard let cacheImage = imageCache.get(forKey: urlString) else {
//            return false
//        }
//
//        image = cacheImage
//        return true
//    }
//
//    func loadImageFromUrl() {
//        guard let urlString = urlString else {
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
//            self.imageCache.set(forKey: self.urlString!, image: loadedImage)
//            self.image = loadedImage
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
