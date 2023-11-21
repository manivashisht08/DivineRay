//
//  SettingsViewController.swift
//  Divineray
//
//  Created by     on 15/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD

@available(iOS 14.0, *)
class SettingsViewController: UIViewController {
    private let kProfileSettingHeaderTableViewCell = "ProfileSettingHeaderTableViewCell"
    private let kSettingsIdentifier = "SettingsTableViewCell"
    var isNotifictionON = "1"
    
    @IBOutlet weak var tbView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userData = UserDefaults.standard.value(forKey: "user_details") as? [String:Any]{
            if let isNotification = userData["allowPush"] as? String {
                self.isNotifictionON = isNotification
            }
        }
        self.registerNib()
        self.tbView.delegate = self
        self.tbView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    func registerNib(){
        let nibhView = UINib(nibName: kProfileSettingHeaderTableViewCell, bundle: nil)
        self.tbView.register(nibhView, forCellReuseIdentifier: kProfileSettingHeaderTableViewCell)
        
        let nibImgView = UINib(nibName: kSettingsIdentifier, bundle: nil)
        self.tbView.register(nibImgView, forCellReuseIdentifier: kSettingsIdentifier)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.updatenavigationBar()
        self.tbView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.updatenavigationBarBack()
        self.navigationController?.navigationBar.isHidden = true
    }
    func updatenavigationBar(){
        if let navigationBar = self.navigationController?.navigationBar {
            // remove left buttons (in case you added some)
            self.navigationItem.leftBarButtonItems = []
            // hide the default back buttons
            self.navigationItem.hidesBackButton = true
            
            if let lblInfo = navigationBar.viewWithTag(11) as? UILabel {
                lblInfo.text = "Settings"
            }
            if let btnSetting = navigationBar.viewWithTag(12) as? UIButton {
                btnSetting.setImage(UIImage(named: "notT"), for: .normal)
                btnSetting.isHidden = false
                btnSetting.addTarget(self, action: #selector(notAction), for: .touchUpInside)

            }
            if let backBtn = navigationBar.viewWithTag(13) as? UIButton {
                backBtn.isHidden = false
                backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
                
            }
        }
    }
    
    func updatenavigationBarBack(){
        if let navigationBar = self.navigationController?.navigationBar {
            if let backBtn = navigationBar.viewWithTag(13) as? UIButton {
                backBtn.removeTarget(self, action: #selector(backAction), for: .touchUpInside)
            }
        }
    }
    @objc func notAction() {
        let notificationViewController : NotificationViewController = NotificationViewController(nibName: "NotificationViewController", bundle: nil)
        notificationViewController.isFromPush = false
            notificationViewController.notificationInfo = nil
        self.navigationController?.pushViewController(notificationViewController, animated: true)
    }
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}
@available(iOS 14.0, *)

extension SettingsViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }else {
            return 40
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let hv = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
            hv.backgroundColor = UIColor.clear
            return hv
        }else {
            let hv = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
            
            hv.backgroundColor = UIColor.clear
            
            let lbl = UILabel.init(frame: CGRect(x: 20, y: 0, width: self.view.frame.size.width-20, height: 40))
            hv.addSubview(lbl)
            lbl.text = "ACCOUNT";
            lbl.textColor = UIColor.init(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.7)
            lbl.font = UIFont(name: "Poppins-Regular", size: 17)
            return hv
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
        return 8
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
        guard let cell : SettingsTableViewCell = tableView.dequeueReusableCell(withIdentifier: kSettingsIdentifier, for: indexPath) as? SettingsTableViewCell else {
            fatalError("Unable to Dequeue Reusable Table View Cell")
        }
        cell.switchNotifi.isHidden = true
        cell.iconArrow.isHidden = false
        if indexPath.row == 0 {
            cell.nameLbl.text = "Edit Profile"
            cell.iconImg.image = UIImage(named: "edit")
        }
        else if indexPath.row == 1 {
            cell.nameLbl.text = "View Notification"
            cell.switchNotifi.isHidden = false
            cell.iconArrow.isHidden = true
            cell.iconImg.image = UIImage(named: "not")
            if self.isNotifictionON == "1" {
                cell.switchNotifi.isOn = true
            }else {
                cell.switchNotifi.isOn = false;
            }
            cell.switchNotifi.addTarget(self, action: #selector(notificationOnOFFService), for: .valueChanged)
        }else if indexPath.row == 2 {
            cell.nameLbl.text = "Your Activity"
            cell.iconImg.image = UIImage(named: "activity")
        }
        
        else if indexPath.row == 3 {
            cell.nameLbl.text = "Privacy Policy"
            cell.iconImg.image = UIImage(named: "privcay")
        }
        else if indexPath.row == 4 {
            cell.nameLbl.text = "Terms of Use"
            cell.iconImg.image = UIImage(named: "terms")
        }
        else if indexPath.row == 5 {
            cell.nameLbl.text = "Contact Us"
            cell.iconImg.image = UIImage(named: "call")
        }else if indexPath.row == 6 {
            cell.nameLbl.text = "About Us"
            cell.iconImg.image = UIImage(named: "users")
        }
        else if indexPath.row == 7 {
            cell.nameLbl.text = "Delete Acount"
            cell.iconImg.image = UIImage(systemName: "person.fill.xmark")
        }
        else if indexPath.row == 8 {
            cell.nameLbl.text = "Logout"
            cell.iconImg.image = UIImage(named: "log")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let editProfileViewController : EditProfileViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
                self.navigationController?.pushViewController(editProfileViewController, animated: true)
            }
            else  if indexPath.row == 1 {
                //"View Notifications"
                let notificationViewController : NotificationViewController = NotificationViewController(nibName: "NotificationViewController", bundle: nil)
                notificationViewController.isFromPush = false
                notificationViewController.notificationInfo = nil
                self.navigationController?.pushViewController(notificationViewController, animated: true)
            }else if indexPath.row == 2 {
                let vc : ActivityVC  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ActivityVC") as! ActivityVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if indexPath.row == 3 {
                let inAppBrowserViewController : InAppBrowserViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InAppBrowserViewController") as! InAppBrowserViewController
                inAppBrowserViewController.optionFrom = 1
                self.navigationController?.pushViewController(inAppBrowserViewController, animated: true)
            }
            else if indexPath.row == 4 {
                let inAppBrowserViewController : InAppBrowserViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InAppBrowserViewController") as! InAppBrowserViewController
                inAppBrowserViewController.optionFrom = 2
                self.navigationController?.pushViewController(inAppBrowserViewController, animated: true)
            }
            else if indexPath.row == 5 {
                let inAppBrowserViewController : InAppBrowserViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InAppBrowserViewController") as! InAppBrowserViewController
                inAppBrowserViewController.optionFrom = 3
                self.navigationController?.pushViewController(inAppBrowserViewController, animated: true)
            }
            else if indexPath.row == 6 {
                let inAppBrowserViewController : InAppBrowserViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InAppBrowserViewController") as! InAppBrowserViewController
                inAppBrowserViewController.optionFrom = 4
                self.navigationController?.pushViewController(inAppBrowserViewController, animated: true)
            }
            
            else if indexPath.row == 7 {
                let optionMenu = UIAlertController(title: API.appName, message: "Are you sure you want to delete account?", preferredStyle: .alert)
                let logoutAction = UIAlertAction(title: "OK", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.deleteAccountService()
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                })
                optionMenu.addAction(logoutAction)
                optionMenu.addAction(cancelAction)
                self.present(optionMenu, animated: true, completion: nil)
            }
      
            else if indexPath.row == 8 {
                let optionMenu = UIAlertController(title: API.appName, message: "Are you sure you want to logout?", preferredStyle: .alert)
                let logoutAction = UIAlertAction(title: "OK", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.logoutService()
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                })
                optionMenu.addAction(logoutAction)
                optionMenu.addAction(cancelAction)
                self.present(optionMenu, animated: true, completion: nil)
            }
        }
    }
    
    
    func logoutService(){
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID()
        ]
        SVProgressHUD.show()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.logoutURL, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.logoutSucess()
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
    
    
    func deleteAccountService(){
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID()
        ]
        SVProgressHUD.show()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.RmUser, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.logoutSucess()
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
    
    
    
    @objc func notificationOnOFFService(){
        var deviceToken  = UserDefaults.standard.value(forKey: "device_token")
        if deviceToken == nil  {
            deviceToken = "simlator"
        }
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID(),"allowPush" : self.isNotifictionON == "1" ? "0":"1","device_type":"1","device_token":deviceToken ?? "simlator"
        ]
        SVProgressHUD.show()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.updateNotificationURL, postData: params) { (result) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            switch (result) {
            case .success(let json):
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            if let data =  result["data"] as? [String : Any] {
                                let aa = data.filter { !($0.value is NSNull) }
                                ApplicationStates.setUserData(Info:  aa)
                                if let userData = UserDefaults.standard.value(forKey: "user_details") as? [String:Any]{
                                    if let isNotification = userData["allowPush"] as? String {
                                        self.isNotifictionON = isNotification
                                    }
                                }
                                self.tbView.reloadData()
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
                break;
            }
        }
    }
    
}
