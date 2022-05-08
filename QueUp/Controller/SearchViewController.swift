//
//  SearchViewController.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ searchViewController: SearchViewController, didAdd song: Song)
}

class SearchViewController: UIViewController {
    
    weak var delegate: SearchViewControllerDelegate?
    
    lazy var parentSearchController = UISearchController(searchResultsController: self)
    @IBOutlet weak var tableViewHeaderLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var vm = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parentSearchController.delegate = self
        parentSearchController.searchResultsUpdater = self
        parentSearchController.searchBar.autocapitalizationType = .none
        parentSearchController.searchBar.setValue("Done", forKey: "cancelButtonText")
        updateSearchBarFont()
        tableView.dataSource = self
        tableView.delegate = self
        
        Task {
            let result = await vm.initialize()
            switch result {
            case.success:
                print("SpotifyService initialized")
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updateSearchBarFont() {
        if let textfield = parentSearchController.searchBar.value(forKey: "searchField") as? UITextField {
            let attrString = NSAttributedString(string: "Search songs, artists, albums",
                                                attributes: [.font : UIFont(name: "Avenir Next", size: 17) ?? .systemFont(ofSize: 17)])
            textfield.attributedPlaceholder = attrString
        }
    }
}

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else { return }
        Task {
            let result = await vm.search(query: searchText)
            switch result {
            case.success:
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension SearchViewController: UISearchControllerDelegate {
    
    func presentSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = true
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell", for: indexPath) as! SearchResultTableViewCell
        cell.update(with: vm.searchResult[indexPath.row])
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
