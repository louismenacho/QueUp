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
            let user = try await vm.signIn(as: homeFormView.displayNameTextField.text!)
            try vm.createUser(user)
        }
    }
    
    func homeFormView(_ homeFormView: HomeFormView, hostButtonPressed button: UIButton) {
        Task {
            let user = try await vm.signIn(as: homeFormView.displayNameTextField.text!)
            try vm.createUser(user)
        }
    }
}
