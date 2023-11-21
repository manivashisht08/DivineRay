import Foundation

class ValidationError: Error {
    var message: String
    
    init(_ message: String) {
        self.message = message
    }
}

protocol ValidatorConvertible {
    func validated(_ value: String) throws -> String
}

enum ValidatorType {
    case username
    case mobile
    case email
    case emailC
    case password
    case confirmPassword
    case address
    case qualification
    case batchqualification
    case instituteName
    case universityName
    case universityAddress
    case pickerAddress
    case pickerDefinition
    case areaofActivity
    case designation
    case organisation
    case aboutProfile
    case nameMobile
    case postTitle
    case postDescription
    case areaofexpertise
    case hospital
    case occupation
    case nameOfCompany
    case country
    case gender
    
    
}

enum VaildatorFactory {
    static func validatorFor(type: ValidatorType) -> ValidatorConvertible {
        switch type {
        case .username: return UserNameValidator()
        case .mobile: return MobileValidator()
        case .email: return EmailValidator()
        case .emailC: return EmailCValidator()
        case .password: return PasswordValidator()
        case .confirmPassword: return ConfirmPasswordValidator()
        case .address: return AddressValidator()
        case .qualification: return QualificationValidator()
        case .batchqualification: return BatchqualificationValidator()
        case .instituteName: return InstituteNameValidator()
        case .universityName: return UniversityNameValidator()
        case .universityAddress: return UniversityAddressValidator()
        case .pickerAddress: return PickerAddressValidator()
        case .pickerDefinition: return DefinitionValidator()
        case .areaofActivity: return AreaofActivityValidator()
        case .designation: return DesignationValidator()
        case .organisation: return OrganisationValidator()
        case .aboutProfile: return AboutProfileValidator()
        case .nameMobile: return NameMobileProfileValidator()
        case .postTitle: return PostTitleValidator()
        case .postDescription: return PostMessageValidator()
        case .areaofexpertise: return AreaOfExpertiseMessageValidator()
        case .hospital: return HospitalMessageValidator()
        case .occupation:  return OccupationValidator()
        case .nameOfCompany:  return NameOfCompanyValidator()
        case .country :  return CountryValidator()
        case .gender :  return GenderValidator()
            
        }
    }
}

struct UserNameValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value.count >= 1 else {
            throw ValidationError("Please enter the name" )
        }
        guard value.count < 31 else {
            throw ValidationError("Name shoudn't contain more than 30 characters" )
        }
        return value
    }
}

struct MobileValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please enter the valid mobile number" )
        }
        return value
    }
}

struct EmailValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        if value != ""{
            do {
                let emailRegex = try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$", options: .caseInsensitive)
                let textRange = NSRange(location: 0, length: value.count)
                if emailRegex.firstMatch(in: value, options: [], range: textRange) == nil {
                    throw ValidationError("Please enter correct email address.")
                }
            } catch  {
                throw ValidationError("Please enter correct email address.")
            }
        }
        else{
            throw ValidationError("Please enter email address.")
        }
        
        return value
    }
}
struct EmailCValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        if value != ""{
            do {
                let emailRegex = try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$", options: .caseInsensitive)
                let textRange = NSRange(location: 0, length: value.count)
                if emailRegex.firstMatch(in: value, options: [], range: textRange) == nil {
                    throw ValidationError("Please enter correct confirm email address.")
                }
            } catch  {
                throw ValidationError("Please enter correct confirm email address.")
            }
        }
        else{
            throw ValidationError("Please enter confirm email address.")
        }
        
        return value
    }
}

struct PasswordValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value != "" else {throw ValidationError("Password is Required")}
        guard value.count >= 2 else { throw ValidationError("Password must have at least 2 characters") }
        return value
    }
}

struct ConfirmPasswordValidator: ValidatorConvertible {
    
    func validated(_ value: String) throws -> String {
        guard value != "" else {throw ValidationError("Confirm Password is Required")}
        guard value.count >= 2 else { throw ValidationError("Confirm Password must have at least 2 characters") }
        return value
    }
}

struct AddressValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value.count >= 3 else {
            throw ValidationError("Address must contain more than three characters" )
        }
        guard value.count < 100 else {
            throw ValidationError("Address shoudn't conain more than 100 characters" )
        }
        return value
    }
}

struct QualificationValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please enter the Qualification" )
        }
        return value
    }
}

struct AreaofActivityValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please enter the Area of Activity" )
        }
        return value
    }
}

struct DesignationValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please enter the Designation" )
        }
        return value
    }
}

struct NameMobileProfileValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please enter the Name/Mobile" )
        }
        return value
    }
}


struct OrganisationValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please enter the Organisation" )
        }
        return value
    }
}

struct AboutProfileValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please enter the Profile Description" )
        }
        return value
    }
}


struct BatchqualificationValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        let items = value.components(separatedBy: "-")
        guard items.count == 2, items.first?.count == 4, items.last?.count == 4 else {
            throw ValidationError("Please enter the Batch of Qualification in yyyy-yyyy" )
        }
        return value
    }
}

struct InstituteNameValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please enter the Institute Name" )
        }
        return value
    }
}

struct UniversityNameValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please enter the University Name" )
        }
        return value
    }
}

struct UniversityAddressValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please enter the University Address" )
        }
        return value
    }
}

struct PickerAddressValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please select a interest")
        }
        return value
    }
}

struct DefinitionValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please define text")
        }
        return value
    }
}

struct PostTitleValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please enter the title")
        }
        return value
    }
}

struct PostMessageValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please enter the message")
        }
        return value
    }
}

struct AreaOfExpertiseMessageValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please enter Area Of Expertise")
        }
        return value
    }
}

struct HospitalMessageValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please enter Hospital/Health institute where practising")
        }
        return value
    }
}

struct OccupationValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please enter the Occupation")
        }
        return value
    }
}

struct NameOfCompanyValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please enter the name of company")
        }
        return value
    }
}

struct CountryValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please choose the country")
        }
        return value
    }
}

struct GenderValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Please choose the gender")
        }
        return value
    }
}

