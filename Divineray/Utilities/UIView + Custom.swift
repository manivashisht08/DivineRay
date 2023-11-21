//
//  UIView + Custom.swift
//  Divineray
//
//  Created by dr mac on 09/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
extension UIView {
    // for corner radius
    @IBInspectable var isRounded: Bool {
        set  {
            if newValue {
                self.layer.cornerRadius = (self.frame.height/2)
                self.clipsToBounds = true
            }
        } get {
            return self.layer.cornerRadius == 0
        }
    }
    
    
    func setHeight(_ h:CGFloat, animateTime:TimeInterval?=nil) {

        if let c = self.constraints.first(where: { $0.firstAttribute == .height && $0.relation == .equal }) {
            c.constant = CGFloat(h)

            if let animateTime = animateTime {
                UIView.animate(withDuration: animateTime, animations:{
                    self.superview?.layoutIfNeeded()
                })
            }  else {
                self.superview?.layoutIfNeeded()
            }
        }
    }
    
    
    func addTarget(target: Any?, action: Selector?) {
        let gesture = UITapGestureRecognizer(target: target, action: action)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(gesture)
    }
    
    func makeSlide() {
        let frame = self.bounds
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 20))
        path.addLine(to: CGPoint(x: frame.width, y: 0))
        
        path.close()
        path.fill()
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        
    }
    
    func addDashedBorder(_ color:UIColor, size:CGSize) {
        let color = color.cgColor
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        shapeLayer.bounds = frameSize
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [5,5]
        shapeLayer.path = UIBezierPath(roundedRect: frameSize, cornerRadius: 5).cgPath
        self.layer.addSublayer(shapeLayer)
        self.setNeedsLayout()
    }
    
    
