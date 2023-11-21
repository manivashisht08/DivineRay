//
//  String+Custom.swift
//  CullintonsCustomer
//
//  Created by Nitin Kumar on 07/04/18.
//  Copyright © 2018 Nitin Kumar. All rights reserved.
//

import UIKit

extension String {
    
    enum format:String {
        
        case created = "dd MMM yyy HH:mm a"
        
        case full1 = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        case full2 = "hh:mm a, dd MMM yyyy"
        case EEEEddMM = "EEEE dd MM"
        case E4d2M3 = "EEEE dd MMM"
        case ddM4EEEE = "dd MMMM EEEE"
        case ddM3EEEE = "dd MMM EEEE"
        case ddM3y4 = "dd MMM yyyy"
        case d2M4y4 = "dd MMMM yyyy"
        case time = "hh:mm a"
        case HHmm = "HH:mm"
        case ddM3y4HHmm = "dd MMM yyyy HH:mm"
        case ddM4y4hhmma = "dd MMMM yyyy, hh:mm a"
        case E4Ath2m2a = "EEEE 'at' hh:mm a"
        case E3d2M3 = "EEE, dd MMM"
        case mmmddyyyy = "MMM dd,yyyy hh:mm a"
        case y_MM_dd = "yyyy-MM-dd"
        
    }
   
    var toDouble: Double? {
        return Double(self)
    }
    
    var toInt: Int? {
        return Int(self)
    }
    
    var toCGFloat: CGFloat? {
        return CGFloat(self.toDouble ?? 0)
    }
    
    var url: URL? {
        return URL(string: self)
    }
    
    
    var numerals: String {
        let pattern = UnicodeScalar("0")..."9"
        let string = String(unicodeScalars.compactMap { pattern ~= $0 ? Character($0) : nil })
        return string
    }
    
    var numeralsOnly: Int {
        let pattern = UnicodeScalar("0")..."9"
        let string = String(unicodeScalars.compactMap { pattern ~= $0 ? Character($0) : nil })
        return Int(string) ?? 0
    }
    
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
    
    var generateQRCode: UIImage? {
        let data = self.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    
    var strikeThrough: NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
        return attributeString
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGRect {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox
    }
    
    func widthWithConstrainedHeight(height: CGFloat, font: UIFont) -> CGRect {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

    
    var html2String: String? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil).string
            
        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
    
    
    func stringToTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        guard let date1 = dateFormatter.date(from: self) else { return "" }
        
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        dateFormatter.dateFormat = "MMM dd, YYYY"
//        let dateSelected = dateFormatter.string(from: date1)
        
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        dateFormatter.dateFormat = "hh:mm a"
        let timeSelected = dateFormatter.string(from: date1)
       // let updatedDate = "\(dateSelected) at \(timeSelected)"
        
        return timeSelected
    }
    
    func changeFormat(_ format1:String, to format2:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = format1
        guard let date1 = dateFormatter.date(from: String(self)) else { return "" }
        
        dateFormatter.dateFormat = format2
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let dateSelected = dateFormatter.string(from: date1)
        return dateSelected
    }
    
    func changeFormat(_ format1:format, to format2:format) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format1.rawValue
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        guard let date1 = dateFormatter.date(from: String(self)) else { return "" }
        
