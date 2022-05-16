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
    
    var roomVM = RoomViewModel()
    var usersVM = UsersViewModel()
    var playlistVM = PlaylistViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchViewController.parentSearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        collectionView.dataSource = self
        collectionView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        roomVM.roomListener { result in
            print("roomListener fired")
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.navigationItem.title = self.roomVM.room.id
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                    if !self.roomVM.isHost(self.usersVM.signedInUser()) {
                        self.navigationItem.rightBarButtonItem = nil
                    }
                }
            case .failure(let error):
                print(error)
                if let error = error as? DecodingError, case .valueNotFound = error {
                    self.navigationController?.popToRootViewController(animated: true)
                    self.navigationController?.showAlert(title: "Host closed the room")
                    self.roomVM.unsaveRoomId()
                }
            }
        }
        
        usersVM.usersListener { result in
            print("usersListener fired")
            switch result {
            case .success:
                DispatchQueue.main.async {
                    let signedInUser = self.usersVM.signedInUser()
                    if self.usersVM.getUser(signedInUser) == nil {
                        self.navigationController?.popToRootViewController(animated: true)
                        self.navigationController?.showAlert(title: "Host removed you from room")
                    }
                    self.playlistVM.updateAddedByDisplayNames(with: self.usersVM.users)
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
        
        playlistVM.playlistListener { result in
            print("playlistListener fired")
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.searchViewController.updateIsAddedStatus(with: self.playlistVM.playlist)
                    self.playlistVM.updateAddedByDisplayNames(with: self.usersVM.users)
                    self.addSongButton.isHidden = !self.playlistVM.playlist.isEmpty
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        roomVM.stopListener()
        usersVM.stopListener()
        playlistVM.stopListener()
    }
    
    @IBAction func addSongButtonPressed(_ sender: UIButton) {
        navigationItem.searchController?.searchBar.becomeFirstResponder()
    }
    
    @IBAction func rightBarButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "RoomInfoViewController", sender: self)
    }
}

extension PlaylistViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        usersVM.users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let user = usersVM.users[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCollectionViewCell", for: indexPath) as! UserCollectionViewCell
        cell.update(with: usersVM.users[indexPath.row])
        if roomVM.isHost(user) {
            cell.showCircleBorder()
        }
        return cell
    }
}

extension PlaylistViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 77)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = usersVM.users[indexPath.row]
        if roomVM.isHost(user) || !roomVM.isHost(usersVM.signedInUser())  { return }
        showActionSheet(title: user.displayName, action: .init(title: "Remove", style: .destructive) {  action in
            Task {
                let result = await self.usersVM.deleteUser(user)
                switch result {
                case.success:
                    print(user.displayName+" removed from room")
                case .failure(let error):
                    print(error)
                }
            }
        })
    }
}

extension PlaylistViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistVM.playlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistTableViewCell", for: indexPath) as! PlaylistTableViewCell
        cell.update(with: playlistVM.playlist[indexPath.row])
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
