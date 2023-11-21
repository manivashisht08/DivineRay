//
//  UITextField+Extension.swift
//  Divineray
//
//  Created by     on 08/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit.UITextField

extension UITextField {
    func validatedText(validationType: ValidatorType) throws -> String {
        let validator = VaildatorFactory.validatorFor(type: validationType)
        return try validator.validated(self.text!)
    }
}

extension String {
    func validatedText(validationType: ValidatorType) throws -> String {
        let validator = VaildatorFactory.validatorFor(type: validationType)
        return try validator.validated(self)
    }
    
    func validatePasswords(password:String, confirmPassword:String) throws -> String {
        
        if (confirmPassword.isEmpty || confirmPassword != password) {
            throw ValidationError("Password didn't match" )
        }
        return confirmPassword
    }
    
}
extension UITextField {
       @IBInspectable var placeholderColor: UIColor {
           get {
               return attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? .clear
           }
           set {
               guard let attributedPlaceholder = attributedPlaceholder else { return }
            let attributes: [NSAttributedString.Key: UIColor] = [.foregroundColor: newValue]
               self.attributedPlaceholder = NSAttributedString(string: attributedPlaceholder.string, attributes: attributes)
           }
       }
    
    func updatePlaceHolderColor () {
        if let placeholder = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(string:placeholder,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
    }
   }

extension UITextField {
    func setUnderLine() {
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  UIScreen.main.bounds.size.width-20, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        self.setNeedsDisplay()
        self.setNeedsLayout()
    }
}