//    var safeAreaInsetsForAllOS: UIEdgeInsets {
//        var insets: UIEdgeInsets
//        if #available(iOS 11.0, *) {
//            insets = safeAreaInsets
//        } else {
//            insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        }
//        return insets
//    }
    
    func setShadow(upside:Bool = true) {
        setShadowBounds(upside: upside)
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
    }
    
    func setViewBorder(borderWidth:CGFloat, background: UIColor, borderColor: UIColor) {
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.backgroundColor = background
    }
    
    
    func setView(borderWidth:CGFloat, background:UIColor, outerColor:UIColor = UIColor.white) {
        self.borderColor = outerColor
        self.borderWidth = borderWidth
        self.backgroundColor = background
        self.addShadow()
    }
    
    func addShadow(color:UIColor = UIColor.black.withAlphaComponent(0.5), opticity:Float = 1.0) {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 5
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = opticity
    }
    
    func tabbarShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: -3)
        self.layer.shadowRadius = 5
    }
    
    func setShadowBounds(upside:Bool) {
        if upside == true {
            self.layer.shadowOffset = CGSize(width: -6, height: -8)
        } else {
            self.layer.shadowOffset = CGSize(width: 6, height: 8)
        }
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 6
        self.clipsToBounds = false
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat, width: CGFloat, height: CGFloat) {
        let path = UIBezierPath(roundedRect: CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: width, height: height), byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        DispatchQueue.main.async {
            let gradient:CAGradientLayer = CAGradientLayer()
            gradient.frame = self.bounds
            gradient.colors = colours.map { $0.cgColor }
            gradient.locations = locations
            gradient.name = "gradientLayer"
            //        gradient.startPoint = CGPoint(x: 0.0, y: 0.5) // CGPointMake(0.0, 0.5)
            //        gradient.endPoint = CGPoint(x: 1.0, y: 0.5) //CGPointMake(1.0, 0.5)
            self.layer.insertSublayer(gradient, at: 0)
            self.clipsToBounds = true
        }
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1) {
      layer.masksToBounds = false
      layer.shadowColor = color.cgColor
      layer.shadowOpacity = opacity
      layer.shadowOffset = offSet
      layer.shadowRadius = radius
    }
    
    
    func removeGradient() {
        guard let layers = self.layer.sublayers else {
            return
        }
        for subLayer in layers {
            if subLayer.name == "gradientLayer" {
                subLayer.removeFromSuperlayer()
            }
        }
    }
    
    func setBorder(_ color:UIColor, corner radius:CGFloat, _ width:CGFloat) {
        self.borderColor = color
        self.cornerRadius = radius
        self.borderWidth = width
        self.clipsToBounds = true
    }
    
    func applyGradientOnBorder(colours: [CGColor], locations: [NSNumber]?) {
        self.borderColor = UIColor.clear
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: self.frame.size)
        gradient.colors = colours
        self.layer.cornerRadius = self.frame.height / 2
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)// CGPointMake(0.0, 0.5)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.5)//CGPointMake(1.0, 0.5)
        gradient.name = "gradientLayer"
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        // shape.path = UIBezierPath(rect: self.bounds).cgPath
        shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: (self.frame.height/2)).cgPath
        shape.strokeColor = UIColor.white.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        self.layer.addSublayer(gradient)
        print(self.frame.size)
    }
    
    func applyGradientOnBorderView(colours: [CGColor], locations: [NSNumber]?) {
        self.borderColor = UIColor.clear
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: self.frame.size)
        gradient.colors = colours
        self.layer.cornerRadius = self.frame.height / 2
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)// CGPointMake(0.0, 0.5)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.5)//CGPointMake(1.0, 0.5)
        gradient.name = "gradientLayer"
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        // shape.path = UIBezierPath(rect: self.bounds).cgPath
        shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: (self.frame.height/2)).cgPath
        shape.strokeColor = UIColor.white.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        self.layer.addSublayer(gradient)
        print(self.frame.size)
    }
    
    func applyGradientLeftToRight(colours: [UIColor], locations: [NSNumber]?) -> Void {
        DispatchQueue.main.async {
            let gradient:CAGradientLayer = CAGradientLayer()
            gradient.frame = self.bounds
            gradient.colors = colours.map { $0.cgColor }
            gradient.locations = locations
            gradient.name = "gradientLayer"
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)// CGPointMake(0.0, 0.5)
            gradient.endPoint = CGPoint(x: 1.5, y: 0.5)//CGPointMake(1.0, 0.5)
            self.layer.insertSublayer(gradient, at: 0)
        }
    }
    
    func animateSping() {
        self.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        })
    }
    
    func dissmissPopup(complitionHandler: @escaping(_ complitionHandler:Bool) -> (Void)) {
        UIView.animate(withDuration: 0.35) {
            self.transform = CGAffineTransform(scaleX: 0.02, y: 0.02)
            complitionHandler(true)
        }
    }
    
    func setCornerRadius(topLeft:CGFloat, topRight:CGFloat, bottomLeft:CGFloat, bottomRight:CGFloat) {
        self.roundCorners(corners: [.topLeft], radius: topLeft, width: self.frame.width, height: self.frame.height)
        self.roundCorners(corners: [.topRight], radius: topRight, width: self.frame.width, height: self.frame.height)
        self.roundCorners(corners: [.bottomLeft], radius: bottomLeft, width: self.frame.width, height: self.frame.height)
        self.roundCorners(corners: [.bottomRight], radius: bottomRight, width: self.frame.width, height: self.frame.height)
    }
    
    // for corner radius
