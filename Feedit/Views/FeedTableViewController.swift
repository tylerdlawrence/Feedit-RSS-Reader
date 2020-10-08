//
//  FeedTableViewController.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 10/3/20.
//

import SwiftUI
import UIKit
import FeedKit

let feedURL = URL(string: "http://images.apple.com/main/rss/hotnews/hotnews.rss")!

class FeedTableViewController: UITableViewController {
    
    let parser = FeedParser(URL: feedURL)
    
    var rssFeed: RSSFeed?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Feed"
        
        // Parse asynchronously, not to block the UI.
        parser.parseAsync { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let feed):
                // Grab the parsed feed directly as an optional rss, atom or json feed object
                self.rssFeed = feed.rssFeed
                
                // Or alternatively...
                //
                // switch feed {
                // case let .rss(feed): break
                // case let .atom(feed): break
                // case let .json(feed): break
                // }
                
                // Then back to the Main thread to update the UI.
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
}

// MARK: - Table View Data Source

extension FeedTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4
        case 1: return self.rssFeed?.items?.count ?? 0
        default: fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reusableCell()
        guard let layout = TableViewLayout(indexPath: indexPath) else { fatalError() }
        switch layout {
        case .title:        cell.textLabel?.text = self.rssFeed?.title ?? "[no title]"
        case .link:         cell.textLabel?.text = self.rssFeed?.link ?? "[no link]"
        case .description:  cell.textLabel?.text = self.rssFeed?.description ?? "[no description]"
        case .date:         cell.textLabel?.text = self.rssFeed?.lastBuildDate?.description ?? "[no date]"
        case .items:        cell.textLabel?.text = self.rssFeed?.items?[indexPath.row].title ?? "[no title]"
        }
        return cell
    }
    
}

// MARK: - Table View Delegate

extension FeedTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let layout = RSSTableView(indexPath: indexPath) else { fatalError() }
        switch layout {
        case .title:        self.showDetailViewControllerWithText(self.rssFeed?.title ?? "[no title]")
        case .link:         self.showDetailViewControllerWithText(self.rssFeed?.link ?? "[no link]")
        case .description:  self.showDetailViewControllerWithText(self.rssFeed?.description ?? "[no link]")
        case .date:         self.showDetailViewControllerWithText(self.rssFeed?.lastBuildDate?.description ?? "[no date]")
        case .items:        self.showDetailViewControllerWithText(self.rssFeed?.items?[indexPath.row].description ?? "[no description]")
        }
    }
    
}

// MARK: - Navigation

extension FeedTableViewController {
    
    // MARK: - Navigation
    
    func showDetailViewControllerWithText(_ text: String) {
        let viewController = FeedDetailTableViewController(text: text)
        self.show(viewController, sender: self)
    }
    
}

