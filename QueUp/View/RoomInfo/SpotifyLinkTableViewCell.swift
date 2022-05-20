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
        selectionStyle = .none
    }
    
    @IBAction func linkStatusButtonPressed(_ sender: UIButton) {
        delegate?.spotifyLinkTableViewCell(linkStatusButtonPressedFor: self)
    }
    
    
    func showLinkedStatus(isSpotifyLinked: Bool, isTokenExpired: Bool) {
        if isSpotifyLinked && !isTokenExpired {
            linkStatusButton.setTitle("Linked", for: .normal)
            linkStatusButton.isEnabled = false
        }
        if isSpotifyLinked && isTokenExpired {
            linkStatusButton.setTitle("Relink", for: .normal)
            linkStatusButton.isEnabled = true
        }
        if !isSpotifyLinked {
            linkStatusButton.setTitle("Link", for: .normal)
            linkStatusButton.isEnabled = true
        }
    }
}
