//
//  SearchViewController.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(searchViewController: SearchViewController, addButtonPressedFor cell: SearchResultTableViewCell)
}

class SearchViewController: UIViewController {
    
    weak var delegate: SearchViewControllerDelegate?
    
    lazy var parentSearchController = UISearchController(searchResultsController: self)
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SongInfoViewController" {
            let vc = segue.destination as! SongInfoViewController
            if let searchResultItem =  vm.selectedSearchResultItem {
                vc.vm.song = searchResultItem.song
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerViewHeight.constant = 0
    }
    
    @objc func search() {
        guard let searchText = parentSearchController.searchBar.text, !searchText.isEmpty else { return }
        Task {
            let result = await vm.search(query: searchText)
            switch result {
            case.success:
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                showAlert(title: error.localizedDescription)
            }
        }
    }
    
    func showHeaderView(_ bool: Bool) {
        self.headerLabel?.text = "Spotify is not linked. Unable to sync."
        self.headerViewHeight?.constant = bool ? 43 : 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func updateIsAddedStatus(with playlist: [PlaylistItem]) {
        vm.updateIsAddedStatus(with: playlist)
        if tableView != nil { tableView.reloadData() }
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
        guard let searchText = parentSearchController.searchBar.text, !searchText.isEmpty else {
            vm.reset()
            tableView.reloadData()
            return
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(search), object: nil)
        perform(#selector(search), with: nil, afterDelay: 0.2)
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
        cell.searchResultItem = vm.searchResult[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vm.selectedSearchResultItem = vm.searchResult[indexPath.row]
        performSegue(withIdentifier: "SongInfoViewController", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchViewController: SearchResultTableViewCellDelegate {
    
    func searchTableViewCell(addButtonPressedFor cell: SearchResultTableViewCell) {
        delegate?.searchViewController(searchViewController: self, addButtonPressedFor: cell)
    }
}
