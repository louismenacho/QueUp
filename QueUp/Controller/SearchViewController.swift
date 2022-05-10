//
//  SearchViewController.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import UIKit

class SearchViewController: UIViewController {
    
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
    }
    
    func updateCurrentPlaylistItems(currentPlaylistItems: [PlaylistItem]) {
        vm.currentPlaylistItems = currentPlaylistItems
        if tableView != nil { updateSearchResults(for: parentSearchController) }
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
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            vm.reset()
            tableView.reloadData()
            return
        }
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
        cell.delegate = self
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

extension SearchViewController: SearchResultTableViewCellDelegate {
    
    func searchTableViewCell(addButtonPressedFor cell: SearchResultTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let result = vm.addSong(at: indexPath.row)
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