//    @IBInspectable var cornerRadius: CGFloat
//        {
//        set (radius) {
//            self.layer.cornerRadius = radius
//            self.clipsToBounds = radius > 0
//        }
//        get {
//            return self.layer.cornerRadius
//        }
//    }
    
    //-----------round bottom corners---
    @IBInspectable var topCornerRadius:CGFloat{
        set(radius){
            self.clipsToBounds = true
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        get{
            return self.layer.cornerRadius
        }
    }
    
    //-----------round bottom corners---
    @IBInspectable var bottomCornerRadius:CGFloat{
        set(radius){
            self.clipsToBounds = true
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
        get{
            return self.layer.cornerRadius
        }
    }
    //-----------round left corners---
    @IBInspectable var leftCornerRadius:CGFloat{
        set(radius){
            self.clipsToBounds = radius > 0
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        }
        get{
            return self.layer.cornerRadius
        }
    }
    //-----------round right corners---
    @IBInspectable var rightCornerRadius:CGFloat{
        set(radius){
            self.clipsToBounds = radius > 0
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
        
        get{
            return self.layer.cornerRadius
        }
    }
    
    // for border width
//    @IBInspectable var borderWidth: CGFloat {
//        set (borderWidth) {
//            self.layer.borderWidth = borderWidth
//        } get {
//            return self.layer.borderWidth
//        }
//    }
    
    // for border Color
//    @IBInspectable var borderColor:UIColor? {
//        set (color) {
//            self.layer.borderColor = color?.cgColor
//        } get {
//            if let color = self.layer.borderColor  {
//                return UIColor(cgColor: color)
//            } else {
//                return nil
//            }
//        }
//    }
    
    
    

    // shadow Radius
    @IBInspectable var shadowRadius: CGFloat
        {
        set (radius) {
            self.layer.shadowRadius = radius
            guard self.layer.cornerRadius > 0 else {
                return}
            self.layer.masksToBounds = false
        }
        get {
            return self.layer.shadowRadius
        }
    }
    
    // shadow optacity
    @IBInspectable var shadowOptacity: Float
        {
        set (opticity) {
            self.layer.shadowOpacity = opticity
        }
        get {
            return self.layer.shadowOpacity
        }
    }
    
    //  for shadow color
    @IBInspectable var shadowColorr:UIColor?
        {
        set (color) {
            self.layer.shadowColor = color?.cgColor
        }
        get {
            if let color = self.layer.shadowColor
            {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
    }
    
    @IBInspectable var shadowOffsett: CGSize {
        set (offSet) {
            self.layer.shadowOffset = offSet
        }
        get {
            return self.layer.shadowOffset
        }
    }
    
    @IBInspectable var rightRadius: CGFloat {
        set (radius) {
            self.roundCorners(corners: [.bottomRight,.topRight], radius: radius, width: self.frame.width, height: self.frame.height)
            self.clipsToBounds = true
        }
        get {
            return self.cornerRadius
        }
    }
    
    
    @IBInspectable var topRadius: CGFloat {
        set (radius) {
            self.roundCorners(corners: [.topRight,.topLeft], radius: radius, width: self.frame.width, height: self.frame.height)
            self.clipsToBounds = true
        }
        get {
            return self.cornerRadius
        }
    }
    
    @IBInspectable var bottomRadius: CGFloat {
        set (radius) {
            self.roundCorners(corners: [.bottomRight,.bottomLeft], radius: radius, width: self.frame.width, height: self.frame.height)
            self.clipsToBounds = true
        }
        get {
            return self.cornerRadius
        }
    }
    
    @IBInspectable var leftRadius: CGFloat {
        set (radius) {
            self.roundCorners(corners: [.topLeft,.bottomLeft], radius: radius, width: self.frame.width, height: self.frame.height)
            self.clipsToBounds = true
        }
        get {
            return self.cornerRadius
        }
    }
    
    //    @IBInspectable public var topLeftRadius: CGFloat
    //        {
    //        set (radius) {
    //            self.roundCorners(corners: [.topLeft], radius: radius, width: self.frame.width, height: self.frame.height)
    //        }
    //        get {
    //            return self.layer.cornerRadius
    //        }
    //    }
    //
    //    @IBInspectable public var topRightRadius: CGFloat
    //        {
    //        set (radius) {
    //            self.roundCorners(corners: [.topRight], radius: radius, width: self.frame.width, height: self.frame.height)
    //        }
    //        get {
    //            return self.layer.cornerRadius
    //        }
    //    }
    //
    //    @IBInspectable public var bottonLeftRadius: CGFloat
    //        {
    //        set (radius) {
    //            self.roundCorners(corners: [.bottomLeft], radius: radius, width: self.frame.width, height: self.frame.height)
    //        }
    //        get {
    //            return self.layer.cornerRadius
    //        }
    //    }
    //
    //    @IBInspectable public var bottomRightRadius: CGFloat
    //        {
    //        set (radius) {
    //            self.roundCorners(corners: [.bottomRight], radius: radius, width: self.frame.width, height: self.frame.height)
    //        }
    //        get {
    //            return self.layer.cornerRadius
    //        }
    //    }
    //
    
    
    
//    func copyView<T: UIView>() -> T? {
//        return NSKeyedUnarchiver.classForKeyedUnarchiver()  as? T
//        unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
//    }
    
    var takeScreenshot: UIImage? {
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
        
//        if let img = image {
//            return img
//        }
        
    }
    
    func removeSubviews() {
        self.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
    
    func getImageView(frame:CGRect) -> UIImageView {
        let imageView = UIImageView(frame: frame)
        imageView.image = self.takeScreenshot
        return imageView
    }

    
}

extension UIView {


    class func header(size:CGSize, title:String?, textColor:UIColor = .placeholderColor) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: size.width-30, height: size.height))
        label.setLabel(title, textColor, .Cinzel_Regular, 16)
        label.backgroundColor = .white
        view.backgroundColor = .white
        view.addSubview(label)
        return view
    }

    func addLine(position : LINE_POSITION, color: UIColor, width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        self.addSubview(lineView)

        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))

        switch position {
        case .top:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        case .bottom:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
//        case .center:
//            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
//            break
        }
//        return lineView

    }

    func addCenterLine(color:UIColor) {
        let y = self.frame.height/2
        let view = UIView(frame: CGRect(x: 0, y: y, width: self.frame.width, height: 1))
        view.backgroundColor = color
        self.addSubview(view)
    }



//    func addActivityIndigator(isRounded:Bool = false, color: UIColor? = nil, indigatorColor:UIColor? = nil) {
//        removeActivityIndigator()
//
//        let indigator = UIActivityIndicatorView(style: .gray)
//        if let color = color {
//            indigator.backgroundColor = color
//        } else {
//            indigator.backgroundColor = .white
//        }
//        if let indigatorColor = indigatorColor {
//            indigator.color = indigatorColor
//        }
//        indigator.restorationIdentifier = "activity"
//        indigator.tag = 90909090
//        indigator.startAnimating()
//        indigator.frame = self.bounds
//        if isRounded {
//            indigator.cornerRadius = indigator.frame.size.height/2
//        }
//        self.addSubview(indigator)
//    }

//    func removeActivityIndigator() {
//        self.subviews.forEach { v in
//            if let v = v as? UIActivityIndicatorView {
//                v.stopAnimating()
//                v.removeFromSuperview()
//            }
//        }
//    }

}


