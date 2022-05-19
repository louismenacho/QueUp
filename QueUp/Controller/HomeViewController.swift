//
//  HomeViewController.swift
//  QueUp
//
//  Created by Louis Menacho on 4/24/22.
//

import UIKit

class HomeViewController: UIViewController {

    var vm = HomeViewModel()
    
    @IBOutlet weak var appearanceSwitch: SwitchControl!
    @IBOutlet weak var formView: HomeFormView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSwitch.delegate = self
        formView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        formView.setRoomId(vm.lastRoomId)
        formView.setDisplayName(vm.displayName)
        if !vm.lastRoomId.isEmpty && vm.lastRoomId == formView.roomIdTextField.text {
            formView.joinButton.setTitle("REJOIN", for: .normal)
        } else {
            formView.joinButton.setTitle("JOIN", for: .normal)
        }
    }
}

extension HomeViewController: SwitchControlDelegate {
    func switchControl(_ switchControl: SwitchControl, didToggle isOn: Bool) {
        switchControl.setThumbImage(UIImage(systemName: isOn ? "sun.min.fill" : "moon.fill"))
        UIApplication.shared.windows.forEach { window in
            UIView.animate(withDuration: 0.3) {
                window.overrideUserInterfaceStyle = isOn ? .light : .dark
            }
        }
    }
}

extension HomeViewController: HomeFormViewDelegate {
    
    func homeFormView(_ homeFormView: HomeFormView, joinButtonPressed displayName: String, roomId: String) {
        homeFormView.joinButton.isEnabled = false
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
            homeFormView.joinButton.isEnabled = true
        }
    }
    
    func homeFormView(_ homeFormView: HomeFormView, hostButtonPressed displayName: String) {
        homeFormView.hostButton.isEnabled = false
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
            homeFormView.hostButton.isEnabled = true
        }
    }
    
    func homeFormView(_ homeFormView: HomeFormView, roomIdTextFieldDidChange text: String) {
        if vm.lastRoomId == text {
            formView.joinButton.setTitle("REJOIN", for: .normal)
        } else {
            formView.joinButton.setTitle("JOIN", for: .normal)
        }
    }
}
