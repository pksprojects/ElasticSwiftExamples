//
//  ViewController.swift
//  ElasticSwiftSample-iOS
//
//  Created by Prafull Kumar Soni on 3/5/18.
//  Copyright © 2018 pksprojects. All rights reserved.
//

import UIKit
import NotificationCenter
import ElasticSwiftCore
import ElasticSwift
import ElasticSwiftQueryDSL

class SearchViewController: UITableViewController, UISearchResultsUpdating {
    
    var client: ElasticClient?
    var selectedRow: Int?
    
    var results = [SearchHit<Shakespeare>]()
    var filterring = false
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        client = clientManager.client
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        //refreshControl = UIRefreshControl()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for shakespeare's work"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            // Fallback on earlier versions
        }
        definesPresentationContext = true
        
        self.doSearch(value: "")
        NotificationCenter.default.addObserver(forName: AppNotifications.connectionUpdated, object: nil, queue: nil, using: self.updateConnection)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return results.count
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "shakespeareCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SearchResultTableViewCell else {
            fatalError("Unable to dequeue cell with identifier: \(cellIdentifier)")
        }
        
        // Configure the cell...
        cell.textLabel?.text = results[indexPath.row].source?.textEntry
        cell.shakespeare = results[indexPath.row].source
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row
        self.performSegue(withIdentifier: "toDetailView", sender: nil)
    }
    
    func handler(_ response: Result<SearchResponse<Shakespeare>, Error>) {
        
        switch response {
        case .failure(let error):
            print("Error:", error)
        case .success(let searchResponse):
            self.results = searchResponse.hits.hits
            DispatchQueue.main.sync {
                self.tableView.reloadData()
            }
        }
    }
    
    func updateConnection(_ notification: Notification?) {
        self.client = clientManager.client
        self.doSearch(value: "")
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? DetailsTableViewController{
            destination.shakespeare = self.results[self.selectedRow!].source
        }
        
    }
    
    // MARK: - Search
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            self.doSearch(value: text)
            self.filterring = true
        }
    }
    
    // MARK: - Private instance methods
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func doSearch(value: String) {
        let matchQuery = QueryBuilders.matchQuery()
            .set(field: "text_entry")
            .set(value: value)
            .query
        
        do {
            
            let searchRequest = try SearchRequestBuilder { builder in
                builder.set(indices: "shakespeare")
                    .set(size: 1000)
                if !value.isEmpty {
                    builder.set(query: matchQuery)
                }
            } .build()
            
            self.client?.search(searchRequest, completionHandler: self.handler)
            
        } catch {
            print(error)
        }
    }
    
}

struct Shakespeare: Codable {
    var playName: String
    var type: String
    var lineId: Int
    //var speech_number: Int?
    var lineNo: String
    var speaker: String
    var textEntry: String
    
    func propertyNames() -> [Mirror.Child] {
        return Mirror(reflecting: self).children.compactMap{ $0 }
    }
    
    enum CodingKeys: String, CodingKey {
        case playName = "play_name"
        case type
        case lineId = "line_id"
        case lineNo = "line_number"
        case speaker
        case textEntry = "text_entry"
    }
}