enum LINE_POSITION {
    case top
    case bottom
//    case center
}


extension UINib {
    var instantiate: [Any] {
        return self.instantiate(withOwner: nil, options: nil)
    }
    
    var instantiateView: UIView? {
        return self.instantiate(withOwner: nil, options: nil).first as? UIView
    }
    
    class func instantiateVieww(with name:String) -> UIView? {
        return UINib(nibName: name, bundle: nil).instantiateView
    }
    
    
}


extension UIView {

  // OUTPUT 1
  func dropShadow() {
      
    layer.cornerRadius = 20
    clipsToBounds = true
    borderColor = .blue
    borderWidth = 0.7
    
    layer.masksToBounds = false
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.2
    layer.shadowOffset = CGSize(width: 0, height: 0)
    layer.shadowRadius = 20
      
//    layer.shadowPath = UIBezierPath(rect: bounds).cgPath
//    layer.shouldRasterize = true
//    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }

  // OUTPUT 2
  func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = color.cgColor
    layer.shadowOpacity = opacity
    layer.shadowOffset = offSet
    layer.shadowRadius = radius

    layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }
}


class BorderShadowView: UIView {

    private var shadowLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            
            shadowLayer.shadowColor = UIColor.darkGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            shadowLayer.shadowOpacity = 0.4
            shadowLayer.shadowRadius = 20
            
            layer.insertSublayer(shadowLayer, at: 0)
            //layer.insertSublayer(shadowLayer, below: nil) // also works
        }
    }

}

extension UIResponder {
    
    func getParentViewController() -> UIViewController? {
        if let vc = self.next as? UIViewController {
            return vc
        } else {
            if self.next != nil {
                return self.next?.getParentViewController()
            } else {
                return nil
            }
        }
    }
}
