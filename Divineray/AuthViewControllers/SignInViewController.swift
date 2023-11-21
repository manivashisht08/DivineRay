//
//  SignInViewController.swift
//  Divineray
//
//  Created by     on 08/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
import FBSDKLoginKit
import AuthenticationServices
import Firebase

@available(iOS 14.0, *)
class SignInViewController: UIViewController {
    @IBOutlet weak var appleloginView: UIView!
    @IBOutlet weak var emailViewC: NSLayoutConstraint!
    @IBOutlet weak var btView: UIView!
    
    @IBOutlet weak var orp1: NSLayoutConstraint!
    @IBOutlet weak var orLbl: UILabel!
    @IBOutlet weak var orp2: NSLayoutConstraint!
    
    @IBOutlet weak var btViewConst: NSLayoutConstraint!
    @IBOutlet weak var topLogoConst: NSLayoutConstraint!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtpassword: UITextField!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        topLogoConst.constant = 130
        if #available(iOS 13.0, *) {
            self.appleloginView.isHidden = false
        }else {
            self.appleloginView.isHidden = true
        }
        
        if let height = UIApplication.shared.keyWindow?.frame.size.height {
            if  height <= 667 {
                topLogoConst.constant = 0
            }
            else if  height <= 736.0 {
                topLogoConst.constant = 70
            }
        }
        txtEmail.delegate = self
        txtpassword.delegate = self
        txtEmail.returnKeyType = .next
        txtpassword.returnKeyType = .default
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonpressed(_ sender: Any) {
        txtEmail.resignFirstResponder()
        txtpassword.resignFirstResponder()
        if let errorMessage = self.validateEmailFields() {
            self.showToastMessage(errorMessage)
            return
        }
        if let errorMessage = self.validatePasswordFields() {
            self.showToastMessage(errorMessage)
            return
        }
        var deviceToken  = UserDefaults.standard.value(forKey: "device_token")
        if deviceToken == nil  {
            deviceToken = "simlator"
        }
        let params:[String:Any] = [
            "email": txtEmail.text!,"password": txtpassword.text!,"device_type":"1","device_token":deviceToken ?? "simlator"
        ]
        SVProgressHUD.show()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.signInURL, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            let userDetail = result["data"] as! [String : Any]
                            let aa = userDetail.filter { !($0.value is NSNull) }
                            ApplicationStates.setUserData(Info:  aa as [String : Any])
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.loginSucess()
                            return
                        }
                    }
                    if let msg = result["message"] as? String{
                        self.showAlertWith(title:API.appName, message:msg)
                    }
                    
                } else {
                    self.showAlertWith(title:API.appName, message:AlertMessages.GeneralErrorMsg)
                }
                break
            case .failure(let error):
                self.showAlertWith(title:API.appName, message:error)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                break;
            }
        }
    }
    func validateEmailFields() ->String? {
        var err:String? = nil
        do {
            _ = try self.txtEmail.validatedText(validationType: ValidatorType.email)
        } catch(let error) {
            err = (error as! ValidationError).message
        }
        return err
    }
    func validatePasswordFields() ->String? {
        var err:String? = nil
        do {
            _ = try self.txtpassword.validatedText(validationType: ValidatorType.password)
        } catch(let error) {
            err = (error as! ValidationError).message
        }
        return err
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        let storyboard = UIStoryboard(storyboard: .main)
        let signUp = storyboard.instantiateViewController(withIdentifier: "SignupViewController")
        self.navigationController?.pushViewController(signUp, animated: true)
    }
    @IBAction func fbLoginAction(_ sender: Any) {
        
        let login = LoginManager()
        login.logIn(permissions: ["public_profile","email"], from: self) { (result, error) in
            if error != nil {
            }else {
                if let token = result?.token?.tokenString {
                    SVProgressHUD.show()
                    guard let accessToken = FBSDKLoginKit.AccessToken.current else { return }
                    let graphRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                                  parameters: ["fields": "email, name"],
                                                                  tokenString: accessToken.tokenString,
                                                                  version: nil,
                                                                  httpMethod: .get)
                    graphRequest.start { (connection, resultInfo, error) -> Void in
                        if error == nil {
                            if let dict = resultInfo as? NSDictionary {
                                self.faceBookLoginServiceCall(email: dict["email"] as! String, name: dict["name"] as! String, fbID: dict["id"] as! String)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func appleLoginServiceCall(email:String,name:String,appleID:String) {
        txtEmail.resignFirstResponder()
        txtpassword.resignFirstResponder()
        
        var deviceToken  = UserDefaults.standard.value(forKey: "device_token")
        if deviceToken == nil  {
            deviceToken = "simlator"
        }
        
        let params:[String:Any] = [
            "email": email,"name": name,"appleId":appleID,"device_type":"1","device_token":deviceToken ?? "simlator"
        ]
        
        SVProgressHUD.show()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.appleLoginURL, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            let userDetail = result["data"] as! [String : Any]
                            let aa = userDetail.filter { !($0.value is NSNull) }
                            ApplicationStates.setUserData(Info:  aa )
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.loginSucess()
                            return
                        }
                    }
                    if let msg = result["message"] as? String{
                        self.showAlertWith(title:API.appName, message:msg)
                    }
                    
                } else {
                    self.showAlertWith(title:API.appName, message:AlertMessages.GeneralErrorMsg)
                }
                break
            case .failure(let error):
                self.showAlertWith(title:API.appName, message:error)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                break;
            }
        }
        
    }
    
    @IBAction func twitterLoginAction(_ sender: Any) {
        
        let provider = OAuthProvider(providerID: "twitter.com",auth: .auth())
        provider.customParameters = [
            "lang": "fr",
            "redirect_uri":"https://divineray-e79c7.firebaseapp.com/__/auth/handler"
        ]

        provider.getCredentialWith(nil) { credential, error in
            if error != nil {
                // Handle error.
                if let msg : String = error?.localizedDescription  {
                    if msg != "The interaction was cancelled by the user." {
                        self.showAlertWith(title:API.appName, message:error?.localizedDescription ?? "")
                        
                    }
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                }
                return;
                
            }
            SVProgressHUD.show()
            if let ctr = credential  {
                Auth.auth().signIn(with: ctr) { authResult, error in
                    if error != nil {
                        // Handle error.
                        self.showAlertWith(title:API.appName, message:error?.localizedDescription ?? "")
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                        }
                        return
                    }
                    
                    var twitterID = authResult?.additionalUserInfo?.profile?["id_str"] as? String ?? ""
                    if twitterID == "" {
                        if let idInt = authResult?.additionalUserInfo?.profile?["id"] as? Int {
                            twitterID =  String(idInt)
                        }
                    }
                    self.twitterLoginServiceCall(email: authResult?.additionalUserInfo?.profile?["email"] as? String ?? "", name: authResult?.additionalUserInfo?.profile?["name"] as? String ?? "", twitterId: twitterID, imageUrl: authResult?.additionalUserInfo?.profile?["profile_image_url"] as? String ?? "")
                }
            }
        }
    }
    
    func twitterLoginServiceCall(email:String,name:String,twitterId:String,imageUrl:String) {
        txtEmail.resignFirstResponder()
        txtpassword.resignFirstResponder()
        
        var deviceToken  = UserDefaults.standard.value(forKey: "device_token")
        if deviceToken == nil  {
            deviceToken = "simlator"
        }
        let params:[String:Any] = [
            "email": email,"name": name,"twitterId":twitterId,"device_type":"1","device_token":deviceToken ?? "simlator"
        ]
        SVProgressHUD.show()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.twitterLogin, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            let userDetail = result["data"] as! [String : Any]
                            let aa = userDetail.filter { !($0.value is NSNull) }
                            ApplicationStates.setUserData(Info:  aa )
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.loginSucess()
                            return
                        }
                    }
                    if let msg = result["message"] as? String{
                        self.showAlertWith(title:API.appName, message:msg)
                    }
                    
                } else {
                    self.showAlertWith(title:API.appName, message:AlertMessages.GeneralErrorMsg)
                }
                break
            case .failure(let error):
                self.showAlertWith(title:API.appName, message:error)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                break;
            }
        }
        
    }
    
    @IBAction func appleLogin(_ sender: Any) {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        } else {
            DispatchQueue.main.async {
                self.showAlertWith(title:API.appName, message:"Apple login support in iOS 13 and above")
            }            }
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        let storyboard = UIStoryboard(storyboard: .main)
        let fogPassword = storyboard.instantiateViewController(withIdentifier: "ForgotViewController")
        self.navigationController?.pushViewController(fogPassword, animated: true)
    }
    
}
@available(iOS 14.0, *)

