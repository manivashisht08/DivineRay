//
//  ChatVC.swift
//  Divineray
//
//  Created by Dharmani Apps mini on 7/15/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import SDWebImage

@available(iOS 14.0, *)
class ChatVC: UIViewController,UITextFieldDelegate {
    
    lazy var responseArr = [AnyObject]()
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var chatListTBView: UITableView!
    var fromAppDelegate: String?
    var senderIdFromPush: String?
    var isFromSearch:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchTF.delegate = self
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.updatenavigationBar()
        self.view.setNeedsLayout()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        self.updatenavigationBarBack()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        isFromSearch = false
        searchTF.text = ""
        chatListApi()
        
    }
    @objc func textFieldDidChange(_ theTextField: UITextField?) {
        if (theTextField?.text?.count ?? 0) > 0 {
            isFromSearch = true
            self.search(byUserName: theTextField?.text)
        } else {
            isFromSearch = false
            chatListApi()
        }
    }
    
    @IBAction func groupBtnAction(_ sender: UIButton) {
        print("Tappeddd")
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
        let CMDVC = storyBoard.instantiateViewController(withIdentifier: "GroupVC") as? GroupVC
        CMDVC?.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(CMDVC!, animated: true)
    }
    
    open func search(byUserName searchTxt: String?) {
        if (searchTxt?.count ?? 0) > 0 {
            let lastId = "0"
            
            let params:[String:Any] = [
                "user_id": ApplicationStates.getUserID(),
                "search":searchTxt ?? "",
                "lastUserId" :lastId,
                "perPage":"1000"
            ]
            SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.searchChatListURL, postData: params){ (result) -> Void in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                switch (result) {
                case .success(let json):
                    let resultDict = json as? [String:AnyObject] ?? [:]
                    self.responseArr = resultDict["data"] as? [AnyObject] ?? []
                    self.chatListTBView.reloadData()
                    if self.responseArr.count == 1{
                        self.view.endEditing(true)
                    }
                    break
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DashBoardDataFetch"), object: ["error":error])
                    break;
                }
            }
            
        } else {
        }
    }
    open func delete(chatUserId:String){
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID(),
            "chatUserId":chatUserId
        ]
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.generateRoomIDURL, postData: params){ (result) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            switch (result) {
            case .success(let json):
                let resultDict = json as? [String:AnyObject] ?? [:]
                let dataArr = resultDict["data"] as? [AnyObject] ?? []
                let respDict = dataArr[0] as? [String:AnyObject] ?? [:]                
                break
            case .failure(let error):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DashBoardDataFetch"), object: ["error":error])
                break;
            }
        }
    }
    @available(iOS 14.0, *)
    open func getRoomIdApi(chatUserId:String,vc:ChatDetailVC?){
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID(),
            "chatUserId":chatUserId
        ]
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.generateRoomIDURL, postData: params){ (result) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            switch (result) {
            case .success(let json):
                let resultDict = json as? [String:AnyObject] ?? [:]
                let dataArr = resultDict["data"] as? [AnyObject] ?? []
                let respDict = dataArr[0] as? [String:AnyObject] ?? [:]
                vc?.roomId = respDict["roomId"] as? String ?? ""
                vc?.userId = ApplicationStates.getUserID()
                vc?.chatUserId = chatUserId
                
                self.navigationController?.pushViewController(vc!, animated: true)
                break
            case .failure(let error):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DashBoardDataFetch"), object: ["error":error])
                break;
            }
        }
    }
    open func chatListApi(){
        
        SVProgressHUD.show(withStatus: "Loading...")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID()
        ]
        
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getChatListURL, postData: params){ (result) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            
            switch (result) {
            case .success(let json):
                let resultDict = json as? [String:AnyObject] ?? [:]
                
                self.responseArr = resultDict["data"] as? [AnyObject] ?? []
                print(self.responseArr,"Data")
                self.chatListTBView.reloadData()
                
                if self.fromAppDelegate == "YES" {
                    var ids : [String : AnyObject]?
                    for obj in self.responseArr {
                        let chatUserId = obj["chatUserId"] as? String
                        if self.senderIdFromPush == chatUserId {
                            ids = obj as? [String : AnyObject]
                            break;
                        }
                    }
                    if let mainData  = ids {
                        self.openChatMain(obj: mainData)
                    }
                }
                
                break
            case .failure(let error):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DashBoardDataFetch"), object: ["error":error])
                break;
            }
        }
        
    }
    func openChatMain(obj:[String : AnyObject]){
        self.fromAppDelegate = "NO"
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
        let CMDVC = storyBoard.instantiateViewController(withIdentifier: "ChatDetailVC") as? ChatDetailVC
        let contactDict = obj
        if let object = contactDict["user_id"] {
            CMDVC?.chatUserId = "\(object)"
        }
        
        if let object = contactDict["name"] {
            CMDVC?.receiverName = "\(object)"
        }else{
            CMDVC?.receiverName = contactDict["username"] as? String ?? ""
        }
        
        let object = contactDict["roomId"] as? String ?? ""
        if object  == ""{
            getRoomIdApi(chatUserId:contactDict["user_id"] as? String ?? "", vc: CMDVC)
        }else{
            CMDVC?.roomId = "\(object)"
            if let CMDVC = CMDVC {
                navigationController?.pushViewController(CMDVC, animated: true)
            }
        }
    }
}

