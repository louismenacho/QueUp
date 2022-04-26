//
//  HomeViewController.swift
//  QueUp
//
//  Created by Louis Menacho on 4/24/22.
//

import UIKit

class HomeViewController: UIViewController {

    let vm = HomeViewModel()
    
    @IBOutlet weak var homeFormView: HomeFormView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeFormView.delegate = self
    }
}

extension HomeViewController: HomeFormViewDelegate {
    
    func homeFormView(_ homeFormView: HomeFormView, joinButtonPressed displayName: String, roomId: String) {
        Task {
            await vm.join(roomId: roomId, displayName: displayName)
        }
    }
    
    func homeFormView(_ homeFormView: HomeFormView, hostButtonPressed displayName: String) {
        Task {
            await vm.host(displayName: displayName)
        }
    }
}
