//
//  AddRSSSourceViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import UIKit

class AddRSSViewModel: NSObject, ObservableObject {
    
    @Published var rss: RSS?
    
    let dataSource: RSSDataSource

    init(dataSource: RSSDataSource) {
        self.dataSource = dataSource
        
        super.init()
        beginCreateNewRSS()
    }
    
    func beginCreateNewRSS() {
        dataSource.discardNewObject()
        dataSource.prepareNewObject()
        rss = dataSource.newObject

    }
    var onDoneAction: (() -> Void)?
    func commitCreateNewRSS() {
        dataSource.saveCreateContext()
    }
        
    func cancelCreateNewRSS() {
        dataSource.discardCreateContext()
    }
    

}

class AlertController: UIAlertController {
    //avoid Snapshotting https://stackoverflow.com/questions/30685379/swift-getting-snapshotting-a-view-that-has-not-been-rendered-error-when-try
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
    }
    
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

}
