//
//  ApplicationStates.swift
//  Divineray
//
//  Created by     on 08/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit



class ApplicationStates: NSObject {
    

    static func isUserLoggedIn() -> Bool {
           if let userDetails = UserDefaults.standard.value(forKey: "user_details") as? [String:Any]{
            let userId = userDetails["user_id"] as? String ?? ""
            if !userId.isEmpty {
                return true;
            }
        }
        return false
    }
    static func isUserTokenIn() -> Bool {
           if let userDetails = UserDefaults.standard.value(forKey: "user_details") as? [String:Any]{
            let userId = userDetails["usertoken"] as? String ?? ""
            if !userId.isEmpty {
                return true;
            }
        }
        return false
    }
    static func setUserData(Info:[String:Any]) -> Void {
        UserDefaults.standard.set(Info, forKey:"user_details")
        UserDefaults.standard.synchronize()
    }
    static func removeUserData() -> Void {
        UserDefaults.standard.removeObject(forKey: "user_details")
        UserDefaults.standard.synchronize()
    }

    static func getUserData() -> [String:Any]? {
        return UserDefaults.standard.dictionary(forKey: "user_details")
    }
    static func getUserID() -> String {
         if let userDetails = UserDefaults.standard.value(forKey: "user_details") as? [String:Any]{
           let userId = userDetails["user_id"] as? String ?? ""
           return userId
       }
        return ""
    }
    static func getSecurityToken() -> String {
         if let userDetails = UserDefaults.standard.value(forKey: "user_details") as? [String:Any]{
           let securitytoken = userDetails["securitytoken"] as? String ?? ""
           return securitytoken
       }
        return ""
    }
    static func getTokenID() -> String {
         if let userDetails = UserDefaults.standard.value(forKey: "user_details") as? [String:Any]{
           let usertoken = userDetails["usertoken"] as? String ?? ""
           return usertoken
       }
        return ""
    }
}
