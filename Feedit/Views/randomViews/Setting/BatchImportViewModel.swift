//
//  BatchImportViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/15/20.
//

import Foundation

struct BatchImportModel: Codable {
    
    var url: String
    var title: String?
    var description: String?
    var imageUrl: String?

    func apply(in rss: RSS) {
        rss.url = url
        if let t = title {
            rss.title = t
        }
        if let d = description {
            rss.desc = d
        }
        if let img = imageUrl {
            rss.image = img
        }
    }
}

class BatchImportViewModel: NSObject, ObservableObject {
    
    let dataSource: RSSDataSource
    var start = 0
    
    init(dataSource: RSSDataSource) {
        self.dataSource = dataSource
        super.init()
    }
    
    func batchInsert(JSONText: String) {
        let models = parseJson2Model(JSONText)
        let total = models.count
        let group = DispatchGroup()
        for model in models {
            guard let url = URL(string: model.url) else { continue }
            dataSource.discardNewObject()
            dataSource.prepareNewObject()
            guard let rss = dataSource.newObject else { continue }
            group.enter()
            updateNewRSS(url: url, for: rss) { rs in
                switch rs {
                case .success(let rss):
                    print("rss = \(rss)")
                    model.apply(in: rss)
                    self.dataSource.newObject = rss
                case .failure(let error):
                    print("error = \(error)")
                }
                group.leave()
                
                NotificationCenter.default.post(
                    name: NSNotification.Name.init("addNewRSSPublisher"),
                    object: nil,
                    userInfo: ["total": Double(total)]
                )
            }
        }
        group.notify(queue: DispatchQueue.main) {
            _ = self.dataSource.saveNewObject()
            NotificationCenter.default.post(
                name: Notification.Name.init("rssListNeedRefresh"),
                object: nil,
                userInfo: nil
            )
        }
    }
    
    func batchInsert(_ jsonURL: URL) {
        guard let jsonStr = try? String(contentsOf: jsonURL, encoding: .utf8) else {
            return
        }
        batchInsert(JSONText: jsonStr)
    }
    
    func parseJson2Model(_ jsonStr: String) -> [BatchImportModel] {
        let jsonDecoder = JSONDecoder()
        guard let jsonData = jsonStr.data(using: .utf8) else {
            return []
        }
        let models = try? jsonDecoder.decode([BatchImportModel].self, from: jsonData)
        return models ?? []
    }
    
    func discardCreateContext() {
        self.dataSource.discardNewObject()
        self.dataSource.discardCreateContext()
    }
}