@available(iOS 14.0, *)
extension ChatVC:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.responseArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? ChatListTBCell
        let respDict = responseArr[indexPath.row] as? [String:AnyObject] ?? [:]
        let badgeCount = respDict["UnreadMessagesCount"]
        var bdgCountStr: String? = nil
        if let badgeCount = badgeCount {
            bdgCountStr = "\(badgeCount)"
        }
        if bdgCountStr == "0" {
            cell?.notificationBadgeCountBtn.isHidden = true
        } else {
            cell?.notificationBadgeCountBtn.isHidden = false
            cell?.notificationBadgeCountBtn.setTitle(bdgCountStr, for: .normal)
            
        }
        let time = Double(respDict["lastMessageTime"] as? String ?? "") ?? 0.0
        cell?.timeLbl.text = Date(timeIntervalSince1970: time).timeAgoSinceDate()
        cell?.profileBtn.tag = indexPath.row
        cell?.profileBtn.addTarget(self, action: #selector(self.profileAction), for: .touchUpInside)
        
        cell?.profileBtn
        if isFromSearch == true{
            cell?.nameLbl.text = respDict["name"] as? String ?? ""
            var userProfilePic = respDict["photo"] as? String ?? ""
            userProfilePic = userProfilePic.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            cell?.profileImgView.sd_setImage(with: URL(string: userProfilePic ), placeholderImage: UIImage(named: "user"))
            cell?.messageLbl.isHidden = true
            cell?.notificationBadgeCountBtn.isHidden = true
        }else{
            cell?.messageLbl.isHidden = false
            cell?.messageLbl.text = respDict["lastMessage"] as? String ?? ""
            if respDict["isGroup"] as? String ?? "" == "1" {
                cell?.nameLbl.text = respDict["groupName"] as? String ?? ""
            }else{
                cell?.nameLbl.text = respDict["groupName"] as? String ?? ""
            }
            var userProfilePic = respDict["groupImage"] as? String ?? ""
            userProfilePic = userProfilePic.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            cell?.profileImgView.sd_setImage(with: URL(string: userProfilePic ), placeholderImage: UIImage(named: "user"))
        }
        return cell!
    }
    @objc func profileAction(btn:UIButton) {
        if  let data  = self.responseArr[btn.tag] as? [String:AnyObject] {
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

@available(iOS 14.0, *)
extension ChatVC:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
        let CMDVC = storyBoard.instantiateViewController(withIdentifier: "ChatDetailVC") as? ChatDetailVC
       
        let contactDict = responseArr[indexPath.row] as? [String : AnyObject] ?? [:]
        let roomId = contactDict["roomId"] as? String ?? ""
        CMDVC?.profileImg = contactDict["userProfileImage"] as? String ?? ""
        CMDVC?.isGroup = contactDict["isGroup"] as? String ?? ""
        if let object = contactDict["name"] {
            CMDVC?.receiverName = "\(object)"
        }
        else{
            CMDVC?.receiverName = contactDict["groupName"] as? String ?? ""
        }
        
        if roomId == ""{
            self.getRoomIdApi(chatUserId:contactDict["user_id"] as? String ?? "", vc: CMDVC)
        }
        else{
            if let object = contactDict["user_id"] {
                CMDVC?.userId = "\(object)"
            }
            if let object = contactDict["chatUserId"] {
                CMDVC?.chatUserId = "\(object)"
            }
            
            CMDVC?.roomId = roomId
            
            if let CMDVC = CMDVC {
                navigationController?.pushViewController(CMDVC, animated: true)
            }
        }
    }
}

@available(iOS 14.0, *)
extension ChatVC {
    
    func updatenavigationBar(){
        if let navigationBar = self.navigationController?.navigationBar {
            if let lblInfo = navigationBar.viewWithTag(11) as? UILabel {
                lblInfo.text = ""
            }
            if let btnSetting = navigationBar.viewWithTag(12) as? UIButton {
                btnSetting.isHidden = true
            }
            if let backBtn = navigationBar.viewWithTag(13) as? UIButton {
                backBtn.isHidden = true
                backBtn.addTarget(self, action: #selector(backToTop), for: .touchUpInside)
                backBtn.isHidden = true
            }
        }
    }
    
    @objc func backToTop() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addCustomNavigation() {
        if let navigationBar = self.navigationController?.navigationBar {
            self.navigationItem.setHidesBackButton(true, animated: true);
            
            let firstFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: navigationBar.frame.height)
            let firstLabel = UILabel(frame: firstFrame)
            firstLabel.text = ""
            
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
            btnBack.isHidden = true
            btnSetting.isHidden = true
            
        }
    }
    
    func updatenavigationBarBack(){
        
        if let navigationBar = self.navigationController?.navigationBar {
            if let backBtn = navigationBar.viewWithTag(13) as? UIButton {
                backBtn.removeTarget(self, action: #selector(backToTop), for: .touchUpInside)
            }
        }
    }
    
}
