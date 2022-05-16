//
//  UserCollectionViewCell.swift
//  QueUp
//
//  Created by Louis Menacho on 5/10/22.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var circleImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    
    func update(with user: User) {
        if let firstInitial = user.displayName.first?.lowercased() {
            imageView.image = UIImage(systemName: "\(firstInitial).circle.fill")
        } else {
            imageView.image = UIImage(systemName: "questionmark.circle.fill")
        }
        displayNameLabel.text = user.displayName
        circleImageView.isHidden = true
    }
    
    func showCircleBorder() {
        circleImageView.isHidden = false
    }
}
