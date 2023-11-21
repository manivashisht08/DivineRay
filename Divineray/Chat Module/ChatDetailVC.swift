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

@available(iOS 14.0, *)
class ChatDetailVC: UIViewController, UITextViewDelegate, updateBlockDel, GroupRequestDelegate {

    
    @IBOutlet weak var profileGroupImg: UIImageView!
    @IBOutlet weak var othersNameLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendMessageBtn: UIButton!
    @IBOutlet weak var messageTV: UITextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    
    var productName = ""
    var productId = ""
    
    var roomId = ""
    var senderId = ""
    var userId = ""
    var chatUserId = ""
    var profileImg = ""
    var isFromPagination = false
    var responseArray =  [[String:AnyObject]]()
    var dataArray =  [[String:AnyObject]]()
    var refreshControl =  UIRefreshControl()
    var receiverName = ""
   
    var responseDict = [String:AnyObject]()
    var lastMesasageId = "0"
    var appDelegate  = AppDelegate()
    lazy var isFromNewMessage = Bool()
    var fromAppDelegate: String?
    var isGroup = String()
    
    var keyboard: KeyboardVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chatTableView.register(UINib(nibName: "RightImageTVCell", bundle: nil), forCellReuseIdentifier: "RightImageTVCell")
        self.chatTableView.register(UINib(nibName: "LeftImageTVCell", bundle: nil), forCellReuseIdentifier: "LeftImageTVCell")
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.profileGroupImg.sd_setImage(with: URL(string:profileImg ?? ""), placeholderImage:UIImage(named: "user"))
//        if let navigationBar = self.navigationController?.navigationBar {
//            if (navigationBar.viewWithTag(11) as? UILabel) != nil {
//                self.updatenavigationBar()
//            }else {
//                self.addCustomNavigation()
//            }
//        }else {
//            self.addCustomNavigation()
//        }
        self.navigationController?.isNavigationBarHidden = true
        self.nameLbl.text = receiverName
        self.othersNameLbl.text = ""
        tabBarController?.tabBar.isHidden = true
        messageTV.delegate = self
        messageTV.textContainerInset = UIEdgeInsets(top: 17, left: 13, bottom: 11, right: 13)
        messageTV.isScrollEnabled = false
        
        self.GetChatApi()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let socketConnectionStatus = SocketManger.shared.socket.status
            switch socketConnectionStatus {
            case .connected:
                print("socket connected")
                SocketManger.shared.socket.emit("ConncetedChat", self.roomId)
                self.newMessageSocketOn()
            case .connecting:
                print("socket connecting")
            case .disconnected:
                print("socket disconnected")
                print("socket not connected")
                SocketManger.shared.socket.connect()
                self.connectSocketOn()
                self.newMessageSocketOn()
            case .notConnected:
                print("socket not connected")
                SocketManger.shared.socket.connect()
                self.connectSocketOn()
                self.newMessageSocketOn()
            }
        }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        let refreshView = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 0))
        chatTableView.insertSubview(refreshView, at: 0)
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadtV), for: .valueChanged)
        refreshView.addSubview(refreshControl)
        if !productName.isEmpty {
            messageTV.text = "I want to buy this product - \(productName)"
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        IQKeyboardManager.shared.enable = false
        keyboard = KeyboardVM()
        keyboard?.setKeyboardNotification(self)
        
        self.updatenavigationBar()
        self.updateMessageSeenApi()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.updatenavigationBarBack()
        self.navigationController?.navigationBar.isHidden = true
        IQKeyboardManager.shared.enable = true
        self.keyboard?.removeKeyboardNotification()
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDot(_ sender: UIButton) {
        if isGroup == "1" {
            let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "GroupRequestVC") as! GroupRequestVC
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }else{
            let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "BlockReportPopVC") as! BlockReportPopVC
            vc.delegate = self
            vc.otherId = chatUserId
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
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
        } else if height < 55 {
            height = 53
        }
        self.view.layoutIfNeeded()
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        sendMessageBtn.isUserInteractionEnabled = true
        if textView.text.count == 0{
            messageTV.isScrollEnabled = false
        }
        return true
    }
    
    @objc  override func dismissKeyboard() {
        view.endEditing(false)
    }
    
    
    func scrollEnd(){
        let lastItemIndex = self.chatTableView.numberOfRows(inSection: 0) - 1
        let indexPath:IndexPath = IndexPath(item: lastItemIndex, section: 0)
        self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        self.chatTableView.reloadData()
    }
    func connectSocketOn(){
        SocketManger.shared.onConnect {
            debugPrint("ConncetedChat \(self.roomId)")
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
                            print(self.responseArray,"DataData")
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
        let params:[String:Any] = ["roomId": roomId, "user_id": ApplicationStates.getUserID(), "message":messageTV.text!, "messageId" :"0"]
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
@available(iOS 14.0, *)
extension ChatDetailVC: UITableViewDataSource, UITableViewDelegate{
    
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
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "hh:mm a" //Specify your format that you want
            let strDate = dateFormatter.string(from: date)
            //creation_date
            cell?.timeLabel.text = strDate
            cell?.messageLBL.text = respDict["message"] as? String ?? ""
            return cell!
            
        }  else {
            var cell1 = tableView.dequeueReusableCell(withIdentifier: "identifier") as? LeftMessageTableViewCell
            if cell1 == nil {
                let arr = Bundle.main.loadNibNamed("LeftMessageTableViewCell", owner: self, options: nil)
                cell1 = arr?[0] as? LeftMessageTableViewCell
            }
            let respDict = responseArray[indexPath.row] as? [String:AnyObject] ?? [:]
            let unixtimeInterval = respDict["messageTime"] as? NSString
            let date = Date(timeIntervalSince1970:  unixtimeInterval?.doubleValue ?? 0.0)
            let dateFormatter        = DateFormatter()
            dateFormatter.timeZone   = TimeZone.current
            dateFormatter.locale     = NSLocale.current
            dateFormatter.dateFormat = "hh:mm a"      //Specify your format that you want
            let strDate = dateFormatter.string(from: date)
            //creation_date
            cell1?.timeLabel.text = strDate
            cell1?.messageLBL.text = respDict["message"] as? String ?? ""
            cell1?.recieverUserNameLbl.text = respDict["username"] as? String ?? ""
            var photoStr = respDict["userProfileImage"] as? String
            photoStr = photoStr?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//            cell1?.senderTxtProfileImageView.sd_setImage(with: URL(string:photoStr ?? ""), placeholderImage:UIImage(named: "user"))
            return cell1!
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
@available(iOS 14.0, *)
extension ChatDetailVC {
    
 
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
@available(iOS 14.0, *)
extension ChatDetailVC: KeyboardVMObserver {
    
    func keyboard(didChange height: CGFloat, duration: Double, animation: UIView.AnimationOptions) {
        if self.messageTV.isFirstResponder {
            if textViewBottomConstraint.constant == height {
                return
            }
        } else {
            if textViewBottomConstraint.constant == 0 {
                return
            }
        }
        print("height is \(height)")
        self.textViewBottomConstraint.constant = height
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: duration, delay: 0.0, options: animation, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: { finished in
        })
    }
    
    func updateGroupData() {
        let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "GroupAcceptRequestVC") as! GroupAcceptRequestVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func updateBlock(otherId:String) {
       print("UpdateBlock")
    }
    func updateData(otherId:String) {
        let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ReportUserPopVC") as! ReportUserPopVC
        vc.modalPresentationStyle = .overFullScreen
        vc.otherId = otherId
        self.present(vc, animated: true)
    }
}
