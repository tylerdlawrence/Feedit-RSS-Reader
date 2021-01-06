//
//  FeedUtils.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 1/5/21.
//

import SwiftUI
import Foundation
import SDWebImage

enum NetworkError: Error {
    case invalidURL
    case invalidData
    case parseFail
}

class FeedUtils {
    static var descPattern = "<(\"[^\"]*\"|\'[^\']*\'|[^\'\">])*>"
    // TODO: We need to add timeout logic when it gets fail or try to use alamofire lib for this.
    static func get(urlString: String, completion: @escaping (Result<[RSSItem], Error>) -> ()) {
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.invalidData))
                return
            }
            
            let decoder = JSONDecoder()
            guard (try?decoder.decode([URL: Bool].self, from: data)) != nil
            else {
                completion(.failure(NetworkError.parseFail))
                return
            }
            //completion(.success(feed.items))
        })
        task.resume()
    }
    
    static func thumurl(desc:String)->String {
        let srcPattern = "(src=)[\"|\'](.*?)[\"|\']+"
        let htmltag = desc.extractAll(pattern: FeedUtils.descPattern).joined()
        var thumSrc = htmltag.extractAll(pattern: srcPattern).joined()
        thumSrc = thumSrc.replacingOccurrences(of: "src=", with: "")
        thumSrc = thumSrc.replacingOccurrences(of: "\"", with: "")
        return thumSrc
    }
    
    static func description(desc:String)->String {
        let desc = desc.replaceAll(pattern: FeedUtils.descPattern, to: "")
        return desc
    }
    
    static func https(link:String)->String {
        let url = link.replacingOccurrences(of: "http", with: "https")
        return url
    }
}

extension String {
  func match(pattern:String) -> Bool {
    let regex = try! NSRegularExpression(pattern:pattern)
    return regex.firstMatch(in:self, range:NSRange(self.startIndex..., in:self)) != nil
  }

  func extractAll(pattern:String) -> [String] {
    let regex = try! NSRegularExpression(pattern:pattern)
    return regex.matches(in:self, range:NSRange(self.startIndex..., in:self)).map { String(self[Range($0.range, in:self)!]) }
  }

  func replaceAll(pattern:String, to:String) -> String {
    return self.replacingOccurrences(of:pattern, with:to, options:NSString.CompareOptions.regularExpression, range:self.range(of:self))
  }
}

struct ItemRow: View {
    let item:RSSItem
    
    init(data:RSSItem){
        self.item = data
    }
    var body: some View{
        URLImage(url: FeedUtils.thumurl(desc: self.item.description)).frame(width: 50, height: 50)
    }
}

struct Placeholder{
    static let feedURL = "https://api.rss2json.com/v1/api.json?rss_url=https://sneakerwars.jp/items.rss" //"https://daringfireball.net/feeds/json" //"https://github.blog/feed" //"https://github.com/tylerdlawrence.private.atom?token=APGIAGGIMXIIPQV5UM6IGLV6AEKL2" //"https://feedbin.com/starred/393a5d17933784928e13bd24e787e4f8.xml"//"https://api.rss2json.com/v1/api.json?rss_url=https://sneakerwars.jp/items.rss"
    static let imageURL = "https://img.sneakerwars.jp/images/11929/thumbnails/NIKE_AIR-MAX-95-UTILITY-NRG_MT-FUJI_CT3689-600-1.jpg" //"https://pbs.twimg.com/profile_images/1319257977283633154/V7knOQ54_400x400.jpg" //"https://img.sneakerwars.jp/images/11929/thumbnails/NIKE_AIR-MAX-95-UTILITY-NRG_MT-FUJI_CT3689-600-1.jpg"
}

struct URLImage: View {
    @ObservedObject private var imageDownloader = ImageDownloader()
    let url:String
    init(url:String){
        self.url = url
        self.imageDownloader.downloadImage(url: self.url)
    }
    
    var body: some View {
        if let imageData = self.imageDownloader.downloadedData {
            let img = UIImage(data:imageData)
            return VStack{
                Image(uiImage:img!).resizable()
            }
        } else {
            return VStack{
                Image("feedbin").resizable()

            }
        }
    }
}

struct URLImage_Previews: PreviewProvider {

    static var previews: some View {
        URLImage(url:Placeholder.imageURL)
    }
}

class ImageDownloader:ObservableObject {
    @Published var downloadedData:Data? = nil
    func downloadImage(url:String) {
        guard let imageURL = URL(string: url) else { return }
        let urlRef = url
        SDWebImageManager.shared.loadImage(with: imageURL,
                                           options: .progressiveLoad,
                                           context: nil,
                                           progress: nil,
                                           completed: { (image, data, error, cache, finished, url) in
                                            
                                            if data == nil {
        SDImageCache.shared.diskImageExists(withKey: urlRef) { exists in
            if exists {
                self.downloadedData = SDImageCache.shared.diskImageData(forKey: urlRef)
            }
        }
                                            } else {
                                                self.downloadedData = data;
                                            }
        })
    }
}
