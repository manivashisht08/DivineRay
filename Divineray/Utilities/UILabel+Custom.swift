//
//  UILabel+Custom.swift
//  DigitalMenu
//
//  Created by apple on 04/12/19.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit

extension UILabel {

    
    func setTextSize(_ size:CGFloat) {
        self.font = self.font.withSize(size)
    }
    
    //MARK:- out line
    func makeOutLine(oulineColor: UIColor, foregroundColor: UIColor) {
        let strokeTextAttributes = [
        NSAttributedString.Key.strokeColor : oulineColor,
        NSAttributedString.Key.foregroundColor : foregroundColor,
        NSAttributedString.Key.strokeWidth : -4.0,
        NSAttributedString.Key.font : font ?? UIFont.systemFontSize
        ] as [NSAttributedString.Key : Any]
        self.attributedText = NSMutableAttributedString(string: self.text ?? "", attributes: strokeTextAttributes)
    }
    
    //MARK:- unser line
    var underline:Void {
        if let textString = text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                             value: NSUnderlineStyle.single.rawValue,
                                             range: NSRange(location: 0,
                                                            length: attributedString.length))
            attributedText = attributedString
        }
    }
    
    func drawLineOnBothSides(labelWidth: CGFloat, color: UIColor) {

        let fontAttributes = [NSAttributedString.Key.font: self.font]
        let size = self.text?.size(withAttributes: fontAttributes as [NSAttributedString.Key : Any])
        let widthOfString = size!.width

        let width = CGFloat(1)

        let leftLine = UIView(frame: CGRect(x: 0, y: self.frame.height/2 - width/2, width: labelWidth/2 - widthOfString/2 - 10, height: width))
        leftLine.backgroundColor = color
        self.addSubview(leftLine)

        let rightLine = UIView(frame: CGRect(x: labelWidth/2 + widthOfString/2 + 10, y: self.frame.height/2 - width/2, width: labelWidth/2 - widthOfString/2 - 10, height: width))
        rightLine.backgroundColor = color
        self.addSubview(rightLine)
    }
    
    
    
    open func setAttributed(str1:String, font1:UIFont?, color1:UIColor, str2:String, font2:UIFont?, color2:UIColor)  {
        
        let attributed = NSMutableAttributedString(string: str1, attributes: [
        .font: font1 ?? UIFont(), .foregroundColor: color1])
      
        let attributed2 = NSMutableAttributedString(string: " ", attributes: [
        .font: font1 ?? UIFont(), .foregroundColor: color1])
        
        let attributed3 = NSMutableAttributedString(string: str2, attributes: [
        .font: font2 ?? UIFont(), .foregroundColor: color2])
        
        let attributedStirng = NSMutableAttributedString(attributedString: attributed)
        attributedStirng.append(attributed2)
        attributedStirng.append(attributed3)
        
        self.attributedText = attributedStirng
    }
    
    func setWithPrice(_ description:String, _ price:Int, isSeeMore:Bool) {
        if description.count > 75 {
            if isSeeMore == true {
                let textSting = description.prefix(75)
                let attributedString = NSMutableAttributedString(string: "(\(textSting)", attributes: [
                    .font: UIFont.setCustom(.Cinzel_Regular, 12), .foregroundColor: UIColor.placeholderColor ])
                
                let seeMoreString = NSAttributedString(string: " See More) \(price)/-", attributes: [.font: UIFont.setCustom(.Cinzel_Regular, 14),.foregroundColor: UIColor.textColor])
                
                attributedString.append(seeMoreString)
                self.attributedText = attributedString
            } else {
                let attributedString = NSMutableAttributedString(string: "(\(description)", attributes: [
                    .font: UIFont.setCustom(.Cinzel_Regular, 12), .foregroundColor: UIColor.placeholderColor ])
                
                let seeMoreString = NSAttributedString(string: " See Less) \(price)/-", attributes: [.font: UIFont.setCustom(.Cinzel_Regular, 14),.foregroundColor: UIColor.textColor])
                
                attributedString.append(seeMoreString)
                self.attributedText = attributedString
            }
        } else {
            
            let attributedString = NSMutableAttributedString(string: "(\(description)", attributes: [
                .font: UIFont.systemFont(ofSize: 12),
              .foregroundColor: UIColor.placeholderColor
            ])
            
            let seeMoreString = NSAttributedString(string: " \(price)/-", attributes: [.font: UIFont.setCustom(.Cinzel_Bold, 14),.foregroundColor: UIColor.textColor])

            attributedString.append(seeMoreString)
            self.attributedText = attributedString
        }
    }
    
    func setLabel(_ text:String?, _ color:UIColor?, _ font:FONT_NAME, _ size: CGFloat) {
        self.textColor = color ?? UIColor.black
        self.text = text
        self.font = UIFont.setCustom(font, size)
    }
    
    func centerLine() {
        let text = self.text?.strikeThrough
        self.attributedText = text
    }
    
    func setAttributedLabel(_ title: String?,_ value: String?, _ font:FONT_NAME, _ size: CGFloat) {
        self.font = UIFont.setCustom(font, size)
        let mutable = NSMutableAttributedString(string: title ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.placeholderColor])
        let value = NSAttributedString(string: value ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.textColor])
        mutable.append(value)
        self.attributedText = mutable
    }
    
    func setCommentLabel(title: String?, value: String?) {
        let mutable = NSMutableAttributedString(string: "\(title ?? "") ", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.placeholderColor,
            NSAttributedString.Key.font : UIFont.setCustom(.Cinzel_Black, 14)
        ])
        let value = NSAttributedString(string: value ?? "", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.textColor,
            NSAttributedString.Key.font : UIFont.setCustom(.Cinzel_Black, 13)
        ])
        mutable.append(value)
        self.attributedText = mutable
    }
    
    func setMediumFont(_ text:String, _ textColor:UIColor) {
        self.setLabel(text, textColor, .Cinzel_Regular, 15)
    }
    
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {

        guard let labelText = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple

        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }

        // (Swift 4.2 and above) Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))


        // (Swift 4.1 and 4.0) Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))

        self.attributedText = attributedString
    }
    
}


extension UITapGestureRecognizer {
    
    open func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x:(labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y:(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}

