//
//  HomeFormView.swift
//  QueUp
//
//  Created by Louis Menacho on 4/23/22.
//

import UIKit

protocol HomeFormViewDelegate: AnyObject {
    func homeFormView(_ homeFormView: HomeFormView, joinButtonPressed button: UIButton)
    func homeFormView(_ homeFormView: HomeFormView, hostButtonPressed button: UIButton)
}


class HomeFormView: UIStackView {

    weak var delegate: HomeFormViewDelegate?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var roomCodeTextField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var hostButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        displayNameTextField.delegate = self
        roomCodeTextField.delegate = self
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
        joinButton.isEnabled = !displayNameTextField.text!.isEmpty && roomCodeTextField.text!.count == 4
        hostButton.isEnabled = !displayNameTextField.text!.isEmpty
    }
    
    @IBAction func roomCodeTextFieldDidChange(_ sender: UITextField) {
        roomCodeTextField.text = roomCodeTextField.text?.uppercased()
        joinButton.isEnabled = !displayNameTextField.text!.isEmpty && roomCodeTextField.text!.count == 4
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        delegate?.homeFormView(self, joinButtonPressed: sender)
    }
    
    @IBAction func hostButtonPressed(_ sender: UIButton) {
        delegate?.homeFormView(self, hostButtonPressed: sender)
    }
    
    private func showJoinRoomOptions() {
        roomCodeTextField.isHidden = false
        joinButton.isHidden = false
        hostButton.isHidden = true
        joinButton.isEnabled = !displayNameTextField.text!.isEmpty && roomCodeTextField.text!.count == 4
    }
    
    private func showCreateRoomOptions() {
        roomCodeTextField.isHidden = true
        joinButton.isHidden = true
        hostButton.isHidden = false
        hostButton.isEnabled = !displayNameTextField.text!.isEmpty
    }
    
    func setRoomCode(_ roomCode: String) {
        roomCodeTextField.text = roomCode
        joinButton.isEnabled = !displayNameTextField.text!.isEmpty && roomCodeTextField.text!.count == 4
    }
    
    func setDisplayName(_ displayName: String) {
        displayNameTextField.text = displayName
        joinButton.isEnabled = !displayNameTextField.text!.isEmpty && roomCodeTextField.text!.count == 4
        hostButton.isEnabled = !displayNameTextField.text!.isEmpty
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
        if textField == roomCodeTextField {
            return updatedText.count <= 4
        }
        
        return true
    }
    
}
