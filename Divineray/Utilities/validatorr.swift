//
//  validatorr.swift
//  Smallwrld
//
//  Created by dr mac on 07/08/23.
//

import Foundation
class Validator {
    
    
    static public func validateEmail(candidate: String) -> (Bool,String) {
        guard candidate.count > 0  else {
            return (false, "Please enter email")
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let isValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
        return (isValid, "Please enter valid email")
    }
    
    static public func validateAccountId(id:String) -> Bool {
        let regex = "^[a-z-A-Z]{6}+[0-9]{2}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: id)
    }
    
    static public func validateName(name: String) -> (Bool,String) {
      
        let maxLength = 50 // Maximum allowed length for full name
        
           // Trim any leading or trailing whitespaces
           let trimmedFullName = name.trimmingCharacters(in: .whitespacesAndNewlines)
           
        guard trimmedFullName.count <= maxLength   else {
            return (false, "Name is too long")
        }
        guard name.count > 0  else {
            return (false, "Please enter name")
        }
        guard name.count > 1  else {
            return (false, "Please enter at least two Characters for name")
        }
        
        return (true, "")
    }
    
    static public func validateFirstName(name: String) -> (Bool,String) {
      
        let maxLength = 30 // Maximum allowed length for full name
        
           // Trim any leading or trailing whitespaces
           let trimmedFullName = name.trimmingCharacters(in: .whitespacesAndNewlines)
           
        guard trimmedFullName.count <= maxLength   else {
            return (false, "Name is too long")
        }
        guard name.count > 0  else {
            return (false, "Please enter first name")
        }
        guard name.count > 1  else {
            return (false, "Please enter at least two Characters for first name")
        }
        
        return (true, "")
    }
    static public func validateGroupName(name: String) -> (Bool,String) {
      
        let maxLength = 30 // Maximum allowed length for full name
        
           // Trim any leading or trailing whitespaces
           let trimmedFullName = name.trimmingCharacters(in: .whitespacesAndNewlines)
           
        guard trimmedFullName.count <= maxLength   else {
            return (false, "Name is too long")
        }
        guard name.count > 0  else {
            return (false, "Please enter group name")
        }
        guard name.count > 1  else {
            return (false, "Please enter at least two Characters for group name")
        }
        
        return (true, "")
    }
    
    static public func validateLastName(name: String) -> (Bool,String) {
      
        let maxLength = 30 // Maximum allowed length for full name
        
           // Trim any leading or trailing whitespaces
           let trimmedFullName = name.trimmingCharacters(in: .whitespacesAndNewlines)
           
        guard trimmedFullName.count <= maxLength   else {
            return (false, "Name is too long")
        }
        guard name.count > 0  else {
            return (false, "Please enter last name")
        }
        guard name.count > 1  else {
            return (false, "Please enter at least two Characters for last name")
        }
        
        return (true, "")
    }
    
    static public func validateLearnReson(learnReason: String) -> (Bool,String) {
        guard learnReason.count > 0  else {
            return (false, "Please select learn reason")
        }
        return (true, "")
    }
    
    static public func validateDailyLearningGoal(lerningGoal: String) -> (Bool,String) {
        guard lerningGoal.count > 0  else {
            return (false, "Please select daily learning goal")
        }
        return (true, "")
    }
    
    static public func validateEnglishLevel(englishLevel: String) -> (Bool,String) {
      
        guard englishLevel.count > 0  else {
            return (false, "Please select spanish level")
        }
        
        return (true, "")
    }

    static public func validateVenue(venue: String) -> (Bool,String) {
        guard venue.count > 0  else {
            return (false, "Please enter venue")
        }
        let maxLength = 50 // Maximum allowed length for full name
        
           // Trim any leading or trailing whitespaces
           let trimmedFullName = venue.trimmingCharacters(in: .whitespacesAndNewlines)
           
        guard trimmedFullName.count <= maxLength   else {
            return (false, "Venue is too long.")
        }
        guard venue.count > 3  else {
            return (false, "Please enter at least four Character's for venue.")
        }
     
        return (true, "")
    }
    static public func validateUrl(venue: String) -> (Bool,String) {
        guard venue.count > 0  else {
            return (false, "Please enter url")
        }
        return (true, "")
    }
    
    static public func validateEventName(eventName: String) -> (Bool,String) {
        guard eventName.count > 0  else {
            return (false, "Please enter event name")
        }
        let maxLength = 50 // Maximum allowed length for full name
        
           // Trim any leading or trailing whitespaces
           let trimmedFullName = eventName.trimmingCharacters(in: .whitespacesAndNewlines)
           
        guard trimmedFullName.count <= maxLength   else {
            return (false, "Event name is too long.")
        }
        guard eventName.count > 3  else {
            return (false, "Please enter at least four Character's for Event name.")
        }
        return (true, "")
    }
    static public func validateEventTime(eventName: String) -> (Bool,String) {
    
        guard eventName.count > 0  else {
            return (false, "Please enter event time")
        }
    
        return (true, "")
    }
    
    static public func validatebio(caption: String) -> (Bool,String) {
        guard caption.count > 0  else {
            return (false, "Please enter bio")
        }
        let maxLength = 200 // Maximum allowed length for full name
        
           // Trim any leading or trailing whitespaces
           let trimmedFullName = caption.trimmingCharacters(in: .whitespacesAndNewlines)
           
        guard trimmedFullName.count <= maxLength   else {
            return (false, "Caption is too long.")
        }
        guard caption.count > 0  else {
            return (false, "Please enter Character's for bio.")
        }
     
        return (true, "")
    }
    
    static public func validateDescs(caption: String) -> (Bool,String) {
        guard caption.count > 0  else {
            return (false, "Please enter description.")
        }
        let maxLength = 200 // Maximum allowed length for full name
        
           // Trim any leading or trailing whitespaces
           let trimmedFullName = caption.trimmingCharacters(in: .whitespacesAndNewlines)
           
        guard trimmedFullName.count <= maxLength   else {
            return (false, "Description is too long.")
        }
        guard caption.count > 3  else {
            return (false, "Please enter at least four Character's for description.")
        }
    
        return (true, "")
    }
    
//    static public func validateImagePost(postImage: [PickerData]) -> (Bool,String) {
//        guard postImage.count > 0  else {
//            return (false, "Please select atleast one video or image.")
//        }
//        return (true, "")
//    }
    
    static public func validateDesc(caption: String) -> (Bool,String) {
        guard caption.count > 0  else {
            return (false, "Please enter description")
        }
        return (true, "")
    }
    
    static public func validateUsername(name: String) -> (Bool,String) {
        guard name.count > 0  else {
            return (false, "Please enter user name")
        }
        guard name.count > 2  else {
            return (false, "Please enter at least three Character")
        }
        guard name.rangeOfCharacter(from: .whitespaces) == nil else {
            return (false, "Username must not contain whitespace characters.")
        }
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?")
        guard (name.rangeOfCharacter(from: specialCharacters) == nil) else{
            // The username contains special characters
            return (false, "Username must not contain special characters.")
        }
        return (true, "")
    }
    
    static public func validateGender(gender: String) -> (Bool,String) {
        guard gender.count > 0  else {
            return (false, "Please select gender.")
        }
        return (true, "")
    }
    
    static public func validateBio(bio: String) -> (Bool,String) {
        guard bio.count > 0  else {
            return (false, "Please enter bio.")
        }
        
        let maxLength = 200 // Maximum allowed length for full name
           // Trim any leading or trailing whitespaces
           let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
           
        guard trimmedBio.count <= maxLength   else {
            return (false, "Bio is too long.")
        }
        
        return (true, "")
    }
    
    
    static public func validateSeries(name: String, message: String) -> (Bool,String) {
        guard name.count > 0  else {
            return (false, message)
        }
        return (true, message)
    }
    
    static public func validate_is_select(is_select: Bool, message: String) -> (Bool,String) {
        guard is_select == true  else {
            return (false, message)
        }
        return (true, message)
    }
    
    static public func validateCaption(caption: String,message: String) -> (Bool,String) {
        guard caption.count > 0  else {
            return (false, message)
        }
        return (true, message)
    }
    
    static public func validatePhoneNumber(number: String?) -> (Bool,String) {
        guard let phone = number, phone.count > 0  else {
            return (false,"Please enter phone number")
        }
        
        guard phone.count <= 15 else {
            return (false,"Please enter valid phone number")
        }
        
        return (true,"")
    }
    static public func validateAge(age: String) -> (Bool,String) {
        let personAge = Int(age)
        
        guard age.count > 0  else {
            return (false,"Please enter age.")
        }
        guard age.count <= 3  else {
            return (false,"Please enter valid age.")
        }
        guard personAge != 0  else {
            return (false,"Please enter valid age.")
        }
        
        
        return (true,"")
    }
    
    static public func validatePassword(password:String?,oldPassword:String?, val:String = "") -> (Bool,String) {
        guard let pwd = password, pwd.count > 0 else {
            return (false,"Please enter your \(val)password")
        }
        guard pwd.count >= 6 else {
            return (false, "\(val)Password should be 6 characters long")
        }
        
        guard pwd != oldPassword else {
            return (false, "Old password and new password should not be same")
        }
        
        return (true,"Please enter valid \(val)password")
    }
    
    static public func validateOldPassword(password:String?, val:String = "") -> (Bool,String) {
        guard let pwd = password, pwd.count > 0 else {
            return (false,"Please enter your \(val) password")
        }
        guard pwd.count >= 6 else {
            return (false, "\(val)Password should be 6 characters long")
        }
        return (true,"Please enter valid \(val)password")
    }

    static public func validateNewPassword(password:String?, val:String = "") -> (Bool,String) {
        guard let pwd = password, pwd.count > 0 else {
            return (false,"Please enter your \(val) password")
        }
        guard pwd.count >= 6 else {
            return (false, "\(val)Password should be 6 characters long")
        }
        return (true,"Please enter valid \(val)password")
    }
    
    static public func validateConfirmPassword(password:String?,confirmPass: String?, val:String = "") -> (Bool,String) {
        guard let pwd = confirmPass, pwd.count > 0 else {
            return (false,"Please enter your \(val) password")
        }
        
        guard pwd.count >= 6 else {
            return (false, "\(val)Password should be 6 characters long")
        }
        
        guard pwd == password else {
            return (false, "New password and \(val) password are not matching")
        }
        
        return (true,"Please enter valid \(val)password")
    }
    
    static public func validateCurrentPassword(password:String?, val:String = "") -> (Bool,String) {
        guard let pwd = password, pwd.count > 0 else {
            return (false,"Please enter your \(val)Current password")
        }
        
        guard pwd.count >= 6 else {
            return (false, "\(val)Password should be 6 characters long")
        }
        return (true,"Please enter valid \(val)password")
    }
    static public func validateOtpFiled(otp:String?, val:String = "") -> (Bool,String) {
        guard let pwd = otp, pwd.count > 0 else {
            return (false,"Please enter your \(val)one time password")
        }
        return (true,"Please enter valid \(val)Otp")
    }
  
}
