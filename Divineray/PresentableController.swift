//
//  PresentableController.swift
//  Divineray
//
//  Created by apple on 26/05/22.
//  Copyright © 2022 Dharmani Apps. All rights reserved.
//

import UIKit

class PresentableController: UIViewController {
    
    var transitionHeight: CGFloat = 150
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        self.modalPresentationStyle = .overFullScreen
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.modalPresentationStyle = .overFullScreen
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
    }
    
    @objc func handleDismiss(sender : UIPanGestureRecognizer){
        let transfromY = sender.translation(in: view).y
        switch sender.state {
        case .changed:
            if transfromY > 0 {
                self.view.transform = CGAffineTransform(translationX: 0, y: transfromY)
            } else {
                self.view.transform = .identity
            }
        case .ended:
            if transfromY < transitionHeight {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
}

