//
//  KeyboardVM.swift
//  fit
//
//  Created by Nitin Kumar on 15/05/21.
//

import UIKit


protocol KeyboardVMObserver: NSObjectProtocol {
    func keyboard(didChange height: CGFloat, duration: Double, animation: UIView.AnimationOptions)
}

class KeyboardVM {
    weak var keyboardObserver: KeyboardVMObserver?
    
    public func setKeyboardNotification(_ keyboardObserver: KeyboardVMObserver?) {
        self.keyboardObserver = keyboardObserver
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidChangeFrame(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }
    
    public func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        keyboardObserver = nil
    }
    
    @objc func keyboardWillShow(_ notification : Foundation.Notification) {
        DispatchQueue.main.async {
            var duration = 0.3
            var animation = UIView.AnimationOptions.curveLinear
            if let value  = (notification as NSNotification).userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                duration = value
            }
            if let value = (notification as NSNotification).userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
                animation = UIView.AnimationOptions(rawValue: value)
            }
            let value: NSValue = (notification as NSNotification).userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
            let height = value.cgRectValue.height
            let barHight = HEIGHT.getBottomInsetofSafeArea
            self.keyboardObserver?.keyboard(didChange: height-barHight, duration: duration, animation: animation)
        }
    }
    
    @objc func keyboardDidChangeFrame(_ notification : Foundation.Notification) {
        DispatchQueue.main.async {
            var duration = 0.3
            var animation = UIView.AnimationOptions.curveLinear
            if let value  = (notification as NSNotification).userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                duration = value
            }
            if let value = (notification as NSNotification).userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
                animation = UIView.AnimationOptions(rawValue: value)
            }
            let value: NSValue = (notification as NSNotification).userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
            let height = value.cgRectValue.height
            let barHight = HEIGHT.getBottomInsetofSafeArea
            self.keyboardObserver?.keyboard(didChange: height-barHight, duration: duration, animation: animation)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Foundation.Notification) {
        DispatchQueue.main.async {
            var duration = 0.3
            var animation = UIView.AnimationOptions.curveLinear
            if let value  = (notification as NSNotification).userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                duration = value
            }
            if let value = (notification as NSNotification).userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
                animation = UIView.AnimationOptions(rawValue: value)
            }
            self.keyboardObserver?.keyboard(didChange: 0, duration: duration, animation: animation)
        }
    }
    
}

struct HEIGHT {
    
    static let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow})
    
    static var statusBarHeight: CGFloat {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let window = HEIGHT.window
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        return statusBarHeight
    }
    static let errorMessageHeight: CGFloat = 43.0
    
    static let navigationHeight: CGFloat = 190 + Self.getTopInsetofSafeArea + Self.statusBarHeight
    
    static var getTopInsetofSafeArea: CGFloat {
        guard let topInset = Self.window?.safeAreaInsetsForAllOS.top else { return 0 }
        return topInset
    }
    
    static var getBottomInsetofSafeArea: CGFloat {
        let topInset = Self.window?.safeAreaInsetsForAllOS.bottom ?? 0
        return topInset
    }
    
}

@IBDesignable
extension UIView {
    var safeAreaInsetsForAllOS: UIEdgeInsets {
        var insets: UIEdgeInsets
        if #available(iOS 11.0, *) {
            insets = safeAreaInsets
        } else {
            insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return insets
    }
}
