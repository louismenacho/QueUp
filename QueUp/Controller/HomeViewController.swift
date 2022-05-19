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
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var formView: HomeFormView!
    
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addKeyboardObserver()
        appearanceSwitch.delegate = self
        formView.delegate = self
        appearanceSwitch.setOn(traitCollection.userInterfaceStyle == .light ? true : false)
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
    
    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            UIView.animate(withDuration: 0.1) { [self] in
                headerView.alpha = 0
                headerView.isHidden = true
                let viewHeight = view.frame.height
                let keyboardHeight = keyboardRect.height
                let remainingSpace = viewHeight - keyboardHeight
                headerViewTopConstraint.constant = remainingSpace/2 - formView.frame.height/2 - 48
                view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.1) { [self] in
            headerView.alpha = 1
            headerView.isHidden = false
            headerViewTopConstraint.constant = 0
            view.layoutIfNeeded()
        }
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        print("viewTapped")
        view.endEditing(true)
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
