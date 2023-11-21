//
//  AppDefaults.swift
//  SetUpNewProject
//
//  Created by dr mac on 09/01/23.
//

import Foundation
struct AppDefaults {
    static var userID:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "userID")
        }
        get{
            return UserDefaults.standard.string(forKey: "userID")
        }
    }
    static var postID:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "postID")
        }
        get{
            return UserDefaults.standard.string(forKey: "postID")
        }
    }
    static var swipeCount:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "swipeCount")
        }
        get{
            return UserDefaults.standard.string(forKey: "swipeCount")
        }
    }
    static var facebookToken:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "facebookToken")
        }
        get{
            return UserDefaults.standard.string(forKey: "facebookToken")
        }
    }
    static var googleToken:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "googleToken")
        }
        get{
            return UserDefaults.standard.string(forKey: "googleToken")
        }
    }
    static var updateMessageText:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "updateText")
        }
        get{
            return UserDefaults.standard.string(forKey: "updateText")
        }
    }
    static var subscriptionId:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "id")
        }
        get{
            return UserDefaults.standard.string(forKey: "id")
        }
    }
    
    static var description:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "description")
        }
        get{
            return UserDefaults.standard.string(forKey: "description")
        }
    }
    
    static var updateCity:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "City")
        }
        get{
            return UserDefaults.standard.string(forKey: "City")
        }
    }

    static var profileComplete:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "profile_complete")
        }
        get{
            return UserDefaults.standard.string(forKey: "profile_complete")
        }
    }
    static var token:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "authtoken")
        }
        get{
            return UserDefaults.standard.string(forKey: "authtoken")
        }
    }
    static var planSubscription:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "planSubscription")
        }
        get{
            return UserDefaults.standard.string(forKey: "planSubscription")
        }
    }
    static var showActivty:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "showActivty")
        }
        get{
            return UserDefaults.standard.string(forKey: "showActivty")
        }
    }
    static var planName:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "planName")
        }
        get{
            return UserDefaults.standard.string(forKey: "planName")
        }
    }
    static var connectProfile:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "connectProfile")
        }
        get{
            return UserDefaults.standard.string(forKey: "connectProfile")
        }
    }
    static var planID:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "planID")
        }
        get{
            return UserDefaults.standard.string(forKey: "planID")
        }
    }
    static var latitude:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "latitude")
        }
        get{
            return UserDefaults.standard.string(forKey: "latitude")
        }
    }
    static var longitude:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "longitude")
        }
        get{
            return UserDefaults.standard.string(forKey: "longitude")
        }
    }
    
    static var userFirstName:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "first_name")
        }
        get{
            return UserDefaults.standard.string(forKey: "first_name")
        }
    }
    
    static var userLastName:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "last_name")
        }
        get{
            return UserDefaults.standard.string(forKey: "last_name")
        }
    }
    
    static var userName:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "name")
        }
        get{
            return UserDefaults.standard.string(forKey: "name")
        }
    }
    
    static var loginId:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "login_id")
        }
        get{
            return UserDefaults.standard.string(forKey: "login_id")
        }
    }
    
    static var userImage:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "image")
        }
        get{
            return UserDefaults.standard.string(forKey: "image")
        }
    }
    
    static var userEmail:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "email")
        }
        get{
            return UserDefaults.standard.string(forKey: "email")
        }
    }
    static var userRemember:Bool?{
        set{
            UserDefaults.standard.set(newValue, forKey: "remember")
        }
        get{
            return UserDefaults.standard.bool(forKey: "remember")
        }
    }
    
    static var userPassword:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "password")
        }
        get{
            return UserDefaults.standard.string(forKey: "password")
        }
    }
    
    static var deviceToken:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "deviceToken")
        }
        get{
            return UserDefaults.standard.string(forKey: "deviceToken") ?? "1234"
        }
    }
    
    static var isLock:Int?{
        set{
            UserDefaults.standard.set(newValue, forKey: "isLock")
        }
        get{
            return UserDefaults.standard.integer(forKey: "isLock") ?? 0
        }
    }
    
    static var reviewId:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "reviewId")
        }
        get{
            return UserDefaults.standard.string(forKey: "reviewId")
        }
    }
    
    
    static var isType:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "isType")
        }
        get{
            return UserDefaults.standard.string(forKey: "isType")
        }
    }
    static var notificationType:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "notificationType")
        }
        get{
            return UserDefaults.standard.string(forKey: "notificationType")
        }
    }
    static var notificationId:String?{
        set{
            UserDefaults.standard.set(newValue, forKey: "notification_id")
        }
        get{
            return UserDefaults.standard.string(forKey: "notification_id")
        }
    }
    
}

func setAppDefaults<T>(_ value:T,key: String) {
    UserDefaults.standard.set(value, forKey: key)
    UserDefaults.standard.synchronize()
}

func getAppDefaults<T>(key:String) -> T? {
    guard let value = UserDefaults.standard.value(forKey: key) as? T else {
        return nil
    }
    return value
}
func getSAppDefault(key:String) -> Any{
    let value = UserDefaults.standard.value(forKey: key)
    return value as Any
}
func removeAppDefaults(key: String) {
    UserDefaults.standard.removeObject(forKey: key)
    UserDefaults.standard.synchronize()
}


