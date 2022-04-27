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
        songTitleLabel.text = "Song"
        artistNamesLabel.text = "Artists"
        addedByUserLabel.text = "User"
        albumImageView.image = UIImage(systemName: "photo.fill")
    }
}
