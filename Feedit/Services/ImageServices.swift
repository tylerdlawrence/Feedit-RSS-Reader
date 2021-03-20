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

//class ImageLoader: ObservableObject {
//    @Published var image: UIImage?
//
//    private(set) var isLoading = false
//
//    private let url: URL
//    private var cache: ImageCache?
//    private var cancellable: AnyCancellable?
//
//    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")
//
//    init(url: URL, cache: ImageCache? = nil) {
//        self.url = url
//        self.cache = cache
//    }
//
//    deinit {
//        cancel()
//    }
//
//    func load() {
//        guard !isLoading else { return }
//
//        if let image = cache?[url] {
//            self.image = image
//            return
//        }
//
//        cancellable = URLSession.shared.dataTaskPublisher(for: url)
//            .map { UIImage(data: $0.data) }
//            .replaceError(with: nil)
//            .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
//                          receiveOutput: { [weak self] in self?.cache($0) },
//                          receiveCompletion: { [weak self] _ in self?.onFinish() },
//                          receiveCancel: { [weak self] in self?.onFinish() })
//            .subscribe(on: Self.imageProcessingQueue)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] in self?.image = $0 }
//    }
//
//    func cancel() {
//        cancellable?.cancel()
//    }
//
//    private func onStart() {
//        isLoading = true
//    }
//
//    private func onFinish() {
//        isLoading = false
//    }
//
//    private func cache(_ image: UIImage?) {
//        image.map { cache?[url] = $0 }
//    }
//}

protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}

struct TemporaryImageCache: ImageCache {
    private let cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 100 // 100 items
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        return cache
    }()

    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}

struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCache = TemporaryImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}

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
