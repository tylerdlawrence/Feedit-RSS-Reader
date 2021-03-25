//
//  ImageServices.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import UIKit
import Combine
import Foundation

//protocol ImageCache {
//    subscript(_ url: URL) -> UIImage? { get set }
//}

//struct TemporaryImageCache: ImageCache {
//    private let cache: NSCache<NSURL, UIImage> = {
//        let cache = NSCache<NSURL, UIImage>()
//        cache.countLimit = 100 // 100 items
//        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
//        return cache
//    }()
//
//    subscript(_ key: URL) -> UIImage? {
//        get { cache.object(forKey: key as NSURL) }
//        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
//    }
//}

//struct ImageCacheKey: EnvironmentKey {
//    static let defaultValue: ImageCache = TemporaryImageCache()
//}

//extension EnvironmentValues {
//    var imageCache: ImageCache {
//        get { self[ImageCacheKey.self] }
//        set { self[ImageCacheKey.self] = newValue }
//    }
//}

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

//public class ImageLoaderCache {
//    public static let shared = ImageLoaderCache()
//
//    private var loaders: NSCache<NSString, ImageLoader> = NSCache()
//
//    public func loaderFor(path: String?) -> ImageLoader {
//        let key = NSString(string: "\(path ?? "missing")")
//        if let loader = loaders.object(forKey: key) {
//            return loader
//        } else {
//            let loader = ImageLoader(path: path)
//            loaders.setObject(loader, forKey: key)
//            return loader
//        }
//    }
//}
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

class UrlImageModel: ObservableObject {
    @Published var image: UIImage?
    var urlString: String?
    var imageCache = ImageCache.getImageCache()
    
    init(urlString: String?) {
        self.urlString = urlString
        loadImage()
    }
    
    func loadImage() {
        if loadImageFromCache() {
            print("Cache hit")
            return
        }
        
        print("Cache miss, loading from url")
        loadImageFromUrl()
    }
    
    func loadImageFromCache() -> Bool {
        guard let urlString = urlString else {
            return false
        }
        
        guard let cacheImage = imageCache.get(forKey: urlString) else {
            return false
        }
        
        image = cacheImage
        return true
    }
    
    func loadImageFromUrl() {
        guard let urlString = urlString else {
            return
        }
        
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url, completionHandler: getImageFromResponse(data:response:error:))
        task.resume()
    }
    
    
    func getImageFromResponse(data: Data?, response: URLResponse?, error: Error?) {
        guard error == nil else {
            print("Error: \(error!)")
            return
        }
        guard let data = data else {
            print("No data found")
            return
        }
        
        DispatchQueue.main.async {
            guard let loadedImage = UIImage(data: data) else {
                return
            }
            
            self.imageCache.set(forKey: self.urlString!, image: loadedImage)
            self.image = loadedImage
        }
    }
}

class ImageCache {
    var cache = NSCache<NSString, UIImage>()
    
    func get(forKey: String) -> UIImage? {
        return cache.object(forKey: NSString(string: forKey))
    }
    
    func set(forKey: String, image: UIImage) {
        cache.setObject(image, forKey: NSString(string: forKey))
    }
}

extension ImageCache {
    private static var imageCache = ImageCache()
    static func getImageCache() -> ImageCache {
        return imageCache
    }
}

struct UrlImageView: View {
    @ObservedObject var urlImageModel: UrlImageModel
    
    init(urlString: String?) {
        urlImageModel = UrlImageModel(urlString: urlString)
    }
    
    var body: some View {
        Image(uiImage: urlImageModel.image ?? UrlImageView.defaultImage!)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
    }
    
    static var defaultImage = UIImage(named: "launch")
}
