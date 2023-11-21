//
//  SignupViewController.swift
//  Divineray
//
//  Created by     on 11/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
@available(iOS 14.0, *)

class SignupViewController: UIViewController {
  
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var txtNameField: UITextField!
    @IBOutlet weak var txtEmailField: UITextField!
    @IBOutlet weak var txtPasswordField: UITextField!
    @IBOutlet weak var termsAndConditionBtn: UIButton!

    let imagePicker = UIImagePickerController()
    var imageStr = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        txtNameField.delegate = self
        txtEmailField.delegate = self
        txtPasswordField.delegate = self
        
        txtNameField.returnKeyType = .next
        txtEmailField.returnKeyType = .next
        txtPasswordField.returnKeyType = .default
    }
    
    
    @IBAction func termsAndConditionBtnAction(_ sender: Any) {
        self.termsAndConditionBtn.isSelected.toggle()
    }
    
    @IBAction func opneTermsAndConditionBtnAction(_ sender: Any) {
        let inAppBrowserViewController : InAppBrowserViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InAppBrowserViewController") as! InAppBrowserViewController
        inAppBrowserViewController.optionFrom = 2
        self.present(inAppBrowserViewController, animated: true)
    }
    
    @IBAction func signuptextField(_ sender: Any) {
        txtNameField.resignFirstResponder()
        txtEmailField.resignFirstResponder()
        txtPasswordField.resignFirstResponder()
        let email =  txtEmailField.text!
        
        if imageStr == "" {
            self.showToastMessage("Please add profile image")
            return
        }
        if let errorMessage = self.validateUserFields() {
            self.showToastMessage(errorMessage)
            return
        }
        
        if email.isEmpty {
            self.showToastMessage("Please enter email address")
            return
        }
        if let errorMessage = self.validateEmailFields() {
            self.showToastMessage(errorMessage)
            return
        }
        if let errorMessage = self.validatePasswordFields() {
            self.showToastMessage(errorMessage)
            return
        }
        if self.termsAndConditionBtn.isSelected == false{
            self.showToastMessage("Please agree with terms and conditions")
            return
        }
        
        var deviceToken  = UserDefaults.standard.value(forKey: "device_token")
        if deviceToken == nil  {
            deviceToken = "simlator"
        }
        
        let params:[String:Any] = [
            "name": txtNameField.text!,"email": txtEmailField.text!,"password": txtPasswordField.text!,"device_type":"1","device_token":deviceToken ?? "","photo":self.imageStr
        ]
        SVProgressHUD.show()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.signupURL, postData: params) { (result) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            
            switch (result) {
            case .success(let json):
                
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
                        else if status == 2 {
                            if let msg = result["message"] as? String{
                                self.signupMailVerify(msg: msg)
                                return
                            }
                        }
                    }
                    if let msg = result["message"] as? String{
                        self.showAlertWith(title:API.appName, message:msg)
                    }
                    
                }
                else {
                    self.showAlertWith(title:API.appName, message:AlertMessages.GeneralErrorMsg)
                }
                break
            case .failure(let error):
                self.showAlertWith(title:API.appName, message:error)
                break;
            }
        }
    }
    func signupMailVerify(msg:String) {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(
                title: API.appName,
                message: msg,
                preferredStyle: .alert)
            let okAction = UIAlertAction(
                title: "OK",
                style:.default,
                handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.navigationController?.popViewController(animated: true)
                })
            alertVC.addAction(okAction)
            self.present(
                alertVC,
                animated: true,
                completion: nil)
        }
    }
    func validateUserFields() ->String? {
        var err:String? = nil
        do {
            _ = try self.txtNameField.validatedText(validationType: ValidatorType.username)
        } catch(let error) {
            err = (error as! ValidationError).message
        }
        return err
    }
    func validateEmailFields() ->String? {
        var err:String? = nil
        do {
            _ = try self.txtEmailField.validatedText(validationType: ValidatorType.email)
        } catch(let error) {
            err = (error as! ValidationError).message
        }
        return err
    }
    func validatePasswordFields() ->String? {
        var err:String? = nil
        do {
            _ = try self.txtPasswordField.validatedText(validationType: ValidatorType.password)
        } catch(let error) {
            err = (error as! ValidationError).message
        }
        return err
    }
    func validateNameFields() ->String? {
        var err:String? = nil
        do {
            _ = try self.txtPasswordField.validatedText(validationType: ValidatorType.username)
        } catch(let error) {
            err = (error as! ValidationError).message
        }
        return err
    }
    
    @IBAction func signInAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addPhotoAction(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Choose An Action", preferredStyle: .actionSheet)
        let galleryAction = UIAlertAction(title: "Gallery", style: .default, handler:
                                            {
            (alert: UIAlertAction!) -> Void in
            self.openGallary()
        })
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler:
                                            {
            (alert: UIAlertAction!) -> Void in
            self.openCamera()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
                                            {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(galleryAction)
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
}
@available(iOS 14.0, *)

extension SignupViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // return NO to not change text
        let maxLength = 30
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
        currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length == 1 && newString == " " {
            return false
        }
        if textField == self.txtPasswordField && newString == " " {
            return false
        }
        if textField == self.txtEmailField && newString == " " {
            return false
        }
        return newString.length <= maxLength
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtNameField {
            txtEmailField.becomeFirstResponder()
        }else if textField == txtEmailField {
            txtPasswordField.becomeFirstResponder()
        }else {
            textField.resignFirstResponder()
        }
        return true
    }
}
@available(iOS 14.0, *)

extension SignupViewController  : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            imagePicker.modalPresentationStyle = .fullScreen;
            self .present(imagePicker, animated: true, completion: nil)
        }else{
            let alertVC = UIAlertController(
                title: "No Camera",
                message: "Sorry, this device has no camera",
                preferredStyle: .alert)
            let okAction = UIAlertAction(
                title: "OK",
                style:.default,
                handler: nil)
            alertVC.addAction(okAction)
            present(
                alertVC,
                animated: true,
                completion: nil)
        }
    }
    
    func openGallary(){
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen;
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        self.present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[.editedImage] as? UIImage {
            userImageView.image = image
            let imageData:Data = image.jpegData(compressionQuality: 0.7)!
            self.imageStr = imageData.base64EncodedString(options: .lineLength64Characters)
        }else if let image = info[.originalImage] as? UIImage {
            userImageView.image = image
            let imageData:Data = image.jpegData(compressionQuality: 0.7)!
            self.imageStr = imageData.base64EncodedString(options: .lineLength64Characters)
        }
        imagePicker .dismiss(animated: true, completion: nil)
    }
}
