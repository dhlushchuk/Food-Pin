//
//  RoundedTextField.swift
//  Food Pin
//
//  Created by Dzmitry Hlushchuk on 22.07.24.
//

import UIKit

class RoundedTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGray5.cgColor
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }

}
