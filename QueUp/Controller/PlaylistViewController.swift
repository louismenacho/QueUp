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
        roomVM.delegate = self
        headerViewHeight.constant = 0
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        guard roomVM.isHost(usersVM.signedInUser()) else { return }
        relinkSpotifyIfNeeded()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SongInfoViewController" {
            let vc = segue.destination as! SongInfoViewController
            if let playlistItem =  playlistVM.selectedPlaylistItem {
                vc.vm.song = playlistItem.song
            }
        }
        if segue.identifier == "RoomInfoViewController" {
            let vc = segue.destination as! RoomInfoViewController
            vc.roomVM = roomVM
            vc.playlistVM = playlistVM
            vc.delegate = self
        }
    }
    
    @objc func willEnterForeground() {
        guard roomVM.isHost(usersVM.signedInUser()) else { return }
        roomVM.resetTokenTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        roomVM.roomListener { result in
//            print("roomListener fired")
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.navigationItem.title = self.roomVM.room.id
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                    
                    self.playlistVM.setFairQueue(self.roomVM.room.isQueueFair)
                    
                    if !self.roomVM.isHost(self.usersVM.signedInUser()) {
                        self.navigationItem.rightBarButtonItem = nil
                    }
                    
                    if self.roomVM.isSpotifyLinked() {
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
//            print("usersListener fired")
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
//            print("playlistListener fired")
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.searchViewController.updateIsAddedStatus(with: self.playlistVM.playlist)
                    self.playlistVM.mapAddedByDisplayNames(from: self.usersVM.users)
                    self.addSongButton.isHidden = !self.playlistVM.playlist.isEmpty
                    self.tableView.reloadSections(.init(integer: 0), with: .none)
                }
                if self.playlistVM.shouldUpdateSpotifyPlaylist && self.roomVM.isSpotifyLinked() {
                    self.updateSpotifyPlaylist()
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
        showActivityIndicator()
        Task {
            let result = await roomVM.relinkSpotifyIfNeeded()
            self.hideActivityIndicator()
            if case .failure(let error) = result {
                showAlert(title: error.localizedDescription)
            }
        }
    }
    
    func updateSpotifyPlaylist() {
        Task {
            let updateResult = await self.playlistVM.updateSpotifyPlaylist()
            switch updateResult {
            case .success(let didUpdate):
                //                            print("Did update Spotify: \(didUpdate)")
                if !didUpdate {
                    self.roomVM.triggerListener()
                }
            case .failure(let error):
                self.showAlert(title: error.localizedDescription)
            }
        }
    }
}

extension PlaylistViewController: RoomViewModelDelegate {
    
    func tokenTimerDidFinish() {
        relinkSpotifyIfNeeded()
    }
}

extension PlaylistViewController: SearchViewControllerDelegate {
    
    func searchViewController(searchViewController: SearchViewController, addButtonPressedFor cell: SearchResultTableViewCell) {
        Task {
            self.playlistVM.shouldUpdateSpotifyPlaylist = self.roomVM.isSpotifyLinked() && !self.roomVM.isTokenExpired()
            let result = await self.playlistVM.addSong(song: cell.searchResultItem.song)
            if case .failure(let error) = result {
                self.showAlert(title: error.localizedDescription)
                self.playlistVM.shouldUpdateSpotifyPlaylist = false
            }
            if self.roomVM.isSpotifyLinked() {
                searchViewController.showHeaderView(!self.playlistVM.shouldUpdateSpotifyPlaylist)
            }
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
            roomVM.isSpotifyProductPremium() &&
            !roomVM.isTokenExpired()
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
        playlistVM.selectedPlaylistItem = playlistVM.playlist[indexPath.row]
        performSegue(withIdentifier: "SongInfoViewController", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard roomVM.isHost(usersVM.signedInUser()) || usersVM.signedInUser().id == playlistVM.playlist[indexPath.row].addedBy.id else { return nil }
        let action = UIContextualAction(style: .normal, title: "Remove") { (action, view, completionHandler) in
            Task {
                self.playlistVM.shouldUpdateSpotifyPlaylist = self.roomVM.isSpotifyLinked() && !self.roomVM.isTokenExpired()
                let result = await self.playlistVM.removeSong(at: indexPath.row)
                if case .failure(let error) = result {
                    self.showAlert(title: error.localizedDescription)
                    self.playlistVM.shouldUpdateSpotifyPlaylist = false
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

extension PlaylistViewController: RoomInfoViewControllerDelegate {
    
    func roomInfoViewController(_ roomInfoViewController: RoomInfoViewController, fairQueueStateDidChange isOn: Bool) {
        playlistVM.setFairQueue(isOn)
        if roomVM.isSpotifyLinked() {
            updateSpotifyPlaylist()
        }
    }
    
    func roomInfoViewController(_ roomInfoViewController: RoomInfoViewController, shouldPlaylistClear: Bool) {
        Task {
            let clearResult = await self.playlistVM.clearPlaylist()
            switch clearResult {
            case.success:
                if self.roomVM.isSpotifyLinked() && !self.roomVM.isTokenExpired() {
                    self.playlistVM.playlist = []
                    let updateResult = await self.playlistVM.updateSpotifyPlaylist()
                    if case .failure(let error) = updateResult {
                        roomInfoViewController.showAlert(title: error.localizedDescription)
                    }
                }
            case .failure(let error):
                roomInfoViewController.showAlert(title: error.localizedDescription)
            }
        }
    }
}
