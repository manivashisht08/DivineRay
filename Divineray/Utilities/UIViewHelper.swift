//
//  UIViewHelper.swift
//  NibSetup
//
//  Created by Neo on 31/05/2018.
//  Copyright © 2018 STH. All rights reserved.
//

import Foundation
import UIKit

protocol NibInstantiable {}

extension UIView: NibInstantiable {}

extension NibInstantiable where Self: UIView {
    static func instantiateFromNib() -> Self {
        if let view = Bundle(for: self).loadNibNamed(String(describing: self), owner: nil, options: nil)?[0] as? Self {
            return view
        } else {
            assert(false, "The nib named \(self) is not found")
            return Self()
        }
    }
}
func showAlertMessage(title: String, message: String, okButton: String, controller: UIViewController, okHandler: (() -> Void)?){
    DispatchQueue.main.async {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let dismissAction = UIAlertAction(title: okButton, style: UIAlertAction.Style.default) { (action) -> Void in
            if okHandler != nil {
                okHandler!()
            }
        }
        alertController.addAction(dismissAction)
       // UIApplication.shared.windows[0].rootViewController?.present(alertController, animated: true, completion: nil)
        controller.present(alertController, animated: true, completion: nil)
    }
 
}
/*
 lazy var socialToolsView: SocialToolsView = {
     let toolView: SocialToolsView = SocialToolsView.instantiateFromNib()
     toolView.translatesAutoresizingMaskIntoConstraints = false
     self.view.addSubview(toolView)
     return toolView
 }()
 
 func setupConstraints() {
     NSLayoutConstraint.activate([
         imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
         imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
         imageView.widthAnchor.constraint(equalToConstant: 150),
         imageView.heightAnchor.constraint(equalToConstant: 200),

         socialToolsView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 25),
         socialToolsView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor, constant: 0),
         socialToolsView.widthAnchor.constraint(equalToConstant: 200),
         socialToolsView.heightAnchor.constraint(equalToConstant: 45)
         ])
 }
 */
