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
    
    @IBOutlet weak var stackViewCenterConstraint: NSLayoutConstraint!
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlaylistViewController" {
            let vc = segue.destination as! PlaylistViewController
            vc.roomVM.room = vm.room
        }
        if segue.identifier == "PolicyViewController" {
            
        }
    }
    
    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRect.height
            let remainingSpace = self.view.frame.height - keyboardHeight
            let window = UIApplication.shared.windows.filter( { $0.isKeyWindow }).first
            let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
            self.stackViewCenterConstraint.constant = -(remainingSpace - (statusBarHeight + navigationBarHeight))/2 + (statusBarHeight + navigationBarHeight) - 83.5
            UIView.animate(withDuration: 0.1) {
                self.headerView.alpha = 0
                self.headerView.isHidden = true
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        stackViewCenterConstraint.constant = 0
        UIView.animate(withDuration: 0.1) {
            self.headerView.alpha = 1
            self.headerView.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func privacyButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "PolicyViewController", sender: self)
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
        showActivityIndicator()
        homeFormView.joinButton.isEnabled = false
        Task {
            let result = await vm.join(roomId: roomId, displayName: displayName)
            self.hideActivityIndicator()
            switch result {
            case.success:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "PlaylistViewController", sender: self)
                }
            case .failure(let error):
                showAlert(title: error.localizedDescription)
            }
            homeFormView.joinButton.isEnabled = true
        }
    }
    
    func homeFormView(_ homeFormView: HomeFormView, hostButtonPressed displayName: String) {
        showActivityIndicator()
        homeFormView.hostButton.isEnabled = false
        Task {
            let result = await vm.host(displayName: displayName)
            self.hideActivityIndicator()
            switch result {
            case.success:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "PlaylistViewController", sender: self)
                }
            case .failure(let error):
                showAlert(title: error.localizedDescription)
            }
            homeFormView.hostButton.isEnabled = true
        }
    }
    
    func homeFormView(_ homeFormView: HomeFormView, roomIdTextFieldDidChange text: String) {
        if !vm.lastRoomId.isEmpty && vm.lastRoomId == formView.roomIdTextField.text {
            formView.joinButton.setTitle("REJOIN", for: .normal)
        } else {
            formView.joinButton.setTitle("JOIN", for: .normal)
        }
    }
}
