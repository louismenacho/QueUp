//
//  SongInfoViewController.swift
//  QueUp
//
//  Created by Louis Menacho on 5/10/22.
//

import UIKit

class SongInfoViewController: UIViewController {
    
    var vm = SongInfoViewModel()

    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumImageView.image = UIImage(systemName: "photo.fill")
        albumLabel.text = vm.song.album
        titleLabel.text = vm.song.title
        vm.song.artists.forEach {
            if artistStackView.subviews.count > 8 { return }
            let label = UILabel()
            label.text = $0
            label.textColor = .secondaryLabel
            label.font = UIFont(name: "Avenir Next Medium", size: 17)
            label.textAlignment = .left
            artistStackView.addArrangedSubview(label)
        }
    }
}