extension SignInViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // return NO to not change text
        let maxLength = 150
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
        currentString.replacingCharacters(in: range, with: string) as NSString
        if textField == self.txtEmail && newString == " " {
            return false
        }
        if textField == self.txtpassword && newString == " " {
            return false
        }
        
        return newString.length <= maxLength
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtEmail {
            txtpassword.becomeFirstResponder()
        }else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    
}

@available(iOS 14.0, *)
extension SignInViewController : ASAuthorizationControllerDelegate {
    
//    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            if let email = appleIDCredential.email {
                self.appleLoginServiceCall(email: email, name: fullName?.fullName ?? "", appleID: userIdentifier)
            }else {
                self.appleLoginServiceCall(email: "", name: fullName?.fullName ?? "", appleID: userIdentifier)
            }
        }
    }
//    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {

    }
    func faceBookLoginServiceCall(email:String,name:String,fbID:String) {
        txtEmail.resignFirstResponder()
        txtpassword.resignFirstResponder()
        
        var deviceToken  = UserDefaults.standard.value(forKey: "device_token")
        if deviceToken == nil  {
            deviceToken = "simlator"
        }
        let params:[String:Any] = [
            "email": email,"name": name,"facebookId":fbID,"device_type":"1","device_token":deviceToken ?? "simlator"
        ]
        SVProgressHUD.show()
        if #available(iOS 14.0, *) {
            SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.facebookLoginURL, postData: params) { (result) -> Void in
                switch (result) {
                case .success(let json):
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                    if let result:[String:Any] = json as? Dictionary {
                        if let status = result["status"] as? Int {
                            if status == 1 {
                                let userDetail = result["data"] as! [String : Any]
                                let aa = userDetail.filter { !($0.value is NSNull) }
                                ApplicationStates.setUserData(Info:  aa )
                                if #available(iOS 14.0, *) {
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    appDelegate.loginSucess()
                                    
                                } else {
                                    // Fallback on earlier versions
                                }
                                return
                            }
                        }
                        if let msg = result["message"] as? String{
                            self.showAlertWith(title:API.appName, message:msg)
                        }
                        
                    } else {
                        self.showAlertWith(title:API.appName, message:AlertMessages.GeneralErrorMsg)
                    }
                    break
                case .failure(let error):
                    self.showAlertWith(title:API.appName, message:error)
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                    break;
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
}

extension PersonNameComponents {
    var fullName: String {
        return [givenName, middleName, familyName].compactMap{ $0 }.joined(separator: " ")
    }
    
    var fullNameWithSuffix: String {
        return [givenName, middleName, familyName, nameSuffix].compactMap{ $0 }.joined(separator: " ")
    }
    
    var initials: String {
        let firstName = givenName?.first ?? Character(" ")
        let lastName = familyName?.first ?? Character(" ")
        return "\(firstName)\(lastName)".trimmingCharacters(in: .whitespaces)
    }
}
