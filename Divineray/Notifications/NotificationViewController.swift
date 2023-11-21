//
//  NotificationViewController.swift
//  Divineray
//
//  Created by Aravind Kumar on 13/10/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
@available(iOS 14.0, *)

class NotificationViewController: UIViewController {
    var paginationDone = false
    var isFromPush = false
    var serviceInprogress = false
    var notificationInfo:NSDictionary?
    private let kNotificationSystemTableViewCell = "NotificationTableViewCell"
    
    var dataArray : NSMutableArray!
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var tbView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataArray = NSMutableArray.init()
        self.registerNib()
        self.tbView.delegate = self
        self.tbView.dataSource = self
        // Do any additional setup after loading the view.
        self.lblMsg.isHidden = true
        self.getDataAction()
        // Do any additional setup after loading the view.
    }
    func registerNib(){
        let nibhView = UINib(nibName: kNotificationSystemTableViewCell, bundle: nil)
        self.tbView.register(nibhView, forCellReuseIdentifier: kNotificationSystemTableViewCell)
    }
    
}
@available(iOS 14.0, *)

extension NotificationViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        if let navigationBar = self.navigationController?.navigationBar {
            if (navigationBar.viewWithTag(11) as? UILabel) != nil {
                self.updatenavigationBar()
            }else {
                self.addCustomNavigation()
            }
        }else {
            self.addCustomNavigation()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isFromPush = false
        self.updatenavigationBarBack()
        self.navigationController?.navigationBar.isHidden = true
    }
    func addCustomNavigation() {
        if let navigationBar = self.navigationController?.navigationBar {
            self.navigationItem.setHidesBackButton(true, animated: true);
            
            let firstFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: navigationBar.frame.height)
            let firstLabel = UILabel(frame: firstFrame)
            firstLabel.text = "Notifications"
            
            firstLabel.textAlignment = .center
            firstLabel.font = UIFont(name: "Poppins-Medium", size: 17)
            firstLabel.tag = 11
            navigationBar.addSubview(firstLabel)
            let btnFrame = CGRect(x: UIScreen.main.bounds.size.width-54, y: 0, width: 44, height: navigationBar.frame.height)
            let btnSetting = UIButton(type: .custom)
            btnSetting.frame = btnFrame
            btnSetting.setImage(UIImage(named: "st"), for: .normal)
            navigationBar.addSubview(btnSetting)
            btnSetting.tag = 12
            
            let btnBackFrame = CGRect(x: 9, y: 0, width: 44, height: navigationBar.frame.height)
            let btnBack = UIButton(type: .custom)
            btnBack.frame = btnBackFrame
            btnBack.setImage(UIImage(named: "back"), for: .normal)
            navigationBar.addSubview(btnBack)
            btnBack.tag = 13
            btnBack.isHidden = false
            btnSetting.isHidden = true
            
            btnBack.addTarget(self, action: #selector(backAction), for: .touchUpInside)
            
        }
    }
    func updatenavigationBar(){
        if let navigationBar = self.navigationController?.navigationBar {
            // remove left buttons (in case you added some)
            self.navigationItem.leftBarButtonItems = []
            // hide the default back buttons
            self.navigationItem.hidesBackButton = true
            
            if let lblInfo = navigationBar.viewWithTag(11) as? UILabel {
                lblInfo.text = "Notifications"
            }
            if let btnSetting = navigationBar.viewWithTag(12) as? UIButton {
                btnSetting.isHidden = true
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
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func getDataActionForPush() {
        self.dataArray.removeAllObjects()
        self.tbView.reloadData()
        self.getDataAction()
        
    }
    @objc func getDataAction() {
        if serviceInprogress {
            return
        }
        serviceInprogress = true
        var lastNotificationId = "0"
        if self.dataArray.count > 0 {
            if let dict = self.dataArray.lastObject as? NSDictionary  {
                if let lastInfo = dict.value(forKey: "notificationId") as? String {
                    lastNotificationId = lastInfo
                }
            }
        }else {
            paginationDone = false
        }
        let params:[String:Any] = [
            "user_id":ApplicationStates.getUserID() ,"lastNotificationId":lastNotificationId,"perPage":"40"
        ]
        if self.dataArray.count == 0{
            SVProgressHUD.show()
        }
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAllNotificationsDetails, postData: params) { (result) -> Void in
            self.serviceInprogress = false
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            if let data =  result["data"] as? NSArray {
                                self.dataArray.addObjects(from: data as! [Any])
                                self.tbView.reloadData()
                            }
                        }else {
                            self.paginationDone = true
                        }
                        if self.isFromPush {
                            
                            self.openNotificationObject()
                        }
                        if let message =  result["message"] as? String {
                            self.lblMsg.text = message
                        }
                        if self.dataArray.count == 0 {
                            self.lblMsg.isHidden = false
                        }else {
                            self.lblMsg.isHidden = true
                        }
                        
                    }
                } else {
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
    func openNotificationObject() {
        if let data = self.notificationInfo?["data"] as? NSDictionary {
            if let pushNotificationId = data["notificationId"] as? String {
                var dict : NSDictionary?  = nil
                if self.dataArray.count > 0 {
                    for ids in self.dataArray {
                        if let dictIds = ids as? NSDictionary {
                            if let nid = dictIds["notificationId"] as? String {
                                if nid == pushNotificationId {
                                    dict = dictIds
                                    break
                                }
                            }
                        }
                    }
                }
                if let dd = dict {
                    self.openNotification(dict: dd)
                }
                self.isFromPush = false
                self.notificationInfo = nil
            }
        }
    }
}
@available(iOS 14.0, *)

extension NotificationViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hv = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 5))
        hv.backgroundColor = UIColor.clear
        return hv
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let dict = self.dataArray.object(at: indexPath.row) as? NSDictionary {
            if let message =  dict["message"] as? String {
                let h = self.heightForView(text: message, font: UIFont(name: "Poppins-Medium", size: 14)!, width: self.view.frame.size.width - 100)
                return h + 60
            }
        }
        return 90
    }
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell : NotificationTableViewCell = tableView.dequeueReusableCell(withIdentifier: kNotificationSystemTableViewCell, for: indexPath) as? NotificationTableViewCell else {
            fatalError("Unable to Dequeue Reusable Table View Cell")
        }
        if let dict = self.dataArray.object(at: indexPath.row) as? NSDictionary {
            cell.loadCellData(dict: dict)
            cell.btnProfile.addTarget(self, action: #selector(openProfileAction(btn:)), for: .touchUpInside)
            cell.btnProfile.tag = indexPath.row
        }
        if indexPath.row == self.dataArray.count - 10  && !self.paginationDone{
            self.getDataAction()
        }else {
            self.getDataAction()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let dict = self.dataArray.object(at: indexPath.row) as? NSDictionary {
            self.openNotification(dict: dict)
        }
    }
    func openNotification(dict:NSDictionary) {
        if let notificationType = dict["notificationType"] as? String {
            if notificationType == "3" || notificationType == "4" {
                if let video_details = dict["video_details"] as? NSDictionary {
                    var userId = ApplicationStates.getUserID()
                    if let user_details = dict["userDetails"] as? NSDictionary {
                        if let idUser = user_details["user_id"] as? String {
                            userId = idUser
                        }
                    }
                    let playerClass = PlaylistViewController.init(nibName: "PlaylistViewController", bundle: Bundle.main)
                    playerClass.isFromUser = true;
                    let mutArra:NSMutableArray =  NSMutableArray.init(array:NSArray.init(object: video_details))
                    playerClass.oldDataArray = mutArra
                    playerClass.clickedItemIndex = 0
                    playerClass.userId = userId;
                    if userId ==  ApplicationStates.getUserID(){
                        playerClass.myProfile = true
                    }
                    self.navigationController?.pushViewController(playerClass, animated: true)
                }
            }else if let user_details = dict["userDetails"] as? NSDictionary {
                if notificationType == "2" && self.isFromPush {
                    self.isFromPush = false
                }else {
                self.openProfile(user_details: user_details)
                }
            }
        }
    }
    
    
    @objc func openProfileAction(btn:UIButton) {
        if  let data = self.dataArray.object(at: btn.tag) as? NSDictionary {
            if let user_details = data["userDetails"] as? NSDictionary {
                self.openProfile(user_details: user_details)
            }
        }
    }
    func openProfile(user_details:NSDictionary) {
        let profileObject : ProfileViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileObject.userData = user_details;
        self.navigationController?.pushViewController(profileObject, animated: true)
    }
}
