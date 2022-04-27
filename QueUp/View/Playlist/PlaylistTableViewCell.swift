//
//  PlaylistTableViewCell.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {

    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNamesLabel: UILabel!
    @IBOutlet weak var addedByUserLabel: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update(with playlistItem: PlaylistItem) {
        songTitleLabel.text = playlistItem.song.title
        artistNamesLabel.text = playlistItem.song.artists.joined(separator: ",")
        addedByUserLabel.text = "Added by " + playlistItem.addedBy.displayName
        albumImageView.image = UIImage(systemName: "photo.fill")
    }
}
