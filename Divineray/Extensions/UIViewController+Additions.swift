//  Divineray
//
//  Created by     on 08/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import Foundation
import  UIKit

extension UIViewController {
    
    func showMessage(title: String, message: String, okButton: String, cancelButton: String, controller: UIViewController, okHandler: ((() -> Void))?, cancelHandler: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: okButton, style: UIAlertAction.Style.default) { (action) -> Void in
            if okHandler != nil {
                okHandler!() 
            }
        }
        let cancelAction = UIAlertAction(title: cancelButton, style: UIAlertAction.Style.default) {
            (action) -> Void in
            cancelHandler?()
        }
        alertController.addAction(dismissAction)
        if cancelButton != "" {
        alertController.addAction(cancelAction)
        }
        controller.present(alertController, animated: true, completion: nil)
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
    
    func showAlertWith(title: String?, message: String)  {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentWithMessage(_ errorMessage: NSString) {
        let alert = UIAlertController(title: "", message: errorMessage as String, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    func showToastMessage(_ message: String)  {
        if let topViewController = UIApplication.shared.topMostViewController() {
            Loaf(message, state: .custom(.init(backgroundColor:UIColor.appthemeColor, icon: nil, textAlignment: .center, width: .screenPercentage(0.8))), sender:  topViewController).show()
        } else {
            //UIApplication.shared.keyWindow?.rootViewController?.view.makeToast(message)
        }
    }
    func showToastSucessMessage(_ message: String)  {
           if let topViewController = UIApplication.shared.topMostViewController() {
               Loaf(message, state: .custom(.init(backgroundColor:UIColor.green, icon: nil, textAlignment: .center, width: .screenPercentage(0.8))), sender:  topViewController).show()
           } else {
               //UIApplication.shared.keyWindow?.rootViewController?.view.makeToast(message)
           }
       }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        
        if let tab = self as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            if let visibleController = navigation.visibleViewController {
                return visibleController.topMostViewController()
            } else {
                return navigation
            }
        }
        
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}


