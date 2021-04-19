//
//  WidgetContent.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 4/17/21.
//

import Foundation
import WidgetKit
import SwiftUI
import Combine

//ViewModel conforms to the Identifiable protocol since it has to supply data to the List. The List uses the id property to make sure that the contents of the list are unique

struct ArticleViewModel: Identifiable {
    
    let id = UUID()
    
    let article: Article
    
    init(article: Article) {
        self.article = article
    }
    
    var title: String {
        return self.article.title
    }
    
    var description: String {
        return self.article.description ?? ""
    }
    
    var sourceName: String {
        return self.article.source.name
    }
    var urlToImage: String {
        return self.article.urlToImage ?? ""
    }
    
    var urlWeb: String {
        return self.article.url
    }
    
    var image: UIImage!
    
    var publishedAt: String? {
        //2020-11-11T21:04:00Z
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        df.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = df.date(from: self.article.publishedAt) {
            df.dateStyle = .medium
            df.timeStyle = .short
            return df.string(from: date)
        } else {
            return nil
        }
    }
}


class WidgetImage: ObservableObject {
    @Published var widgetimage: Image = WidgetContent.readImage()!
}

protocol WidgetContentProtocol {
    var date: Date { get set }
    var title: String  { get set }
    var description: String  { get set }
}

struct NewsWidgetContent: WidgetContentProtocol, TimelineEntry {
    var date: Date
    var title: String
    var description: String
    var image: UIImage?
}


struct WidgetContent: WidgetContentProtocol ,TimelineEntry, Codable {
    var date = Date()
    var title: String
    var description: String
}

extension WidgetContent {
    
    //saves image in shared container
    static func writeImage(image: UIImage) {
        if let archiveURL = FileManager.sharedContainerURL() {
            let url = archiveURL.appendingPathComponent("widgetImage.png")
            print("writeImage: \(url)")
            guard let data = image.pngData() else { return }
            do {
                try data.write(to: url)
            } catch {
                print("Error saving image file ")
            }
            
        }
    }
    
    //read saved image in shared container
    static func readImage() -> Image? {
        if let archiveURL = FileManager.sharedContainerURL() {
            let url = archiveURL.appendingPathComponent("widgetImage.png")
            print("readImage: \(url)")
            if FileManager.default.fileExists(atPath: url.path) {
                print("Image found!")
                let img = Image(url.path)
                return img
            } else {
                print("Error reading image file ")
            }
        }
        return nil
    }
    
    //saves struct in xml in shared container
    static func writeContents(widgetContent: [WidgetContent]) {
        if let archiveURL = FileManager.sharedContainerURL() {
            let url = archiveURL.appendingPathComponent("contents")
            print("writeContents: \(url)")
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            if let data = try? encoder.encode(widgetContent) {
                do {
                    try data.write(to: url)
                } catch {
                    print("Error: Can't write contents")
                    return
                }
            }
        }
    }
    
    //read struct from xml in shared container
    static func readContents() -> [WidgetContent] {
        if let archiveURL = FileManager.sharedContainerURL() {
            let url = archiveURL.appendingPathComponent("contents")
            let decoder = PropertyListDecoder()
            do {
                let data = try Data(contentsOf: url)
                return try decoder.decode([WidgetContent].self, from: data)
            } catch {
                print(error)
                print(error.localizedDescription)
            }
        }
        return []
    }
    
    
    //Network update
    static func loadData(completion: @escaping ([Article]?) -> ()) {
        
        let urlString = "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=3845667a828c4e3ab88593f284a10f32"

        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let data = data, error == nil {
                
                let response = try? JSONDecoder().decode(JSONModel.self, from: data)
                if let response = response {
                    DispatchQueue.main.async {
                        completion(response.articles)
                    }
                }
            } else {
                print("Error in: \(#function)")
                completion(nil)
            }
        }
        task.resume()
        
    }
    
    //get images from network
    static func downloadImageBy(url: String, completion: @escaping (UIImage)->Void) {
        
        guard let url = URL(string: url) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
                }
            }
        }
        task.resume()
    }
    
}

//URL to shared container
extension FileManager {
    static func sharedContainerURL() -> URL? {
        return FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.tylerdlawrence.feedit.shared"
        )
    }
}

//init this model by fetchData()
class ArticleListViewModel: ObservableObject {
    
    @Published var articles = [ArticleViewModel]()
    
    init() {
        fetchData()
        
    }

    private func fetchData() {
        NetworkService.loadData() { articles in
            if let articles = articles {
                self.articles = articles.map(ArticleViewModel.init)
                let widgetContent = articles.map { (article) in
                    WidgetContent(title: article.title, description: article.description ?? "")
                }
                self.imagesData()
                WidgetContent.writeContents(widgetContent: widgetContent)
            }
        }
    }
    
    private func imagesData(_ index: Int = 0) {
        guard articles.count > index else { return }
        let article = articles[index]
        ImageStore.downloadImageBy(url: article.urlToImage) {
            self.articles[index].image = $0
            if self.articles[0].image != nil, index == 0 {
            WidgetContent.writeImage(image: self.articles[0].image)
            }
            self.imagesData(index + 1)
        }
        
    }
}

class NetworkService {
    
    static func loadData(completion: @escaping ([Article]?) -> ()) {
        
        let urlString = "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=3845667a828c4e3ab88593f284a10f32"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let data = data, error == nil {
                
                let response = try? JSONDecoder().decode(JSONModel.self, from: data)
                if let response = response {
                    DispatchQueue.main.async {
                        completion(response.articles)
                    }
                }
            } else {
                print("Error in: \(#function)")
                completion(nil)
            }
        }
        task.resume()
        
    }
    
}

final class ImageStore {
//    typealias _ImageDictionary = [String: CGImage]
//    fileprivate var images: _ImageDictionary = [:]
//
//    fileprivate static var scale = 2
//
//    static var shared = ImageStore()
//
//    //provide Image from Store
//    func image(name: String) -> Image {
//        let index = _guaranteeImage(name: name)
//
//        return Image(images.values[index], scale: CGFloat(ImageStore.scale), label: Text(name))
//    }
//
    static func downloadImageBy(url: String, completion: @escaping (UIImage)->Void) {
        
        guard let url = URL(string: url) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
                }
            }
        }
        task.resume()
    }

//    //load image
//    static func loadImage(name: String) -> CGImage {
//        guard
//            let url = Bundle.main.url(forResource: name, withExtension: "jpg"),
//            let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
//            let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
//        else {
//            fatalError("Couldn't load image \(name).jpg from main bundle.")
//        }
//        return image
//    }
//
//    //find Image by name
//    fileprivate func _guaranteeImage(name: String) -> _ImageDictionary.Index {
//        if let index = images.index(forKey: name) { return index }
//
//        images[name] = ImageStore.loadImage(name: name)
//        return images.index(forKey: name)!
//    }
}
