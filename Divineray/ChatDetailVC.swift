//
//  ChatDetailVC.swift
//  Divineray
//
//  Created by Dharmani Apps mini on 7/17/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SocketIO
import IQKeyboardManagerSwift
import SDWebImage
import SVProgressHUD

class ChatDetailVC: UIViewController,UITextViewDelegate{
    var roomId = ""
    var senderId = ""
    var userId = ""
    var chatUserId = ""
    var isFromPagination = false
    var responseArray =  [[String:AnyObject]]()
    var dataArray =  [[String:AnyObject]]()
    var refreshControl =  UIRefreshControl()
    var receiverName = ""
    var profileImg = ""
    var responseDict = [String:AnyObject]()
    var lastMesasageId = "0"
    var appDelegate  = AppDelegate()
    lazy var isFromNewMessage = Bool()
    var fromAppDelegate: String?

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendMessageBtn: UIButton!
    @IBOutlet weak var messageTV: UITextView!
    @IBOutlet weak var messageTVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        tabBarController?.tabBar.isHidden = true
        messageTV.delegate = self
        messageTV.textContainerInset = UIEdgeInsets(top: 8.1, left: 13, bottom: 11, right: 13)
        messageTV.isScrollEnabled = false
        
        self.GetChatApi()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            debugPrint("connected")
            let socketConnectionStatus = SocketManger.shared.socket.status
            switch socketConnectionStatus {
            case .connected:
                debugPrint("socket connected")
                SocketManger.shared.socket.emit("ConncetedChat", self.roomId)
                self.newMessageSocketOn()
            case .connecting:
                debugPrint("socket connecting")
            case .disconnected:
                debugPrint("socket disconnected")
                debugPrint("socket not connected")
                SocketManger.shared.socket.connect()
                self.connectSocketOn()
                self.newMessageSocketOn()
            case .notConnected:
                debugPrint("socket not connected")
                SocketManger.shared.socket.connect()
                self.connectSocketOn()
                self.newMessageSocketOn()
            }
        }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        let refreshView = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 0))
        chatTableView.insertSubview(refreshView, at: 0)
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadtV), for: .valueChanged)
        refreshView.addSubview(refreshControl)
    }
    open func updateMessageSeenApi(){
        var params = [String:Any]()
        
        if chatUserId == ApplicationStates.getUserID(){
            
            params = [
               "user_id": userId,
               "roomId":roomId
           ]
        }else{
            //chatUserId
            params = [
               "user_id": chatUserId,
               "roomId":roomId
           ]
        }
        
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.UpdateMessageSeenURL, postData: params){ (result) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            switch (result) {
            case .success(let json):
               
                
                break
            case .failure(let error):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DashBoardDataFetch"), object: ["error":error])
                break;
            }
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        messageTV.isScrollEnabled = true
        // get the current height of your text from the content size
        var height = textView.contentSize.height
        // clamp your height to desired values
        if height > 90 {
            height = 90
        } else if height < 50 {
            height = 33
        }
        messageTVHeightConstraint.constant = height
        messageViewHeightConstraint.constant = height + 30
        self.view.layoutIfNeeded()
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        sendMessageBtn.isUserInteractionEnabled = true
        if textView.text.count == 0{
            messageTV.isScrollEnabled = false
            messageTVHeightConstraint.constant = 33
            messageViewHeightConstraint.constant = 60
        }
        return true
    }
    
    @objc  override func dismissKeyboard() {
        view.endEditing(false)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.updatenavigationBar()
        updateMessageSeenApi()
    }
    func scrollEnd(){
        let lastItemIndex = self.chatTableView.numberOfRows(inSection: 0) - 1
        let indexPath:IndexPath = IndexPath(item: lastItemIndex, section: 0)
        self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        self.chatTableView.reloadData()
    }
    func connectSocketOn(){
        SocketManger.shared.onConnect {
            SocketManger.shared.socket.emit("ConncetedChat", self.roomId)
        }
    }
    func newMessageSocketOn(){
        SocketManger.shared.handleNewMessage { (message) in
            print(message)
            self.responseArray.insert(message as [String:AnyObject], at: self.responseArray.count)
            
            self.isFromNewMessage = true
            DispatchQueue.main.async(execute: {
                self.chatTableView.reloadData()
                if self.responseArray.count > 0 {
                    let ip = IndexPath(row: self.responseArray.count - 1, section: 0)
                    self.chatTableView.scrollToRow(at: ip, at: .bottom, animated: false)
                }
            })
        }
    }
    func joinedMessageSocketOn(){
        SocketManger.shared.handleJoinedMessage { (message) in
        }
    }
    func typeSocketOn(){
        SocketManger.shared.handleUserTyping { (trueIndex) in
        }
    }
    @objc func reloadtV() {
        isFromPagination = true
        GetChatApi()
        self.refreshControl.endRefreshing()
    }
    func GetChatApi(){
        let params:[String:Any] = ["user_id":ApplicationStates.getUserID(),"chatUserId":chatUserId,"perPage":"10","lastMessageId":lastMesasageId,"roomId":roomId]
        if isFromNewMessage == false{
            SVProgressHUD.show(withStatus: "Loading...")
            SVProgressHUD.setDefaultMaskType(.clear)
        }
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getChatMessageDetailURL, postData: params){ (result) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            switch (result) {
            case .success(let json):
                self.responseDict = json as? [String:AnyObject] ?? [:]
                _ = self.responseDict["message"] as? String ?? ""
                let status = self.responseDict["status"] as? Int ?? 0
                if status == 1{
                    self.isFromNewMessage = false
                    self.lastMesasageId = self.responseDict["lastMessageId"] as? String ?? ""
                    if let data = self.responseDict["data"] as? [[String:AnyObject]] {
                        if data.count != 0{
                            for i in 0..<data.count {
                                self.responseArray.append(data[i])
                            }
                            let sortDescriptor = NSSortDescriptor(key: "messageTime", ascending: true)
                            self.responseArray = ((self.responseArray as NSArray).sortedArray(using: [sortDescriptor]) as? [[String:AnyObject]])!
                            if  self.responseArray.count != 0 {
                                DispatchQueue.main.async(execute: {
                                    self.chatTableView.reloadData()
                                    if self.responseArray.count > 0 {
                                        let ip = IndexPath(row: self.responseArray.count-1, section: 0)
                                        if self.isFromPagination != true{
                                        self.chatTableView.scrollToRow(at: ip, at: .bottom, animated: false)
                                        }else{
                                            self.isFromPagination = false
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
                break
            case .failure(let error):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DashBoardDataFetch"), object: ["error":error])
                break;
            }
        }
    }
    
    func addMessageApi(){
        let params:[String:Any] = ["roomId":roomId,"user_id":ApplicationStates.getUserID(),"message":messageTV.text!,"messageId" :"0"]
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.addChatMessageDetailURL, postData: params){ (result) -> Void in
            switch (result) {
            case .success(let json):
                let resultDict = json as? [String:AnyObject] ?? [:]
                let status = resultDict["status"] as? Int ?? 0
                if status == 1{
                    let appendArr = resultDict["data"] as? [AnyObject] ?? []
                    let appendData = appendArr[0] as? [String:AnyObject] ?? [:]
                    SocketManger.shared.socket.emit("newMessage",self.roomId,appendData)
                    self.responseArray.insert(appendData as [String:AnyObject], at: self.responseArray.count)
                    
                    
                    DispatchQueue.main.async(execute: {
                        self.sendMessageBtn.isUserInteractionEnabled = false
                        self.messageTVHeightConstraint.constant = 33
                        self.messageViewHeightConstraint.constant = 60
                        if self.responseArray.count > 0 {
                            self.chatTableView.reloadData()
                            let ip = IndexPath(row: self.responseArray.count - 1, section: 0)
                            self.chatTableView.scrollToRow(at: ip, at: .bottom, animated: true)
                        }
                        
                    })
                    
                }
                break
            case .failure(let error):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DashBoardDataFetch"), object: ["error":error])
                break;
            }
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
          //   SocketManger.shared.socket.disconnect()
          SocketManger.shared.socket.emit("leaveChat",self.roomId)
      }
    @IBAction func crossBtnAction(_ sender: UIButton) {
        
      
        
        
        messageTV.resignFirstResponder()
        tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendMsgBtnAction(_ sender: UIButton) {
        let trimmedString = messageTV.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmedString != "" {
            messageTV.resignFirstResponder()
            addMessageApi()
            messageTV.text = ""
        }
    }
}
extension ChatDetailVC:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responseArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let respDict = responseArray[indexPath.row] as? [String:AnyObject] ?? [:]
        let senderIds = respDict["user_id"] as? String ?? ""
        if  "\(ApplicationStates.getUserID())" == senderIds {
            var cell = tableView.dequeueReusableCell(withIdentifier: "identifier") as? RightMessageTableViewCell
            if cell == nil {
                let arr = Bundle.main.loadNibNamed("RightMessageTableViewCell", owner: self, options: nil)
                cell = arr?[0] as? RightMessageTableViewCell
            }
            let unixtimeInterval = respDict["messageTime"] as? NSString
            let date = Date(timeIntervalSince1970:  unixtimeInterval?.doubleValue ?? 0.0)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "IST") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "hh:mm a" //Specify your format that you want
            let strDate = dateFormatter.string(from: date)
            //creation_date
            cell?.timeLabel.text = strDate
            cell?.messageLBL.text = respDict["message"] as? String ?? ""
            return cell!
            
        }
        else {
            var cell1 = tableView.dequeueReusableCell(withIdentifier: "identifier") as? LeftMessageTableViewCell
            if cell1 == nil {
                let arr = Bundle.main.loadNibNamed("LeftMessageTableViewCell", owner: self, options: nil)
                cell1 = arr?[0] as? LeftMessageTableViewCell
            }
            let respDict = responseArray[indexPath.row] as? [String:AnyObject] ?? [:]
            let unixtimeInterval = respDict["messageTime"] as? NSString
            let date = Date(timeIntervalSince1970:  unixtimeInterval?.doubleValue ?? 0.0)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "IST") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "hh:mm a" //Specify your format that you want
            let strDate = dateFormatter.string(from: date)
            //creation_date
            cell1?.timeLabel.text = strDate
            cell1?.messageLBL.text = respDict["message"] as? String ?? ""
            cell1?.recieverUserNameLbl.text = respDict["username"] as? String ?? ""
            var photoStr = respDict["userProfileImage"] as? String
            photoStr = photoStr?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            cell1?.senderTxtProfileImageView.sd_setImage(with: URL(string:photoStr ?? ""), placeholderImage:UIImage(named: "user"))
            return cell1!
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension ChatDetailVC {
    
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
                lblInfo.text = self.receiverName
            }
            if let btnSetting = navigationBar.viewWithTag(12) as? UIButton {
                btnSetting.isHidden = true
            }
            if let backBtn = navigationBar.viewWithTag(13) as? UIButton {
                backBtn.isHidden = false
                backBtn.addTarget(self, action: #selector(backToTopChatDetails), for: .touchUpInside)
            }
        }
    }
    @objc func backToTopChatDetails() {
        if fromAppDelegate == "YES"{
            print("iiiii")
             self.navigationController?.popViewController(animated: true)
            
                 let storyB = UIStoryboard(name: "Main", bundle: nil)
           //  tabBarController?.tabBar.isHidden = false
                            let SWRC = storyB.instantiateViewController(withIdentifier: "DivinerayTabBarViewController") as? DivinerayTabBarViewController
               SWRC?.selectedIndex = 3
                            //  app.check = false;
                            if let SWRC = SWRC {
                                navigationController?.pushViewController(SWRC, animated: false)
                            }
             }else{
//                self.updateMessageSeen(chatUserId:self.roomId)

                 self.navigationController?.popViewController(animated: true)
             }
    }
    func addCustomNavigation() {
        if let navigationBar = self.navigationController?.navigationBar {
            self.navigationItem.setHidesBackButton(true, animated: true);
            let firstFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: navigationBar.frame.height)
            let firstLabel = UILabel(frame: firstFrame)
            firstLabel.text = receiverName
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
        }
    }
    func updatenavigationBarBack(){
        if let navigationBar = self.navigationController?.navigationBar {
            if let backBtn = navigationBar.viewWithTag(13) as? UIButton {
                backBtn.removeTarget(self, action: #selector(backToTopChatDetails), for: .touchUpInside)
            }
        }
    }
}
