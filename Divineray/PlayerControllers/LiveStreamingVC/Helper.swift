//
//  Helper.swift
//  InfusionAnalystsProject
//
//  Created by IOSDEV1 on 10/10/18.
//  Copyright © 2018 Infusionanalysts. All rights reserved.
//


import UIKit
import Foundation

class Helper: NSObject {
    
    //------------------------------------------------------------------
	
	class func getViewForNib(nibNamed nibName:String,owner:AnyObject)->UIView{
		return (Bundle.main.loadNibNamed(nibName, owner: owner, options: nil)![0] as? UIView)!
	}
    
    //------------------------------------------------------------------
    
    class func show1ButtonAlert(onVC viewController:UIViewController,title:String,message:String,button1Title:String,button1ActionStyle:UIAlertAction.Style,onButton1Click:(()->())?){
        DispatchQueue.main.async {
            let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: button1Title, style:button1ActionStyle, handler: { (action:UIAlertAction) in
                onButton1Click?()
            }))
            
            alert.view.setNeedsLayout()
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    //------------------------------------------------------------------
	
    class func show2ButtonsAlert(onVC viewController:UIViewController,title:String,message:String,button1Title:String,button1ActionStyle:UIAlertAction.Style,button2Title:String,onButton1Click:(()->())?,onButton2Click:(()->())?){
		DispatchQueue.main.async {
            let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
			
			alert.addAction(UIAlertAction(title: button1Title, style:button1ActionStyle, handler: { (action:UIAlertAction) in
				onButton1Click?()
			}))
			
			alert.addAction(UIAlertAction(title: button2Title, style:.default, handler: { (action:UIAlertAction) in
				onButton2Click?()
			}))
			
			alert.view.setNeedsLayout()
			viewController.present(alert, animated: true, completion: nil)
		}
	}
    
    //------------------------------------------------------------------
	
	class func showOKAlert(onVC viewController:UIViewController,title:String,message:String){
        
        // Commonly used in entire app to show UIAlert with Ok
        
		DispatchQueue.main.async {
            let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
			alert.addAction(UIAlertAction(title: AlertMessages.ALERT_OK, style:.default, handler: nil))
			
			alert.view.setNeedsLayout()
			viewController.present(alert, animated: true, completion: nil)
		}
	}
    
    //------------------------------------------------------------------
	
	class func showOKAlertWithCompletion(onVC viewController:UIViewController,title:String,message:String,onOk:@escaping ()->()){
        
        // Commonly used in entire app to show UIAlert with Ok button's completion
		DispatchQueue.main.async {
            let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
			alert.addAction(UIAlertAction(title: AlertMessages.ALERT_OK, style:.default, handler: { (action:UIAlertAction) in
				onOk()
			}))
			alert.view.setNeedsLayout()
			viewController.present(alert, animated: true, completion: nil)
		}
	}
    
    //------------------------------------------------------------------
	
//    class func getStringFromNumber(_ number:Int) -> String{
//        let str = arrOfNumbers[number]
//        return str
//    }
    
    //------------------------------------------------------------------
	
	class func getiOSVersion()->Int{
		
        // gives a iOS version from device.
        
		let iOSVersion = Int(UIDevice.current.systemVersion)
		
		return iOSVersion!
	}
	
	class func getDeviceHeight() -> Int{
		
        // retrives device height from device.
        
		let deviceHeight:Int = Int(UIScreen.main.bounds.size.height)
		
		return deviceHeight
	}
	
    //----------------------------------------------------------------------------------------------------
    //MARK: check validation of email
    //----------------------------------------------------------------------------------------------------
	
	class func hasAlpha(_ string : NSString) -> Bool {
		
		let wantedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz")
		
		return (string.rangeOfCharacter(from: wantedCharacters).location == NSNotFound)
	}
	
	class func hasNumber(_ string : NSString) -> Bool {
		
		let wantedCharacters = CharacterSet(charactersIn: "0123456789")
		
		return (string.rangeOfCharacter(from: wantedCharacters).location == NSNotFound)
	}
    
//    class func isValidNumber(_ sContactInfo:String) -> Bool {
//        if sContactInfo.characters.count > 16 ||  sContactInfo.characters.count == 0 {
//            return false
//        } else {
//            return true
//        }
//    }

    class func isValidEmail(_ sEmail:String) -> Bool {
//        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$")
        let isValid:Bool = emailTest.evaluate(with: sEmail)
        return isValid
    }
    
    class func isValidMobileNumber(_ sEmail:String) -> Bool {
        //        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", "^(?:[0-9]{10}|)$")
        
