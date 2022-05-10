//
//  PlaylistViewController.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import UIKit

class PlaylistViewController: UIViewController {

    lazy var searchViewController = storyboard?.instantiateViewController(identifier: "SearchViewController") as! SearchViewController
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addSongButton: UIButton!
    
    var vm = PlaylistViewModel()
    private var isAnimating: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = SessionService.shared.currentRoom.id
        navigationItem.searchController = searchViewController.parentSearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        collectionView.dataSource = self
        collectionView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm.playlistItemsListener { result in
            print("playlistItemsListener fired")
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.addSongButton.isHidden = !self.vm.playlist.items.isEmpty
                    self.searchViewController.updateCurrentPlaylist(currentPlaylist: self.vm.playlist)
                }
            case .failure(let error):
                print(error)
            }
        }
        
        vm.sessionListener { result in
            print("sessionListener fired")
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        vm.stopListeners()
        vm.resetServices()
    }
    
    @IBAction func addSongButtonPressed(_ sender: UIButton) {
        navigationItem.searchController?.searchBar.becomeFirstResponder()
    }
}

extension PlaylistViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCollectionViewCell", for: indexPath) as! UserCollectionViewCell
        cell.update(with: vm.users[indexPath.row])
        return cell
    }
}

extension PlaylistViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
}

extension PlaylistViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.playlist.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistTableViewCell", for: indexPath) as! PlaylistTableViewCell
        cell.update(with: vm.playlist.items[indexPath.row])
        return cell
    }
}

extension PlaylistViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }    
}
