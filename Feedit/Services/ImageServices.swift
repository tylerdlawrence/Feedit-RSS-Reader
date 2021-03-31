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

class ImageLoader: ObservableObject {
    var dataPublisher = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            dataPublisher.send(data)
        }
     }
    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data else { return }
        DispatchQueue.main.async {
           self.data = data
        }
    }
    task.resume()
  }
}

//struct ImageView: View {
//    @ObservedObject var imageLoader:ImageLoader
//    @State var image:UIImage = UIImage()
//
//    init(withURL url:String) {
//        imageLoader = ImageLoader(urlString:url)
//    }
//
//var body: some View {
//    VStack {
//        Image(uiImage: image)
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//
//    }.onReceive(imageLoader.dataPublisher) { data in
//        self.image = UIImage(data: data) ?? UIImage()
//    }
//  }
//}
//struct ImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageView(withURL: "")
//    }
//}

//public class ImageService {
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
//
//public final class ImageLoader: ObservableObject {
//    public let path: String?
//
//    public var objectWillChange: AnyPublisher<UIImage?, Never> = Publishers.Sequence<[UIImage?], Never>(sequence: []).eraseToAnyPublisher()
//
//    @Published public var image: UIImage? = nil
//
//    public var cancellable: AnyCancellable?
//
//    public init(path: String?) {
//        self.path = path
//
//        self.objectWillChange = $image.handleEvents(receiveSubscription: { [weak self] sub in
//            self?.loadImage()
//        }, receiveCancel: { [weak self] in
//            self?.cancellable?.cancel()
//        }).eraseToAnyPublisher()
//    }
//
//    private func loadImage() {
//        guard let poster = path, let url = URL(string: poster), image == nil else {
//            return
//        }
//        cancellable = ImageService.shared.fetchImage(url: url)
//            .receive(on: DispatchQueue.main)
//            .assign(to: \ImageLoader.image, on: self)
//    }
//
//    deinit {
//        cancellable?.cancel()
//    }
//}
