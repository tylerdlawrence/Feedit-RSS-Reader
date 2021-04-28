//
//  ImageServices.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

//import SwiftUI
//import Combine
//import Foundation
//
//class ImageLoader: ObservableObject {
//    @Published var image: UIImage?
//
//    private let url: URL
//
//    private var cancellable: AnyCancellable?
//
//    private var cache: ImageCache?
//
//    private(set) var isLoading = false
//
//    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")
//
//    init(url: URL, cache: ImageCache? = nil) {
//        self.url = url
//        self.cache = cache
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
//            .subscribe(on: Self.imageProcessingQueue)
//            .map { UIImage(data: $0.data) }
//            .replaceError(with: nil)
//            .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() }, receiveOutput: { [weak self] in self?.cache($0) }, receiveCompletion: { [weak self] _ in self?.onFinish() }, receiveCancel: { [weak self] in self?.onFinish() })
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] in self?.image = $0 }
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
//
//    func cancel() {
//        cancellable?.cancel()
//    }
//}
//
//struct AsyncImage<Placeholder: View>: View {
//    @StateObject private var loader: ImageLoader
//    private let placeholder: Placeholder
//    private let image: (UIImage) -> Image
//
//    init(
//        url: URL,
//        @ViewBuilder placeholder: () -> Placeholder,
//        @ViewBuilder image: @escaping (UIImage) -> Image = Image.init(uiImage:)
//    ) {
//        self.placeholder = placeholder()
//        self.image = image
//        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: Environment(\.imageCache).wrappedValue))
//    }
//
//    var body: some View {
//        content
//            .onAppear(perform: loader.load)
//    }
//
//    private var content: some View {
//        Group {
//            if loader.image != nil {
//                image(loader.image!)
//            } else {
//                placeholder
//            }
//        }
//    }
//}
//
//struct AsyncImageView: View {
//
//    @StateObject var viewModel = RSSFeedViewModel(rss: RSS(), dataSource: DataSourceService.current.rssItem)
//
//    var filteredArticles: [RSSItem] {
//        return viewModel.items.filter({ (item) -> Bool in
//            return !((self.viewModel.isOn && !item.isArchive) || (self.viewModel.unreadIsOn && item.isRead))
//        })
//    }
//
//    let posters = [
//        "https://image.tmdb.org/t/p/original/pThyQovXQrw2m0s9x82twj48Jq4.jpg",
//        "https://image.tmdb.org/t/p/original/vqzNJRH4YyquRiWxCCOH0aXggHI.jpg",
//        "https://image.tmdb.org/t/p/original/6ApDtO7xaWAfPqfi2IARXIzj8QS.jpg",
//        "https://image.tmdb.org/t/p/original/7GsM4mtM0worCtIVeiQt28HieeN.jpg"
//    ].map { URL(string: $0)! }
//
//    let url = URL(string: "https://image.tmdb.org/t/p/original/pThyQovXQrw2m0s9x82twj48Jq4.jpg")!
//
//    @State var numberOfRows = 0
//
//    ////                                AsyncImage(url: URL(string: item.url)!, placeholder: { ProgressView() }, image: { Image(uiImage: $0).resizable() }).frame(width: 60, height: 60)
//
//    var body: some View {
//        NavigationView {
//            //list.navigationBarItems(trailing: addButton)
//            List(filteredArticles, id: \.self) { item in
//                AsyncImage(url: item.thumbnailURL!, placeholder: { ProgressView() }, image: { Image(uiImage: $0).resizable() }).environment(\.managedObjectContext, Persistence.current.context).environmentObject(DataSourceService.current.rssItem)
//                    .frame(idealHeight: UIScreen.main.bounds.width / 2 * 3)
//            }.navigationBarItems(trailing: addButton)
//        }
//    }
//    private var list: some View {
//        List(0..<numberOfRows, id: \.self) { _ in
//            AsyncImage(url: self.url, placeholder: { ProgressView() })
//                .frame(minHeight: 200, maxHeight: 200)
//                .aspectRatio(2 / 3, contentMode: .fit)
//        }
//    }
//    private var addButton: some View {
//        Button(action: { self.numberOfRows += 1 }) { Image(systemName: "plus") }
//    }
//}
//
//struct AsyncImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        AsyncImageView()
//            .preferredColorScheme(.dark)
//    }
//}
//
//protocol ImageCache {
//    subscript(_ url: URL) -> UIImage? { get set }
//}
//
//struct TemporaryImageCache: ImageCache {
//    private let cache = NSCache<NSURL, UIImage>()
//
//    subscript(_ key: URL) -> UIImage? {
//        get { cache.object(forKey: key as NSURL) }
//        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
//    }
//}
//
//struct ImageCacheKey: EnvironmentKey {
//    static let defaultValue: ImageCache = TemporaryImageCache()
//}
//
//extension EnvironmentValues {
//    var imageCache: ImageCache {
//        get { self[ImageCacheKey.self] }
//        set { self[ImageCacheKey.self] = newValue }
//    }
//}

//import SwiftUI
//import FeedKit
//import UIKit
//import Combine
//import Foundation
//
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

//import Combine
//import Foundation
//import SwiftUI
//
//class ImageLoader: ObservableObject {
//    @Published var data = Data()
//
//    func load(url:URL) {
//        loadImage(fromURL: url)
//    }
//
//    func load(urlString:String) {
//        guard let url = URL(string: urlString) else { return }
//        loadImage(fromURL: url)
//    }
//
//    // MARK: - Private
//    private var cancellable:AnyCancellable?
//
//    private func loadImage(fromURL url:URL) {
//        cancellable = RESTClient.loadData(atURL: url)
//            .replaceError(with: Data())
//            .receive(on: RunLoop.main)
//            .assign(to: \.data, on: self)
//    }
//}
//
//enum RESTClientError:Error {
//    case generic(String)
//}
//
//class RESTClient {
//    class func loadData(atURL url:URL) -> AnyPublisher<Data, Error> {
//        URLSession.shared.dataTaskPublisher(for: url)
//            .map {$0.data}
//            .mapError { error in
//                RESTClientError.generic(error.localizedDescription)
//            }
//            .eraseToAnyPublisher()
//    }
//}
//
//

import Combine
import Foundation
import SwiftUI

class ImageLoader: ObservableObject {
    @Published var data:Data?
    
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

struct ImageView: View {
    
    @ObservedObject var imageLoader:ImageLoader
    @State var image:UIImage = UIImage()
    
    init(withURL url:String) {
        imageLoader = ImageLoader(urlString:url)
    }
    
    var body: some View {
        VStack {
            Image(uiImage: imageLoader.data != nil ? UIImage(data:imageLoader.data!)! : UIImage()).resizable().aspectRatio(contentMode: .fit).frame(width:60, height:60)
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(withURL: "")
    }
}
