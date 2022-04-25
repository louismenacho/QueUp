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
    
    func homeFormView(_ homeFormView: HomeFormView, joinButtonPressed button: UIButton) {
        Task {
            let firebaseAuthUser = try await vm.firebaseSignIn()
            _ = try vm.createUser(firebaseAuthUser, displayName: homeFormView.displayNameTextField.text!)
        }
    }
    
    func homeFormView(_ homeFormView: HomeFormView, hostButtonPressed button: UIButton) {
        Task {
            let firebaseAuthUser = try await vm.firebaseSignIn()
            let user = try vm.createUser(firebaseAuthUser, displayName: homeFormView.displayNameTextField.text!)
            _ = try await vm.createRoom(host: user)
        }
    }
}
