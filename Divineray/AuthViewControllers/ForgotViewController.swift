//
//  ForgotViewController.swift
//  Divineray
//
//  Created by     on 11/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
@available(iOS 14.0, *)
class ForgotViewController: UIViewController {
    
    @IBOutlet weak var txtEmailField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        txtEmailField.delegate = self
        txtEmailField.returnKeyType = .default
        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        txtEmailField.resignFirstResponder()
        if let errorMessage = self.validateEmailFields() {
            self.showToastMessage(errorMessage)
            return
        }
        
        SVProgressHUD.show()
        let params:[String:Any] = [
            "email": txtEmailField.text!]
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.recoverpasswordURL, postData: params) { (result) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            switch (result) {
            case .success(let json):
                
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            if let msg = result["message"] as? String {
                                self.showMessage(title: API.appName, message: msg, okButton: "OK", cancelButton: "", controller: self, okHandler: {
                                    self.navigationController?.popViewController(animated: true)
                                }) {
                                    
                                }
                            }else {
                                if let msg = result["message"] as? String{
                                    self.showAlertWith(title:API.appName, message:msg)
                                }
                            }
                        }else {
                            if let msg = result["message"] as? String{
                                self.showAlertWith(title:API.appName, message:msg)
                            }
                        }
                    }else {
                        if let msg = result["message"] as? String{
                            self.showAlertWith(title:API.appName, message:msg)
                        }
                    }
                    
                    
                } else {
                    self.showAlertWith(title:API.appName, message:AlertMessages.GeneralErrorMsg)
                }
                break
            case .failure(let error):
                self.showAlertWith(title:API.appName, message:error)
                
                break;
            }
        }
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
}
@available(iOS 14.0, *)
extension ForgotViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // return NO to not change text
        let maxLength = 150
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
