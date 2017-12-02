//
//  ViewController.swift
//  SearchStore
//
//  Created by Curtis Wiseman on 10/21/17.
//  Copyright © 2017 Curtis Wiseman. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    var searchResults = [SearchResult]()
    
    //To check that state if we searched a item or not
    var hasSearched = false
    
    //A state variable to determine if were loading
    var isLoading = false
    var dataTask: URLSessionDataTask?
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func segmentedChange(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib,forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        tableView.rowHeight = 80
        
        searchBar.becomeFirstResponder()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func iTunesURL(searchText: String, category: Int) -> URL {
        let entityName: String
        switch category{
        case 1: entityName = "musicTrack"
        case 2: entityName = "software"
        case 3: entityName = "ebook"
        default: entityName = ""
        }
        
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "http://itunes.apple.com/search?term=%@&limit=200&entity=%@",escapedSearchText,entityName)
        let url = URL(string: urlString)
        return url!
        
    }
    
    func performStoreRequest(with url: URL) -> String?{
        do{
            return try String(contentsOf:url,encoding: .utf8)
        }catch{
            print("Download error: \(error)")
            return nil
        }
    }
    
    func parse(json data: Data) -> [String: Any]? {
        do{
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }catch{
            print("JSON Error \(error)")
            return nil
        }
    }
    
    func parse(dictionary: [String:Any]) -> [SearchResult]{
        guard let array = dictionary["results"] as? [Any] else {
            print("Unexpected results array")
            return []
        }
        
        var searchResults: [SearchResult] = []
        
        for result in array {
            var searchResult: SearchResult?
            if let result = result as? [String:Any]{
            if let wrapperType = result["wrapperType"] as? String{
                switch wrapperType{
                case "track":
                    searchResult = parse(track: result)
                case "audiobook":
                    searchResult = parse(audiobook: result)
                case "software":
                    searchResult = parse(software: result)
                    
                default:
                    break
                    
                }
            }else if let kind = result["kind"] as? String, kind == "ebook"{
                searchResult = parse(ebbok: result)
                }
                
                
                
                if let res = searchResult {
                    searchResults.append(res)
                }
            }
            
        }
            
        
        return searchResults
    }
    
    func parse(track dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
    }
    
    func parse(audiobook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
    }
    
    func parse(software dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
    }
    func parse(ebbok dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genres: Any = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joined(separator: ", ")
        }
        
        return searchResult
    }
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    func showNetworkError() {
        let alertController = UIAlertController(title: "Whoops.....", message: "There was a error from the itunes store", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController,animated:true,completion: nil)
    }
    
    


}

extension SearchViewController: UISearchBarDelegate {
    func performSearch() {
        
        if !searchBar.text!.isEmpty{
            searchBar.resignFirstResponder()
            dataTask?.cancel()
            isLoading = true
            tableView.reloadData()
            
            hasSearched = true
            searchResults = []
            
            let url = self.iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
            let session = URLSession.shared
            
            dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
                if let error = error as? NSError, error.code == -999 {
                    print("Failure! \(error)")
                }else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    
                    if let data = data , let jsonDictionary = self.parse(json: data){
                        print("\(jsonDictionary)")
                        self.searchResults = self.parse(dictionary: jsonDictionary)
                        self.searchResults.sort(by: <)
                        
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        return
                    }
                }
                else {
                 print("Failure \(response)")
                }
               
                
            })
            dataTask?.resume()
            
            
    
                    
              
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading{
            return 1
        }
        else if !hasSearched{
            return 0
        }
        else if searchResults.count == 0 {
            return 1
        }
        else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isLoading{
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
        
        
        else if searchResults.count == 0{
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        }
        else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
            
        let searchResult = searchResults[indexPath.row]
        cell.configure(for: searchResult)
        return cell
        }
        
        
    }
    
}

extension SearchViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading{
            return nil
        }else {
            return indexPath
        }
    }
}

