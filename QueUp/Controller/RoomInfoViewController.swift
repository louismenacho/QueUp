//
//  RoomInfoViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 11/19/21.
//

import UIKit

protocol RoomInfoViewControllerDelegate: AnyObject {
    func roomInfoViewController(_ roomInfoViewController: RoomInfoViewController, fairQueueStateDidChange isOn: Bool)
    func roomInfoViewController(_ roomInfoViewController: RoomInfoViewController, shouldPlaylistClear: Bool)
}

class RoomInfoViewController: UIViewController {
    
    weak var delegate: RoomInfoViewControllerDelegate?
    
    var roomVM = RoomViewModel()
    var playlistVM = PlaylistViewModel()

    @IBOutlet weak var roomIDLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roomIDLabel.text = roomVM.room.id
        tableView.dataSource = self
        tableView.delegate = self
        tableHeaderView.frame.size = CGSize(width: view.frame.width, height: view.frame.width/2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        roomVM.roomListener { result in
//            print("roomListener fired")
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.roomIDLabel.text = self.roomVM.room.id
                    self.tableView.reloadData()
                }
            case .failure(let error):
                if let error = error as? DecodingError, case .valueNotFound = error {
                    self.navigationController?.popToRootViewController(animated: true)
                    self.navigationController?.showAlert(title: "Room session ended")
                    self.roomVM.unsaveRoomId()
                    return
                }
                self.showAlert(title: error.localizedDescription)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        roomVM.stopListener()
    }
}

extension RoomInfoViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpotifyLinkTableViewCell", for: indexPath) as! SpotifyLinkTableViewCell
            cell.delegate = self
            cell.showLinkedStatus(isSpotifyLinked: roomVM.isSpotifyLinked(), isTokenExpired: roomVM.isTokenExpired())
            return cell
        }
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FairQueueSwitchTableViewCell", for: indexPath) as! FairQueueSwitchTableViewCell
            cell.delegate = self
            cell.fairQueueSwitch.isOn = roomVM.room.isQueueFair
            return cell
        }
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RoomInfoTableViewCell", for: indexPath)
            cell.textLabel?.text = "Clear Playlist"
            cell.textLabel?.textColor = .label
            return cell
        }
        if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RoomInfoTableViewCell", for: indexPath)
            cell.textLabel?.text = "End Room Session"
            cell.textLabel?.textColor = .red
            return cell
        }
        return UITableViewCell()
    }
}

extension RoomInfoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Create a playlist on Spotify named \"QueUp Room \(roomVM.room.id)\". Spotify Premium users can play music on demand from QueUp. (Spotify must be playing music)"
        }
        if section == 1 {
            return "When turned on, songs in playlist are arranged in fair order. Otherwise, songs are arranged in the order they were added."
        }
        if section == 2 {
            return "Remove all songs from playlist. If Spotify is linked, all songs from the \"QueUp Room \(roomVM.room.id)\" playlist will remain."
        }
        if section == 3 {
            return "Delete room \(roomVM.room.id) with all songs from playlist. If Spotify is linked, all songs from the \"QueUp Room \(roomVM.room.id)\" playlist will remain."
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            showActionSheet(title: "Are you sure you want to clear playlist?", action: .init(title: "Clear Playlist", style: .destructive) {  action in
                self.delegate?.roomInfoViewController(self, shouldPlaylistClear: true)
            })
        }
        if indexPath.section == 3 {
            showActionSheet(title: "Are you sure you want to end room session?", action: .init(title: "End Room Session", style: .destructive) {  action in
                Task {
                    let result = await self.roomVM.endRoomSession()
                    if case .failure(let error) = result {
                        self.showAlert(title: error.localizedDescription)
                    }
                }
            })
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension RoomInfoViewController: SpotifyLinkTableViewCellDelegate {
    
    func spotifyLinkTableViewCell(linkStatusButtonPressedFor cell: SpotifyLinkTableViewCell) {
        cell.linkStatusButton.isEnabled = false
        showActivityIndicator()
        if cell.linkStatusButton.titleLabel!.text == "Link" {
            Task {
                let linkResult = await roomVM.linkSpotifyAccount()
                self.hideActivityIndicator()
                switch linkResult {
                case.success(let isLinked):
                    if isLinked {
                        let updateResult = await playlistVM.updateSpotifyPlaylist()
                        if case let .failure(error) = updateResult {
                            showAlert(title: error.localizedDescription)
                        }
                        cell.linkStatusButton.isEnabled = false
                    } else {
                        cell.linkStatusButton.isEnabled = true
                    }
                case .failure(let error):
                    showAlert(title: error.localizedDescription)
                    cell.linkStatusButton.isEnabled = true
                }
            }
        }
        if cell.linkStatusButton.titleLabel!.text == "Relink" {
            Task {
                let result = await roomVM.relinkSpotifyIfNeeded()
                self.hideActivityIndicator()
                switch result {
                case.success(let isLinked):
                    if isLinked {
                        let updateResult = await playlistVM.updateSpotifyPlaylist()
                        if case let .failure(error) = updateResult {
                            showAlert(title: error.localizedDescription)
                        }
                        cell.linkStatusButton.isEnabled = false
                    } else {
                        cell.linkStatusButton.isEnabled = true
                    }
                case .failure(let error):
                    showAlert(title: error.localizedDescription)
                    cell.linkStatusButton.isEnabled = true
                }
            }
        }
    }
}

extension RoomInfoViewController: FairQueueSwitchTableViewCellDelegate {
    
    func fairQueueSwitchTableViewCell(switchStateDidChange isOn: Bool) {
        roomVM.setFairQueue(isOn)
        delegate?.roomInfoViewController(self, fairQueueStateDidChange: isOn)
    }
}
