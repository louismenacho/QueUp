//
//  PlaylistViewController.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import UIKit

class PlaylistViewController: UIViewController {

    lazy var searchViewController = storyboard?.instantiateViewController(identifier: "SearchViewController") as! SearchViewController
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addSongButton: UIButton!
    
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    
    var roomVM = RoomViewModel()
    var usersVM = UsersViewModel()
    var playlistVM = PlaylistViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchViewController.parentSearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchViewController.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        headerViewHeight.constant = 0
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        guard roomVM.isHost(usersVM.signedInUser()) else { return }
        relinkSpotifyIfNeeded()
    }
    
    @objc func willEnterForeground() {
        guard roomVM.isHost(usersVM.signedInUser()) else { return }
        relinkSpotifyIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear")
        roomVM.roomListener { result in
            print("roomListener fired")
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.navigationItem.title = self.roomVM.room.id
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                    self.playlistVM.spotifyPlaylistId = self.roomVM.room.spotifyPlaylistId
                    if !self.roomVM.isHost(self.usersVM.signedInUser()) {
                        self.navigationItem.rightBarButtonItem = nil
                    }
                    if self.roomVM.isSpotifyLinked()  {
                        self.headerLabel.text = "Spotify is not linked. Unable to sync."
                        self.headerViewHeight.constant = self.roomVM.isTokenExpired() ? 43 : 0
                        UIView.animate(withDuration: 0.3) {
                            self.view.layoutIfNeeded()
                        }
                    }
                }
            case .failure(let error):
                if let error = error as? DecodingError, case .valueNotFound = error {
                    self.navigationController?.popToRootViewController(animated: true)
                    self.navigationController?.showAlert(title: "Room session ended")
                    self.roomVM.unsaveRoomId()
                } else {
                    self.showAlert(title: error.localizedDescription)
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
                        self.navigationController?.showAlert(title: "Host removed you from the room")
                    }
                    self.playlistVM.mapAddedByDisplayNames(from: self.usersVM.users)
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                self.showAlert(title: error.localizedDescription)
            }
        }
        
        playlistVM.playlistListener { result in
            print("playlistListener fired")
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.searchViewController.updateIsAddedStatus(with: self.playlistVM.playlist)
                    self.playlistVM.mapAddedByDisplayNames(from: self.usersVM.users)
                    self.addSongButton.isHidden = !self.playlistVM.playlist.isEmpty
                    self.tableView.reloadSections(.init(integer: 0), with: .none)
                }
                if self.playlistVM.shouldUpdateSpotifyPlaylist && self.roomVM.isSpotifyLinked() {
                    Task {
                        let updateResult = await self.playlistVM.updateSpotifyPlaylist()
                        switch updateResult {
                        case .success(let didUpdate):
                            print("Did update Spotify: \(didUpdate)")
                            if !didUpdate {
                                self.roomVM.triggerListener()
                            }
                        case .failure(let error):
                            self.showAlert(title: error.localizedDescription)
                        }
                    }
                }
            case .failure(let error):
                self.showAlert(title: error.localizedDescription)
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
    
    func relinkSpotifyIfNeeded() {
        Task {
            let result = await roomVM.relinkSpotifyIfNeeded()
            switch result {
            case.success(let bool):
                print("Spotify token generated: \(bool)")
            case .failure(let error):
                showAlert(title: error.localizedDescription)
            }
        }
    }
}

extension PlaylistViewController: SearchViewControllerDelegate {
    
    func searchViewController(searchViewController: SearchViewController, didUpdatSpotifyWith song: Song) -> Bool {
        if roomVM.isSpotifyLinked() && roomVM.isTokenExpired() {
            return false
        } else {
            playlistVM.shouldUpdateSpotifyPlaylist = true
            return true
        }
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
        if !roomVM.isHost(usersVM.signedInUser()) || roomVM.isHost(user) {
            showActionSheet(title: user.displayName, subtitle: roomVM.isHost(user) ? "Host" : nil)
        } else {
            showActionSheet(title: user.displayName, action: .init(title: "Remove", style: .destructive) {  action in
                Task {
                    let result = await self.usersVM.deleteUser(user)
                    switch result {
                    case.success:
                        print(user.displayName+" removed from room")
                    case .failure(let error):
                        self.showAlert(title: error.localizedDescription)
                    }
                }
            })
        }
    }
}

extension PlaylistViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistVM.playlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistTableViewCell", for: indexPath) as! PlaylistTableViewCell
        cell.delegate = self
        cell.update(with: playlistVM.playlist[indexPath.row])
        if  roomVM.isHost(usersVM.signedInUser()) &&
            roomVM.isSpotifyLinked() &&
            roomVM.isSpotifyProductPremium()
        {
            cell.showPlayButton()
        }
        return cell
    }
}

extension PlaylistViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Remove") { (action, view, completionHandler) in
            Task {
                let result = await self.playlistVM.removeSong(at: indexPath.row)
                switch result {
                case.success:
                    print("removed song")
                case .failure(let error):
                    self.showAlert(title: error.localizedDescription)
                }
            }
            completionHandler(true)
        }
        action.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [action])
    }
}

extension PlaylistViewController: PlaylistTableViewCellDelegate {
    
    func playlistTableViewCell(playButtonPressedFor cell: PlaylistTableViewCell) {
        guard let index = tableView.indexPath(for: cell)?.row else { return }
        let playlistItem = playlistVM.playlist[index]
        cell.playButton.isEnabled = false
        Task {
            let result = await playlistVM.playSong(song: playlistItem.song)
            if case .failure(let error) = result {
                showAlert(title: error.localizedDescription)
            }
            cell.playButton.isEnabled = true
        }
    }
}
