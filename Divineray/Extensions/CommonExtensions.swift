//
//  Common.swift
//  Divineray
//
//  Created by     on 08/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit

public struct Errors {
    /*public static var unknownError: NSError {
     return gennerate(with: -9999, domain: Constants.networkingDomain, message: "Unknown error")
     }
     public static var responseError: NSError {
     return gennerate(with: -1, domain: Constants.networkingDomain, message: "Unsuspect response value")
     }*/
    static func gennerate(with code: Int, domain: String, message: String) -> NSError {
        return NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }
}


// hide keyboards in view controllers
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension Date {
    func differenceInDaysWithDate(date: Date) -> Int {
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return (components.day ?? 0 > 0 ? components.day : 0)  ?? 0
    }
    
    static func isCurrentDateIsFuture(eventDate:String) -> Bool {
        
        let timeEnd = Date(timeInterval: eventDate.toDate(format: "yyyy-MM-dd HH:mm:ss").timeIntervalSince(Date()), since: Date())
        let timeNow = Date()
        if timeEnd.compare(timeNow) == ComparisonResult.orderedDescending {
            return true
        }
      return false
    }
    
}

extension DateFormatter {
    static var endDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
}

extension UIView {
    func addShadow(color: UIColor = UIColor.gray, cornerRadius: CGFloat) {
        self.backgroundColor = UIColor.white
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 1.0
        self.backgroundColor = .white
        self.layer.cornerRadius = cornerRadius
    }
}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
    }
    
    convenience init(red: Int, green: Int, blue: Int, alpa:Float) {
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: CGFloat(alpa))
    }
    

    class var appthemeColor: UIColor { return UIColor.red }
    class func hexColorStr (_ hexStr : NSString, alpha : CGFloat) -> UIColor {
       var hexStr = hexStr, alpha = alpha
       hexStr = hexStr.replacingOccurrences(of: "#", with: "") as NSString
       let scanner = Scanner(string: hexStr as String)
       var color: UInt32 = 0
       if scanner.scanHexInt32(&color) {
           let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
           let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
           let b = CGFloat(color & 0x0000FF) / 255.0
           return UIColor(red:r,green:g,blue:b,alpha:alpha)
       } else {
           print("invalid hex string")
           return UIColor.white;
       }
   }

}

// store colors on user defaults
extension UserDefaults {
    func potter_colorForKey(key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        }
        return color
    }
    
    func potter_setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color) as NSData?
        }
        set(colorData, forKey: key)
    }
}
extension Dictionary where Key == String, Value == Any {
    mutating func append(anotherDict:[String:Any]) {
        for (key, value) in anotherDict {
            self.updateValue(value, forKey: key)
        }
    }
}
extension String {
    var boolValue: Bool {
        return NSString(string: self).boolValue
    }
    
}

extension String{
    func toDate(format : String) -> Date{
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)!
    }
}


@IBDesignable class PaddingLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 16.0
    @IBInspectable var rightInset: CGFloat = 16.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}


extension String {
    var htmlToAttributedString: NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return NSMutableAttributedString() }
        do {
            return try NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSMutableAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}


extension UIViewController  {

    func compressImage( image: UIImage) -> UIImage {

        var actualHeight = Float(image.size.height)
        var actualWidth = Float(image.size.width)
        let maxHeight = Float(200.0)
        let maxWidth = Float(200.0)
        var imageRatio = Float(actualWidth/actualHeight)
        let maxRatio = Float(maxWidth/maxHeight)
        let compressionQuality = Float( 0.5 )  // 50 percent compression
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imageRatio < maxRatio {
                //adjust width according to maxHeight
                imageRatio = maxHeight / actualHeight
                actualWidth = imageRatio * actualWidth
                actualHeight = maxHeight
            } else if imageRatio > maxRatio {
                imageRatio = maxWidth / actualWidth
                actualHeight = imageRatio * actualHeight
                actualWidth = maxWidth

            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }

        }

        let rect = CGRect(x: 0, y: 0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let compressedImage =  UIGraphicsGetImageFromCurrentImageContext()
        let compressedImageData  = compressedImage!.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: compressedImageData!)!
    }

}


extension UITableView {
    func setNoDataPlaceholder(_ message: String) {
        let label = UILabel(frame: CGRect(x: 30, y: 0, width: self.bounds.size.width-30, height: self.bounds.size.height))
        label.text = message
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        label.textColor = UIColor.white
        self.isScrollEnabled = false
        self.backgroundView = label
        self.separatorStyle = .none
    }
}

extension UICollectionView {
    func setNoDataPlaceholder(_ message: String) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        label.text = message
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.sizeToFit()
        self.isScrollEnabled = false
        self.backgroundView = label
    }
}

extension UITableView {
    func removeNoDataPlaceholder() {
        self.isScrollEnabled = true
        
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}


extension UIView {
    func setNoDataMessage(_ message: String) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width/2, height: self.bounds.size.height/2))
        label.text = message
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        self.addSubview(label)
        label.frame = CGRect.init(x: 20, y: self.bounds.size.height/2, width: self.bounds.size.width-40, height: 100)
    }
}

