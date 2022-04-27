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
            let result = await vm.join(roomId: roomId, displayName: displayName)
            switch result {
            case.success:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "PlaylistViewController", sender: self)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func homeFormView(_ homeFormView: HomeFormView, hostButtonPressed displayName: String) {
        Task {
            let result = await vm.host(displayName: displayName)
            switch result {
            case.success:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "PlaylistViewController", sender: self)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
