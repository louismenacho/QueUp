//
//  RoomInfoViewController.swift
//  TurnTune
//
//  Created by Louis Menacho on 11/19/21.
//

import UIKit

class RoomInfoViewController: UIViewController {
    
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
            print("roomListener fired")
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.roomIDLabel.text = self.roomVM.room.id
                    self.tableView.reloadData()
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        roomVM.stopListener()
    }
}

extension RoomInfoViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpotifyLinkTableViewCell", for: indexPath) as! SpotifyLinkTableViewCell
            cell.delegate = self
            cell.update(with: roomVM.room)
            return cell
        }
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RoomInfoTableViewCell", for: indexPath)
            cell.textLabel?.text = "Reset Playlist"
            cell.textLabel?.textColor = .label
            return cell
        }
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RoomInfoTableViewCell", for: indexPath)
            cell.textLabel?.text = "End Room Session"
            cell.textLabel?.textColor = .red
            return cell
        }
        return UITableViewCell()
    }
}

extension RoomInfoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            Task {
                let result = await roomVM.clearPlaylist()
                switch result {
                case.success:
                    print("cleared playlist")
                case .failure(let error):
                    print(error)
                }
            }
        }
        if indexPath.row == 2 {
            Task {
                let result = await roomVM.closeRoom()
                switch result {
                case.success:
                    print("closed room")
                case .failure(let error):
                    print(error)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension RoomInfoViewController: SpotifyLinkTableViewCellDelegate {
    
    func spotifyLinkTableViewCell(linkStatusButtonPressedFor cell: SpotifyLinkTableViewCell) {
        Task {
            let result = await roomVM.linkSpotifyAccount()
            switch result {
            case.success:
                print("linked Spotify account")
            case .failure(let error):
                print(error)
            }
        }
    }
}
