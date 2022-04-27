//
//  SearchResultTableViewCell.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNamesLabel: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        print("addButtonPressed")
    }
    
    func update(with song: Song) {
        songTitleLabel.text = song.title
        artistNamesLabel.text = song.artists.joined(separator: ",")
        albumImageView.image = UIImage(systemName: "photo.fill")
    }
}
