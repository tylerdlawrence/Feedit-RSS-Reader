//
//  AddRSSSourceViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import UIKit
import SwiftUI
import Combine

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
        
    func commitCreateNewRSS() {
        dataSource.saveCreateContext()
    }
        
    func cancelCreateNewRSS() {
        dataSource.discardCreateContext()
    }
}