        let isValid:Bool = emailTest.evaluate(with: sEmail)
        print("isValid",isValid)
        return isValid
    }
    
    class func isValidPassword(_ password : String) -> Bool{
//        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&].{7,}")
//        return passwordTest.evaluate(with: password)
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[\\w~@#$%^&*+=`|{}:;!.?\"()\\[\\]-]{8,25}$")
        return passwordTest.evaluate(with: password)
    }
    
//    func isValidPhone(phone: String) -> Bool {
//        let phoneRegex = "^[0-9]{10}$";
//        let valid = NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phone)
//        return valid
//    }

    
    // (?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&].{8,}
    
	class func getKeysFromWeekDay(_ weekday:Int) -> (startdatekey:String, enddatekey:String,ischeckkey:String) {
		
		if weekday == 1 {
			
			return ("sundaystartdate","sundayenddate","issunday")
		}
		if weekday == 2 {
			
			return ("mondaystartdate","mondayenddate","ismonday")
		}
		if weekday == 3 {
			
			return ("tuesdaystartdate","tuesdayenddate","istuesday")
		}
		if weekday == 4 {
			
			return ("wednessdaystartdate","wednessdayenddate","iswednessday")
		}
		if weekday == 5 {
			
			return ("thursdaystartdate","thursdayenddate","isthursday")
		}
		if weekday == 6 {
			
			return ("fridaystartdate","fridayenddate","isfriday")
		}
		if weekday == 7 {
			
			return ("saturdaystartdate","saturdayenddate","issaturday")
		}
		
		return ("","","")
	}
	
	//MARK: resizing image
	//----------------------------------------------------------------------------------------------------
	
	class func imageResize (_ imageObj:UIImage, sizeChange:CGSize)-> UIImage{
		
		let hasAlpha = false
		let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
		
		UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
		imageObj.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
		
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		return scaledImage!
	}
	
	//MARK: get time from dateString
	//----------------------------------------------------------------------------------------------------
	
	class func getTimeFromDateString(_ date:Date) -> String
	{
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm a"
		let dateString:String = dateFormatter.string(from: date)
		
		return dateString
	}
	
	//MARK: get date from dateString
	//----------------------------------------------------------------------------------------------------
	
	class func getStringFromDate(_ date:Date) -> String
	{
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMMM dd, yyyy | hh:mm a"
		let dateString:String = dateFormatter.string(from: date)
		return dateString
	}
	class func getDateFromDateString(_ dateString:NSString) -> Date
	{
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss"
		//        dateFormatter.timeZone = NSTimeZone(abbreviation: "EST")
		let date:Date = dateFormatter.date(from: dateString as String)!
		return date
	}
	
	//MARK: covert array to string
	class func arrayToJsonString(_ arrData:NSArray) -> NSString
	{
		let data = try? JSONSerialization.data(withJSONObject: arrData, options: [])
		let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
		return string!
	}
	
	//MARK: covert string to array
	class func stringToarray(_ string:NSString) -> AnyObject
	{
		
		let dicResponce: AnyObject? = try! JSONSerialization.jsonObject(with: string.data(using: String.Encoding.utf8.rawValue)!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
		
		return dicResponce!
		
	}
    
    class func convertUTCTimeToLocalTime(strUtcTime: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS+SSSS"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let date = dateFormatter.date(from: strUtcTime)// create   date from string
        
        // change to a readable time format and change to local time zone
//        dateFormatter.dateFormat = "hh:mm"
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm aa"
        
        dateFormatter.timeZone = NSTimeZone.local
        let strDateInLocal = dateFormatter.string(from: date!)
        return strDateInLocal
    }
	
	class func convertTimeFromIntToString(_ time: Int) -> String {
		
		if time == -1 {
			return "-"
		}
		
		var newTime = ""
		if time == 0 {
			newTime = "12:00 AM"
		}
		else {
			var suffix = ""
			var hours = floor(Double(time)/100)
			let minutes = floor(Double(time).truncatingRemainder(dividingBy: 100))
			if hours >= 12 {
				hours = hours - 12
				suffix = " PM"
			} else {
				suffix = " AM"
			}
			newTime = String(format: "%02d", Int(hours)) + ":" + String(format: "%02d",  Int(minutes)) + suffix
		}
		return newTime
	}
	
	class func calculateDaysFromStartToEndDate(_ startDate:Date , endDate:Date) -> Int {
		let calendar: Calendar = Calendar.current
		let components = (calendar as NSCalendar).components(NSCalendar.Unit.day , from: startDate, to: endDate,options: [])
		return components.day!
	}

}
