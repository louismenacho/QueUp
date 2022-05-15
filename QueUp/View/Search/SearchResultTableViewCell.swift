//
//  SearchResultTableViewCell.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import UIKit

protocol SearchResultTableViewCellDelegate: AnyObject {
    func searchTableViewCell(addButtonPressedFor cell: SearchResultTableViewCell)
}

class SearchResultTableViewCell: UITableViewCell {
    
    weak var delegate: SearchResultTableViewCellDelegate?
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNamesLabel: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        delegate?.searchTableViewCell(addButtonPressedFor: self)
    }
    
    func update(with searchResultItem: SearchResultItem) {
        songTitleLabel.text = searchResultItem.song.title
        artistNamesLabel.text = searchResultItem.song.artists.joined(separator: ",")
        albumImageView.sd_setImage(with: URL(string: searchResultItem.song.artworkURL)!, placeholderImage: UIImage(systemName: "image"))
        if searchResultItem.isAdded {
            addButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            addButton.isUserInteractionEnabled = false
        } else {
            addButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
            addButton.isUserInteractionEnabled = true
        }
    }
}
