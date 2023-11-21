//
//  MoreVideosVC.swift
//  Divineray
//
//  Created by Aravind Kumar on 01/09/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
@available(iOS 14.0, *)
class MoreVideosVC: UIViewController {
    var userInfo : NSDictionary!
    lazy var globalRoomId = ""
    
    @IBOutlet weak var nodataFound: UILabel!
    var itemArray : NSMutableArray!
    var isPageEnd = false
    @IBOutlet weak var tbView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nodataFound.isHidden = true
        let nibhView = UINib(nibName: "videoAudioTableViewCell", bundle: nil)
        self.tbView.register(nibhView, forCellReuseIdentifier: "videoAudioTableViewCell")
        self.itemArray = NSMutableArray.init()
        self.getMoreVideos()
        self.tbView.delegate = self
        self.tbView.dataSource = self
        // Do any additional setup after loading the view.
    }
    func getMoreVideos() {
        var lastId = ""
        if self.itemArray.count > 0 {
            if let dict = self.itemArray.lastObject as? NSDictionary {
                lastId = dict["id"] as! String;
            }
        }else {
            SVProgressHUD.show()
        }
        var profileUserId = ""
        if let pfUserid = self.userInfo["user_id"] as? String{
            profileUserId = pfUserid
        }
        let params:[String:Any] = [
            "user_id":ApplicationStates.getUserID(),"lastId":lastId,"perPage":"20","profileUserId":profileUserId
        ]
        
        
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAllUsersMediaListing, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            self.isPageEnd = false
                            if let data =  result["data"] as? NSArray {
                                self.itemArray.addObjects(from: data as! [Any])
                                self.tbView.reloadData()
                            }
                        }else {
                            self.isPageEnd = true
                        }
                    }
                    if self.itemArray.count == 0 {
                        self.nodataFound.isHidden = false
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
    
}
@available(iOS 14.0, *)
extension MoreVideosVC {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.updatenavigationBar()
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
                lblInfo.text = "Activation's & Meditations"
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
}
@available(iOS 14.0, *)
extension MoreVideosVC:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : videoAudioTableViewCell = tableView.dequeueReusableCell(withIdentifier: "videoAudioTableViewCell", for: indexPath) as! videoAudioTableViewCell
        cell.imgView.backgroundColor = UIColor.lightGray
        cell.playBtn.isHidden = false
        cell.imgView.image = UIImage(named: "imgDelete")
        if  let dict = self.itemArray.object(at: indexPath.row) as? NSDictionary {
            if let type  = dict["type"] as? String {
                if type == "audio" {
                    cell.playBtn.isHidden = true
                    cell.imgView.image = UIImage(named: "audioBG")
                }
            }
            
            if let postImage = dict["thumbImage"] as? String {
                let url = URL(string: postImage)
                cell.imgView.kf.setImage(with: url, placeholder:UIImage(named: ""))
            }
            cell.nameLbl.text = dict["title"] as? String
            cell.nameLbl.text = cell.nameLbl.text?.capitalized
            cell.despLbl.text = dict["description"] as? String
            cell.buyBtn.tag = indexPath.row
            cell.buyBtn.addTarget(self, action: #selector(buyAction), for: .touchUpInside)
            cell.buyBtn.isHidden = false

            if let isPurchased = dict["isPurchased"] as? String {
                if isPurchased == "1" {
                cell.buyBtn.isHidden = true
                }
            }
            
            if  let  coin =  dict["coins"] as? String {
                cell.lblCoins.text = coin
            }else  {
                cell.lblCoins.text  = ""
            }
        }
        cell.duration.isHidden = true;
        
        if indexPath.row == self.itemArray.count - 10 && self.itemArray.count > 9 &&  !self.isPageEnd {
            self.getMoreVideos()
        }
        return cell
    }
    @objc func buyAction(btn:UIButton) {
        //Need to impliment Api For mail
        if  let dict  = self.itemArray.object(at: btn.tag) as? NSDictionary {
            self.openBuyCall(info: dict,withIndex: btn.tag,isFrom:true)
        }
//        if  let data  = self.itemArray.object(at: btn.tag) as? NSDictionary {
//            if let user_details = data["userDetails"] as? NSDictionary {
//                self.openChat(chatUser: user_details)
//            }
//        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if  let dict = self.itemArray.object(at: indexPath.row) as? NSDictionary {
            if let isPurchased = dict["isPurchased"] as? String {
                if isPurchased == "0" {
                    self.openBuyCall(info: dict,withIndex: indexPath.row,isFrom: false)
                    return
                }
            }
            self.openVideo(dict: dict)
        }
    }
    func openVideo(dict:NSDictionary) {
        if let type  = dict["type"] as? String {
            if type == "audio" {
                let audioControllers = AudioPlayerViewController(nibName: "AudioPlayerViewController", bundle: nil)
                audioControllers.audioInformation = dict
                audioControllers.modalPresentationStyle = .fullScreen
                self.present(audioControllers, animated: true, completion: nil)
            }else {
                var media_link = ""
                if let ml  = dict["media_link"] as? String {
                    //Open You tube Player --
                    media_link = ml
                }
                if media_link.isEmpty {
                let playerClass = PlaylistViewController.init(nibName: "PlaylistViewController", bundle: Bundle.main)
                playerClass.isFromMoreVideo = true;
                playerClass.videoInfoPlay = dict as? [AnyHashable : Any]
                self.navigationController?.pushViewController(playerClass, animated: true)
                }else {
                    //Open YouTuber Player
                   let youtubeUrl = NSURL(string:media_link)!
                    UIApplication.shared.open(youtubeUrl as URL, options: [:], completionHandler: nil)
                }
            }
        }
    }
}