        dateFormatter.dateFormat = format2.rawValue
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        let dateSelected = dateFormatter.string(from: date1)
        return dateSelected
    }
    
    func postDateTime() -> String {

        let date = self.utcToLocal(format: .full1).changeToDateStandard(withFormat: .full1)
        
        if (date?.isToday ?? false) {
            let time = date?.toStringStandard(format: .time)
            return "Today at \(time ?? "")"
        } else if (date?.isYesterday ?? false) {
            let time = date?.toStringStandard(format: .time)
            return "Yesterday at \(time ?? "")"
        } else {

//            let dateFormatter = DateFormatter()
//            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//            dateFormatter.dateFormat = String.format.full1.rawValue
//            let date = dateFormatter.date(from: String(self))
//            dateFormatter.dateFormat = String.format.full2.rawValue
//            dateFormatter.timeZone = .current
//            let dateSelected = dateFormatter.string(from: date!)
            
            let formattedTime = date?.toStringStandard(format: .full2)
            
            return formattedTime ?? ""
        }
    }
    
    func changeToDateStandard(withFormat: format) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = withFormat.rawValue
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        return dateFormatter.date(from: String(self))
    }
    
    
    func changeToDate(withFormat:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = withFormat
        return dateFormatter.date(from: String(self))
    }
    
    func changeToLocalDate(withFormat: format) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        dateFormatter.dateFormat = withFormat.rawValue
        return dateFormatter.date(from: String(self))
    }
    
    
    func changeToDate(withFormat: format) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = withFormat.rawValue
        return dateFormatter.date(from: String(self))
    }
    
    
    func localToUTC(format:format) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        dateFormatter.dateFormat = format.rawValue
        guard let date1 = dateFormatter.date(from: String(self)) else { return "" }
        
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = format.rawValue
        let timeSelected = dateFormatter.string(from: date1)
        
        return timeSelected
    }
    
    var localToUTC: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        dateFormatter.dateFormat = String.format.full1.rawValue
        guard let date1 = dateFormatter.date(from: String(self)) else { return "" }
        
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = String.format.full1.rawValue
        let timeSelected = dateFormatter.string(from: date1)
        
        return timeSelected
    }
    
    var utcToLocal: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = String.format.full1.rawValue
        guard let date1 = dateFormatter.date(from: String(self)) else { return "" }
        
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        dateFormatter.dateFormat = String.format.full1.rawValue
        let timeSelected = dateFormatter.string(from: date1)
        return timeSelected
    }
    
    
    func utcToLocal(format:format) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = format.rawValue
        guard let date1 = dateFormatter.date(from: String(self)) else { return "" }
        
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        dateFormatter.dateFormat = format.rawValue
        let timeSelected = dateFormatter.string(from: date1)
        return timeSelected
    }
    
    var trim: String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    func getDayTitle(previousMessageDate:String) -> String {
        let previousDate = previousMessageDate.stringToDateWithDefaultFormat()
        let sentDateWithFormat = self.currentDateWithDefaultFormat()
        let day = self.getDayCount(previousDate: previousDate, sentDateWithFormat: sentDateWithFormat)
        switch day {
        case 0:
            return "Today"
        case 1:
            return "Yesterday"
        default:
            return previousMessageDate.stringToDate()
        }
    }
    
    func stringToDate()-> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" //Your date format
        guard let date1 = dateFormatter.date(from: String(self)) else { return "" } //according to date format your date string
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        dateFormatter.dateFormat = "dd MMM yyyy"
        let timeSelected = dateFormatter.string(from: date1)
        return timeSelected
    }
    
    func getDayDifference(previsouSentDate:String) -> Int {
        let previousDate = previsouSentDate.stringToDateWithDefaultFormat()
        let sentDateWithFormat = self.stringToDateWithDefaultFormat()
        let day = self.getDayCount(previousDate: previousDate, sentDateWithFormat: sentDateWithFormat)
        return day
    }
    
    func stringToDateWithDefaultFormat() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" //Your date format
        guard let date1 = dateFormatter.date(from: String(self)) else { return Date() } //according to date format your date string
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateSeleted = dateFormatter.string(from: date1)
        print(dateSeleted)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.date(from: dateSeleted)!
    }
    
    func stringToDateWith(format:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        guard let date = dateFormatter.date(from:self) else {return Date()}
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        let finalDate = calendar.date(from:components)
        return finalDate
    }
    
    
    func getDayCount(previousDate:Date, sentDateWithFormat:Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: previousDate, to: sentDateWithFormat)
        return components.day ?? 0
    }
    
    func currentDateWithDefaultFormat() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" //Your date format
        guard let date1 = dateFormatter.date(from: String(self)) else { return Date() } //according to date format your date
        return date1
    }
    
    func stringToTime(_ format:String) -> Date? {
        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = format//"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" //Your date format
        guard let date1 = dateFormatter.date(from: self) else { return Date() } //according to date format your date
        return date1
    }
    
    func stringToTime(_ newForamt:String, _ previousFormat:String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = previousFormat
        guard let date1 = dateFormatter.date(from: self) else { return nil } //according to date format your date
        dateFormatter.dateFormat = newForamt
        return dateFormatter.string(from: date1)
    }
    
    func toDictionary() -> [String:Any]? {
        var dictonary:[String:Any]?
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                if let myDictionary = dictonary {
                    return myDictionary
                }
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    func isEmoji() -> Bool {
        let character = self
        if character == "" || character == "\n" {
            return false
        }
        let characterRender = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        characterRender.text = character
        characterRender.backgroundColor = UIColor.black
        characterRender.sizeToFit()
        let rect: CGRect = characterRender.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        
        if let contextSnap:CGContext = UIGraphicsGetCurrentContext() {
            characterRender.layer.render(in: contextSnap)
        }
        
        let capturedImage: UIImage? = (UIGraphicsGetImageFromCurrentImageContext())
        UIGraphicsEndImageContext()
        var colorPixelFound:Bool = false
        
        let imageRef = capturedImage?.cgImage
        let width:Int = imageRef!.width
        let height:Int = imageRef!.height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let rawData = calloc(width * height * 4, MemoryLayout<CUnsignedChar>.stride).assumingMemoryBound(to: CUnsignedChar.self)
        
        let bytesPerPixel:Int = 4
        let bytesPerRow:Int = bytesPerPixel * width
        let bitsPerComponent:Int = 8
        
        let context = CGContext(data: rawData, width: Int(width), height: Int(height), bitsPerComponent: Int(bitsPerComponent), bytesPerRow: Int(bytesPerRow), space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
        
        context?.draw(imageRef!, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var x:Int = 0
        var y:Int = 0
        while (y < height && !colorPixelFound) {
            
            while (x < width && !colorPixelFound) {
                
                let byteIndex: UInt  = UInt((bytesPerRow * y) + x * bytesPerPixel)
                let red = CGFloat(rawData[Int(byteIndex)])
                let green = CGFloat(rawData[Int(byteIndex+1)])
                let blue = CGFloat(rawData[Int(byteIndex + 2)])
                
                var h: CGFloat = 0.0
                var s: CGFloat = 0.0
                var b: CGFloat = 0.0
                var a: CGFloat = 0.0
                
                let c = UIColor(red:red, green:green, blue:blue, alpha:1.0)
                c.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
                
                b = b/255.0
                
                if Double(b) > 0.0 {
                    colorPixelFound = true
                }
                x+=1
            }
            x=0
            y+=1
        }
        
        return colorPixelFound
    }
    
    func attributedString(text:String, color:UIColor, font:FONT_NAME, fontSize:CGFloat, subString:String, subStringColor:UIColor, subStringFont:FONT_NAME, subStringFontSize:CGFloat) -> (NSMutableAttributedString) {
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        let range = (text as NSString).range(of: subString)
        print(range)
        let attString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.setCustom(font, fontSize),NSAttributedString.Key.foregroundColor : color])
        attString.addAttribute(NSAttributedString.Key.foregroundColor, value: subStringColor, range: range)
        attString.addAttribute(NSAttributedString.Key.font, value: UIFont.setCustom(subStringFont,subStringFontSize), range: range)
        attString.addAttribute(NSAttributedString.Key.paragraphStyle, value:style, range: NSRange(location: 0, length: text.count))
      
        return attString
    }
 
    
    func timeInNumber(_ format:String) -> Int? {
        let hrs = self.stringToTime("HH", format) ?? ""
        let mins = self.stringToTime("mm", format) ?? ""
        var timeInInt:Int = 0
        if let hours = Int(hrs) {
            timeInInt = hours * 60
        }
        if let minutes = Int(mins) {
            timeInInt = timeInInt + minutes
        }
        return timeInInt
    }
    
}


