//
//  FeedTableViewController.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 10/3/20.
//

import SwiftUI
import UIKit

class FeedDetailTableViewController: UITableViewController {
    
    fileprivate let text: String
    
    init(text: String) {
        self.text = text
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = self.text
        return cell
    }
    
}


struct FeedTableViewController_Previews: PreviewProvider {
    static var previews: some View {
        FeedTableViewController()
    }
}
