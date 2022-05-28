//
//  HomeFormView.swift
//  QueUp
//
//  Created by Louis Menacho on 4/23/22.
//

import UIKit

protocol HomeFormViewDelegate: AnyObject {
    func homeFormView(_ homeFormView: HomeFormView, joinButtonPressed displayName: String, roomId: String)
    func homeFormView(_ homeFormView: HomeFormView, hostButtonPressed displayName: String)
    func homeFormView(_ homeFormView: HomeFormView, roomIdTextFieldDidChange text: String)
}


class HomeFormView: UIStackView {

    weak var delegate: HomeFormViewDelegate?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var roomIdTextField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var hostButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        displayNameTextField.delegate = self
        roomIdTextField.delegate = self
        showJoinRoomOptions()
    }
    
    @IBAction func selectedSegmentDidChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            showJoinRoomOptions()
        } else {
            showCreateRoomOptions()
        }
    }
    
    @IBAction func displayNameTextFieldDidChange(_ sender: UITextField) {
        handleButtonEnablement()
    }
    
    @IBAction func roomIdTextFieldDidChange(_ sender: UITextField) {
        handleButtonEnablement()
        roomIdTextField.text = roomIdTextField.text!.uppercased()
        delegate?.homeFormView(self, roomIdTextFieldDidChange: roomIdTextField.text!)
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        delegate?.homeFormView(self, joinButtonPressed: displayNameTextField.text!, roomId: roomIdTextField.text!)
    }
    
    @IBAction func hostButtonPressed(_ sender: UIButton) {
        delegate?.homeFormView(self, hostButtonPressed: displayNameTextField.text!)
    }
    
    private func showJoinRoomOptions() {
        roomIdTextField.isHidden = false
        joinButton.isHidden = false
        hostButton.isHidden = true
        handleButtonEnablement()
    }
    
    private func showCreateRoomOptions() {
        roomIdTextField.isHidden = true
        joinButton.isHidden = true
        hostButton.isHidden = false
        handleButtonEnablement()
    }
    
    func handleButtonEnablement() {
        joinButton.isEnabled = !displayNameTextField.text!.isEmpty && roomIdTextField.text!.count == 4
        joinButton.alpha = joinButton.isEnabled ? 1 : 0.5
        hostButton.isEnabled = !displayNameTextField.text!.isEmpty
        hostButton.alpha = hostButton.isEnabled ? 1 : 0.5
    }
    
    func setRoomId(_ roomId: String) {
        roomIdTextField.text = roomId
    }
    
    func setDisplayName(_ displayName: String) {
        displayNameTextField.text = displayName
    }
}

extension HomeFormView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""
        
        // allow only letter characters
        if string.rangeOfCharacter(from: CharacterSet.letters.inverted) != nil {
            return false
        }
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // make sure the result is under 20 characters if display name text field
        if textField == displayNameTextField {
            return updatedText.count <= 20
        }
        
        // make sure the result is under 4 characters if room ID text field
        if textField == roomIdTextField {
            return updatedText.count <= 4
        }
        
        return true
    }
    
}
