//
//  PlaylistTableViewCell.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import UIKit
import SDWebImage

class PlaylistTableViewCell: UITableViewCell {

    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNamesLabel: UILabel!
    @IBOutlet weak var addedByUserLabel: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update(with playlistItem: PlaylistItem) {
        songTitleLabel.text = playlistItem.song.title
        artistNamesLabel.text = playlistItem.song.artists.joined(separator: ",")
        addedByUserLabel.text = "Added by " + playlistItem.addedBy.displayName
        albumImageView.sd_setImage(with: URL(string: playlistItem.song.artworkURL)!, placeholderImage: UIImage(systemName: "image"))
        playButton.isHidden = true
    }
    
    func showPlayButton() {
        playButton.isHidden = false
    }
}
