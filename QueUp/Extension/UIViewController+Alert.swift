//
//  UIViewController+Alert.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/5/22.
//

import UIKit

extension UIViewController {

    func showAlert(title : String, subtitle : String? = nil) {
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func showActionSheet(title : String, subtitle : String? = nil, action: UIAlertAction) {
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .actionSheet)
        alert.addAction(action)
        self.present(alert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissAlertController() {
        dismiss(animated: true)
    }
}
 