@available(iOS 14.0, *)
extension MoreVideosVC {
    open func openChat(chatUser:NSDictionary) {
        if self.globalRoomId == "" {
            SVProgressHUD.show()
            self.getRoomIdApi(chatUser: chatUser)
        }else {
            self.openChatViewControllers(chatUser: chatUser)
        }
    }
    open func getRoomIdApi(chatUser:NSDictionary){
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID(),
            "chatUserId":chatUser["user_id"] ?? ""
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
                self.globalRoomId = respDict["roomId"] as? String ?? ""
                if self.globalRoomId != "" {
                    self.openChat(chatUser: chatUser)
                }
                break
            case .failure(let error):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DashBoardDataFetch"), object: ["error":error])
                break;
            }
        }
    }
    func openChatViewControllers(chatUser:NSDictionary) {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
        let CMDVC = storyBoard.instantiateViewController(withIdentifier: "ChatDetailVC") as! ChatDetailVC
        if let object = chatUser["user_id"] {
            CMDVC.chatUserId = "\(object)"
        }
        CMDVC.roomId = globalRoomId
        CMDVC.receiverName = chatUser["name"] as? String ?? ""
        self.navigationController?.pushViewController(CMDVC, animated: true)
    }
}
@available(iOS 14.0, *)
extension MoreVideosVC {
    func openBuyCall(info:NSDictionary,withIndex:Int,isFrom:Bool) {
        let optionMenu = UIAlertController(title: API.appName, message: isFrom ? "Are you sure want to purchase this product?" : "First you need to buy this product, Are you sure want to purchase this product?", preferredStyle: .alert)
        let buyAction = UIAlertAction(title: "Buy", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openGoBuy(info: info, withIndex: withIndex, isFrom: isFrom)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(buyAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    func openGoBuy(info:NSDictionary,withIndex:Int,isFrom:Bool) {
        SVProgressHUD.show()
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID(),
            "id":info["id"] ?? ""]
        print(params)
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.purchaseMedia, postData: params){ (result) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            switch (result) {
            case .success(let json):
                if let resultDict = json as? [String:AnyObject]  {
                    if let status = resultDict["status"] as? Int {
                        if status == 1 {
                            if let data =  resultDict["data"] as? NSDictionary {
                                self.itemArray.removeObject(at: withIndex)
                                self.itemArray.insert(data, at: withIndex)
                                self.tbView.reloadData()
                                if  let dict = self.itemArray.object(at:withIndex) as? NSDictionary {
                                self.openVideo(dict: dict)
                                }
                            }
                        }else {
                            if let msg = resultDict["message"] as? String {
                                self.showAlertWith(title: API.appName, message: msg)
                            }
                        }
                    }
                }
                break
            case .failure(let error):
                print(error)
                break;
            }
        }
    }
}
