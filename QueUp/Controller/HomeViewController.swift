//
//  HomeViewController.swift
//  QueUp
//
//  Created by Louis Menacho on 4/24/22.
//

import UIKit

class HomeViewController: UIViewController {

    var vm = HomeViewModel()
    
    @IBOutlet weak var formView: HomeFormView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        formView.setRoomId(vm.roomId)
        formView.setDisplayName(vm.displayName)
        if vm.roomId == formView.roomIdTextField.text {
            formView.joinButton.setTitle("REJOIN", for: .normal)
        } else {
            formView.joinButton.setTitle("JOIN", for: .normal)
        }
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
    
    func homeFormView(_ homeFormView: HomeFormView, roomIdTextFieldDidChange text: String) {
        if vm.roomId == text {
            formView.joinButton.setTitle("REJOIN", for: .normal)
        } else {
            formView.joinButton.setTitle("JOIN", for: .normal)
        }
    }
}
