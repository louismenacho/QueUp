//
//  SpotifyLinkTableViewCell.swift
//  QueUp
//
//  Created by Louis Menacho on 5/14/22.
//

import UIKit

protocol SpotifyLinkTableViewCellDelegate: AnyObject {
    func spotifyLinkTableViewCell(linkStatusButtonPressedFor cell: SpotifyLinkTableViewCell)
}

class SpotifyLinkTableViewCell: UITableViewCell {
    
    weak var delegate: SpotifyLinkTableViewCellDelegate?

    @IBOutlet weak var linkStatusButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func linkStatusButtonPressed(_ sender: UIButton) {
        delegate?.spotifyLinkTableViewCell(linkStatusButtonPressedFor: self)
    }
    
    func update(with room: Room) {
        if room.spotifyPlaylistId.isEmpty {
            linkStatusButton.setTitle("Link", for: .normal)
        } else {
            linkStatusButton.setTitle("Unlink", for: .normal)
        }
    }
}
