//
//  UIFont.swift
//  CullintonsCustomer
//
//  Created by Nitin Kumar on 31/03/18.
//  Copyright © 2018 Nitin Kumar. All rights reserved.
//

import Foundation
import UIKit

enum FONT_NAME: String {
    case Cinzel_Black = "Cinzel-Black"
    case Cinzel_Bold = "Cinzel-Bold"
    case Cinzel_Regular = "Cinzel-Regular"
    
    case Epilogue_Black = "Epilogue-Black"
    case Epilogue_Medium = "Epilogue-Medium"
    case Epilogue_ThinItalic = "Epilogue-ThinItalic"
    case Epilogue_SemiBold = "Epilogue-SemiBold"
    case Epilogue_Regular = "Epilogue-Regular"
    case Epilogue_Bold = "Epilogue-Bold"
}


extension UIFont {
    
    static func setCustom(_ font: FONT_NAME, _ size:CGFloat) -> UIFont {
        if let font = UIFont(name: font.rawValue, size: size) {
            return font
        } else {
            return UIFont.systemFont(ofSize: size)
        }
    }
    
    convenience init?(_ font: FONT_NAME, _ size:CGFloat) {
        self.init(name: font.rawValue, size: size)
    }
    
    class func fontFamilies() {
        for familyName in UIFont.familyNames {
            print("\n-- \(familyName) \n")
            for fontName in UIFont.fontNames(forFamilyName: familyName) {
                print(fontName)
            }
        }
    }
}



extension CAGradientLayer {
    public convenience init(frame:CGRect, colours: [UIColor], locations: [NSNumber]) {
        self.init(layer:frame)
        self.frame = self.bounds
        self.colors = colours.map { $0.cgColor }
        self.locations = locations
        self.name = "gradientLayer"
        self.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.endPoint = CGPoint(x: 1.5, y: 0.5)//CGPointMake(1.0, 0.5)
    }
}


extension UIBezierPath {
    /// The Unwrap logo as a Bezier path.
    static var logo: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.534, y: 0.5816))
        path.addCurve(to: CGPoint(x: 0.1877, y: 0.088), controlPoint1: CGPoint(x: 0.534, y: 0.5816), controlPoint2: CGPoint(x: 0.2529, y: 0.4205))
        path.addCurve(to: CGPoint(x: 0.9728, y: 0.8259), controlPoint1: CGPoint(x: 0.4922, y: 0.4949), controlPoint2: CGPoint(x: 1.0968, y: 0.4148))
        path.addCurve(to: CGPoint(x: 0.0397, y: 0.5431), controlPoint1: CGPoint(x: 0.7118, y: 0.5248), controlPoint2: CGPoint(x: 0.3329, y: 0.7442))
        path.addCurve(to: CGPoint(x: 0.6211, y: 0.0279), controlPoint1: CGPoint(x: 0.508, y: 1.1956), controlPoint2: CGPoint(x: 1.3042, y: 0.5345))
        path.addCurve(to: CGPoint(x: 0.6904, y: 0.3615), controlPoint1: CGPoint(x: 0.7282, y: 0.2481), controlPoint2: CGPoint(x: 0.6904, y: 0.3615))
        return path
    }
}

