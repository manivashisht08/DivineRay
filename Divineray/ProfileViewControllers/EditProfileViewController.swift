//
//  EditProfileViewController.swift
//  Divineray
//
//  Created by     on 15/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD

class EditProfileHeder : UITableViewCell {
    //editProfileHeader
    @IBOutlet weak var editName: UITextField!
    @IBOutlet weak var btnCapture: UIButton!
    @IBOutlet weak var nameLbl: UIButton!
    @IBOutlet weak var userimage: UIImageView!
}

class EditProfileMiddle : UITableViewCell {
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtFiled: UITextField!
}

class EditProfileBottom : UITableViewCell {
    @IBOutlet weak var despTxtView: UITextView!

}

class EditProfileSave : UITableViewCell {
    @IBOutlet weak var btnSave: UIButton!

}
class EditProfileViewController: UIViewController {
    let imagePicker = UIImagePickerController()
    var imageStr = ""
    var userImageEdit:UIImage!
    var nameTxtFiled: UITextField!
    var emailTxtFiled: UITextField!
    var passwordTxtFiled: UITextField!
    var despTxtView:UITextView!
    var email = ""
    var password = ""
    var userDesp = ""

    @IBOutlet weak var tbView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tbView.delegate = self
        self.tbView.dataSource = self
        self.email = ""
        self.userDesp = ""
                  if let userData = UserDefaults.standard.value(forKey: "user_details") as? [String:Any]{
                if let description = userData["description"] as? String {
                    
                if description == "0" || description == "" || description == "N/A" {
                    self.userDesp = ""
                    }
                else  {
                    self.userDesp = description
                    }
                    }}
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
             super.viewWillAppear(animated)
             self.navigationController?.navigationBar.isHidden = false
          self.updatenavigationBar()
        
         }
         override func viewWillDisappear(_ animated: Bool) {
             super.viewWillDisappear(animated)
            self.updatenavigationBarBack()
//             self.navigationController?.navigationBar.isHidden = false
         }

    func updatenavigationBar() {
        if let navigationBar = self.navigationController?.navigationBar {
            // remove left buttons (in case you added some)
             self.navigationItem.leftBarButtonItems = []
            // hide the default back buttons
             self.navigationItem.hidesBackButton = true
            if let lblInfo = navigationBar.viewWithTag(11) as? UILabel {
            lblInfo.text = "Edit Profile"
            }
            if let btnSetting = navigationBar.viewWithTag(12) as? UIButton {
                btnSetting.isHidden = true
            }
            if let backBtn = navigationBar.viewWithTag(13) as? UIButton {
                backBtn.isHidden = false
                backBtn.addTarget(self, action: #selector(backActionEdit), for: .touchUpInside)
            }
        }
    }
    func updatenavigationBarBack(){
           if let navigationBar = self.navigationController?.navigationBar {
               if let backBtn = navigationBar.viewWithTag(13) as? UIButton {
                   backBtn.removeTarget(self, action: #selector(backActionEdit), for: .touchUpInside)
               }
           }
       }
    @objc func backActionEdit() {
        self.navigationController?.popViewController(animated: true)
    }


}
@available(iOS 14.0, *)
extension EditProfileViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 220
        }else if indexPath.row == 1 {
            return 140
        }else if indexPath.row == 2 {
            return 140
        }else if indexPath.row == 3 {
                return 100
            }
        else {
            return 0
        }
      }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell : EditProfileHeder = tableView.dequeueReusableCell(withIdentifier: "editProfileHeader") as! EditProfileHeder
            cell.btnCapture.addTarget(self, action: #selector(openPhotoPicker), for: .touchUpInside)
            if self.userImageEdit != nil {
                cell.userimage.image = self.userImageEdit
            }else {
                if let userData = UserDefaults.standard.value(forKey: "user_details") as? [String:Any]{
                        if let name = userData["name"] as? String {
//                            cell.nameLbl.setTitle(name.uppercased(), for: .normal)
                            self.nameTxtFiled = cell.editName
                            cell.editName.text = name
                            self.nameTxtFiled.text = name
                            self.nameTxtFiled.delegate = self;
                        }
                    if let profilePic = userData["photo"] {
                        let url = URL(string: (profilePic as! String))
                        cell.userimage.kf.setImage(with: url, placeholder:UIImage(named: "user"))
                    }
                }
            }
            return cell
        }else if indexPath.row == 1 {
            let cell : EditProfileMiddle = tableView.dequeueReusableCell(withIdentifier: "editProfileMiddle") as! EditProfileMiddle
            self.emailTxtFiled = cell.emailTxtField
            self.passwordTxtFiled = cell.passwordTxtFiled
            self.emailTxtFiled.delegate = self
            self.passwordTxtFiled.delegate = self
            self.emailTxtFiled.returnKeyType = .next
            self.emailTxtFiled.keyboardType = .emailAddress
            self.emailTxtFiled.isUserInteractionEnabled = false

            if let userData = UserDefaults.standard.value(forKey: "user_details") as? [String:Any]{
            if var emailvalue = userData["email"] as? String {
                if emailvalue == "N/A" {
                    emailvalue = ""
                }
                if emailvalue == "" {
                    self.emailTxtFiled.isUserInteractionEnabled = true
                }else {
                    self.emailTxtFiled.text = emailvalue
                }
                }
            }

        return cell
                }
        else if indexPath.row == 2 {
            let cell :EditProfileBottom = tableView.dequeueReusableCell(withIdentifier: "editProfileBottom") as! EditProfileBottom
            self.despTxtView = cell.despTxtView
            
            self.despTxtView.text = self.userDesp
            self.despTxtView.keyboardType = .asciiCapable
            self.despTxtView.delegate = self
            
        return cell
        }else {
            let cell : EditProfileSave = tableView.dequeueReusableCell(withIdentifier: "editProfileSave") as! EditProfileSave
            cell.btnSave.addTarget(self, action: #selector(saveActionCall), for: .touchUpInside)
            
            return cell
        }
    }
    @objc func saveActionCall() {
        self.nameTxtFiled.resignFirstResponder()
        self.emailTxtFiled.resignFirstResponder()
        self.passwordTxtFiled.resignFirstResponder()
        self.despTxtView.resignFirstResponder()
        if let errorMessage = self.validateUserFields() {
        self.showToastMessage(errorMessage)
            return
                           }
        if let errorMessage = self.validateEmailFields() {
                   self.showToastMessage(errorMessage)
                   return
               }
        if self.passwordTxtFiled.text?.count ?? 0 > 0 {
      if let errorMessage = self.validatePasswordFields() {
                        self.showToastMessage(errorMessage)
                        return
                    }
        }
       if let errorMessage = self.validateDespFields() {
                              self.showToastMessage(errorMessage)
                              return
                          }
        let params:[String:Any] = [
            "name":nameTxtFiled.text!,"email": emailTxtFiled.text!,"password": passwordTxtFiled.text!,"photo":self.imageStr,"user_id":ApplicationStates.getUserID(),"description":self.despTxtView.text ?? ""
        ]
        
        SVProgressHUD.show()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.editUserProfileURL, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                                   SVProgressHUD.dismiss()
                               }
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            if let data =  result["data"] as? [String : Any] {
                                let aa = data.filter { !($0.value is NSNull) }
                                ApplicationStates.setUserData(Info:  aa)
                            }
                           if let msg = result["message"] as? String{
                            let optionMenu = UIAlertController(title: API.appName, message: msg, preferredStyle: .alert)
                            let logoutAction = UIAlertAction(title: "OK", style: .default, handler: {
                                (alert: UIAlertAction!) -> Void in
                                self.backActionEdit()
                            })
                            optionMenu.addAction(logoutAction)
                            self.present(optionMenu, animated: true, completion: nil)
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
    }
    func validateEmailFields() ->String? {
                var err:String? = nil
                do {
                    _ = try self.emailTxtFiled.validatedText(validationType: ValidatorType.email)
                } catch(let error) {
                    err = (error as! ValidationError).message
                }
                return err
            }
          func validatePasswordFields() ->String? {
                   var err:String? = nil
                   do {
                       _ = try self.passwordTxtFiled.validatedText(validationType: ValidatorType.password)
                   } catch(let error) {
                       err = (error as! ValidationError).message
                   }
                   return err
               }
       func validateDespFields() ->String? {
                var err:String? = nil
                do {
                    _ = try self.despTxtView.text.validatedText(validationType: ValidatorType.aboutProfile)
                } catch(let error) {
                    err = (error as! ValidationError).message
                }
                return err
            }
    func validateUserFields() ->String? {
        var err:String? = nil
        do {
            _ = try self.nameTxtFiled.validatedText(validationType: ValidatorType.username)
        } catch(let error) {
            err = (error as! ValidationError).message
        }
        return err
    }
}
extension EditProfileViewController : UITextFieldDelegate , UITextViewDelegate{
   func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
       let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
       let numberOfChars = newText.count
       if numberOfChars == 0 && text == " " {
           return false
       }
       if numberOfChars > 180 {
           return false
       }
       return true
   }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // return NO to not change text
        let maxLength = 30
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length == 1 && newString == " " {
            return false
        }
        if newString.length == 0 && newString == " " {
                   return false
               }
        return newString.length <= maxLength
            }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTxtFiled {
            self.passwordTxtFiled.becomeFirstResponder()
        }else {
        textField.resignFirstResponder()
        }
        return true
    }
    
}
extension EditProfileViewController  : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func openPhotoPicker() {
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
            //print("Cancelled")
        })
        optionMenu.addAction(galleryAction)
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
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
    
    func noCamera() {
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
                self.userImageEdit = image
                let imageData:Data = image.jpegData(compressionQuality: 0.7)!
                self.imageStr = imageData.base64EncodedString(options: .lineLength64Characters)
            } else if let image = info[.originalImage] as? UIImage {
                self.userImageEdit = image
                let imageData:Data = image.jpegData(compressionQuality: 0.7)!
                self.imageStr = imageData.base64EncodedString(options: .lineLength64Characters)
            }
            imagePicker .dismiss(animated: true, completion: nil)
            self.tbView.reloadData()
        }
    
}
