//
//  HomeFormTextField.swift
//  TurnTune
//
//  Created by Louis Menacho on 1/3/22.
//

import UIKit

class HomeFormTextField: UITextField {

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height/2
        layer.borderWidth = 2
        layer.borderColor = UIColor.secondarySystemBackground.cgColor
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: .init(top: 0, left: 20, bottom: 0, right: 35))
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: .init(top: 0, left: 20, bottom: 0, right: 35))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: .init(top: 0, left: 20, bottom: 0, right: 35))
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: .init(top: 0, left: 185, bottom: 0, right: 0))
    }

}
