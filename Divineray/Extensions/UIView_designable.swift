//
//  DesignableImageView.swift
///  Divineray
//
//  Created by     on 08/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit

@IBDesignable class DesignableImageView: UIImageView {
    
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get { return layer.borderColor.flatMap { UIColor(cgColor: $0) } }
        set { layer.borderColor = newValue?.cgColor }
    }
}

extension CGRect {
    func shifted(by x: CGFloat) -> CGRect {
        var newRect = self
        newRect.origin.x += x
        return newRect
    }
}

@IBDesignable
class DesignableTextField: UITextField {
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.shifted(by: 16.0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.shifted(by: 16.0)
    }
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.shifted(by: 16.0)
    }
}


@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}
    
    override public class var layerClass: AnyClass { CAGradientLayer.self }
    
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
    
    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}

open class GradientImageView: UIImageView {

    @objc public  init() {
        super.init(frame: CGRect.init())
        classInitialize()
      }

    @objc public required init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)
           classInitialize()
       }
    
    private  func classInitialize() {
        self.image = FandomGradient.gradientImage()
        
    }
}

