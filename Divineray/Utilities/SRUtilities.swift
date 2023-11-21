//
//  Utilities.swift
//  Divineray
//
//  Created by     on 08/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit

class SRUtilities: NSObject {
    var deviceAPNSToken:String?
    var sessionToken:String?
    var appUserId:String?
    
    private static let _sharedInstance = SRUtilities()
    public class func sharedInstance() -> SRUtilities {
        return _sharedInstance
    }
    
    private override init () {
        self.sessionToken = ""
        self.deviceAPNSToken = ""
        self.appUserId = ""
    }
    
    func getDeviceApnsToken() ->String {
        return deviceAPNSToken ?? ""
    }
    
    func setDeviceApnsToken(apns:String?) {
        if let apnsToken = apns {
            self.deviceAPNSToken = apnsToken
        }
    }
    
    func setSessionToken(session:String?) {
        if let sessionValue = session {
            self.sessionToken = sessionValue
        }
    }
    func getSessionToken() ->String {
        return sessionToken ?? ""
    }
    
    func setUserId(userId:String?) {
        if let userId = userId {
            self.appUserId = userId
        }
    }
    func getUserId() ->String {
        return appUserId ?? ""
    }
  
    
    
    static func showToastMessage(_ message: String)  {
        if let topViewController = UIApplication.shared.topMostViewController() {
            Loaf(message, state: .custom(.init(backgroundColor: .black, icon: nil, textAlignment: .center, width: .screenPercentage(0.8))), sender:  topViewController).show()
        } else {
            //UIApplication.shared.keyWindow?.rootViewController?.view.makeToast(message)
        }
    }
    
}


struct globalVariables {
    static let rect = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
    static let width  = UIScreen.main.bounds.width
    static let height: CGFloat =  64
}
//   self.navigationController?.view.backgroundColor = navigationColor
//    self.navigationController?.navigationItem.hidesBackButton = true
//    self.navigationItem.hidesBackButton = true
//
//    // Navigation Bar color and shadow
//    self.navigationController?.navigationBar.barTintColor = navigationColor
//    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//    self.navigationController?.navigationBar.shadowImage = UIImage()
//
//    // Title Label
//    self.navigationController?.navigationBar.addSubview(self.titleLabel)
//
//    // Tab Bar
//    self.view.addSubview(self.tabBar)


enum AlertMessages {
    static var Apptitle   = "Your App Title"
    static var Firstname  = "Please Enter Firstname"
    static var SurName    = "Please Enter Name"
    static var MobileNo   =  "Please Enter MobileNo"
    static var EmailId    =  "Please Enter Valid EmailId"
    static var Password   =  "Please Enter Password"
    static var ConfirmPassword   =  "Please Enter Confirm Password"
    static var Submited    = "Details Submited SuccessFully"
    static var MobileExits   = "Mobile No Already Exits"
    static var ValidMobileNo  =  "Please Enter Valid Mobile No"
    static var ReqPassword  =  "Password Should be minimum 6 character Length"
    static var PassMatch   =  "Password and Confirm Password Should be Same"
    static var GeneralErrorMsg  = "Oops, something went wrong. Please try again later."
    static var EmailSentMsg = "Please check your message box for OTP"
    static var CityMissingMsg = "Please select city."
    static var AmountMissingMsg = "Please enter the amount."
    static var TeamAMissingMsg = "Please choose teamA."
    static var TeamBMissingMsg = "Please choose teamB."
    static var MainArtistMissingMsg = "Please choose main artist."
    static var EmptyErrorMsg  = "No Data Found"
    static var NetworkErrorMsg  = "Please check your network settings."
    static var LikedErrorMsg  = "you have already liked!"
    static var PackageErrorMsg  = "Please select atleast a package"
    static var DownloadedMsg  = "File has downloaded"
    static let ALERT_OK                                         = "OK"
    static let ALERT_CANCEL                                     = "CANCEL"
    static let ALERT_YES                                        = "YES"
    static let ALERT_NO                                         = "NO"
    static let ALERT_END_LIVE_STREAM                            = "Are you sure to end live stream?"
}

extension DispatchQueue {
    // This method will dispatch the `block` to self.
    // If `self` is the main queue, and current thread is main thread, the block
    // will be invoked immediately instead of being dispatched.
    func safeAsync(_ block: @escaping ()->()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
}


extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

func getSymbol(forCurrencyCode code: String) -> String? {
    let locale = NSLocale(localeIdentifier: code)
    if locale.displayName(forKey: .currencySymbol, value: code) == code {
        let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
        return newlocale.displayName(forKey: .currencySymbol, value: code)
    }
    return locale.displayName(forKey: .currencySymbol, value: code)
}

func getTime()->String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMM yyyy,hh:mm T"
    let currentDate = dateFormatter.string(from: Date())
    return currentDate
}


