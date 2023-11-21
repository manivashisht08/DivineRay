//
//  PhysicalProductVC.swift
//  Divineray
//
//  Created by Aravind Kumar on 01/09/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD

@available(iOS 14.0, *)
class PhysicalProductVC: UIViewController {
    
    @IBOutlet weak var nodatafound: UILabel!
    lazy var globalRoomId = ""
    var userInfo : NSDictionary!
    @IBOutlet weak var tbView: UITableView!
    var itemArray : NSMutableArray!
    var isPageEnd = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nodatafound.isHidden = true
        let nibhView = UINib(nibName: "PhysicalTableViewCell", bundle: nil)
        self.tbView.register(nibhView, forCellReuseIdentifier: "PhysicalTableViewCell")
        self.itemArray = NSMutableArray.init()
        self.getAllPhysicalProduct()
        self.tbView.delegate = self
        self.tbView.dataSource = self
        
        
        // Do any additional setup after loading the view.
    }
    func getAllPhysicalProduct() {
        var lastId = ""
        if self.itemArray.count > 0 {
            if let dict = self.itemArray.lastObject as? NSDictionary {
                lastId = dict["productId"] as! String;
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
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAllUsersProductListing, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 3 {
                           
                        }
                        else if status == 1 {
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
                        self.nodatafound.isHidden = false
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

extension PhysicalProductVC {
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
                lblInfo.text = "Physical Product"
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

extension PhysicalProductVC:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : PhysicalTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PhysicalTableViewCell", for: indexPath) as! PhysicalTableViewCell
        cell.imgView.backgroundColor = UIColor.lightGray
        if  let dict = self.itemArray.object(at: indexPath.row) as? NSDictionary {
            if let postImage = dict["productImage"] as? String {
                let url = URL(string: postImage)
                cell.imgView.kf.setImage(with: url, placeholder:UIImage(named: ""))
            }
            cell.nameLbl.text = dict["productTitle"] as? String
            cell.nameLbl.text = cell.nameLbl.text?.capitalized
            cell.despLbl.text = dict["productDescription"] as? String
            cell.buyBtn.addTarget(self, action: #selector(buyAction), for: .touchUpInside)
            cell.buyBtn.tag = indexPath.row
        }
        if indexPath.row == self.itemArray.count - 10 && self.itemArray.count > 9 &&  !self.isPageEnd {
            self.getAllPhysicalProduct()
        }
        return cell
    }
    @objc func buyAction(btn:UIButton) {
        let optionMenu = UIAlertController(title: API.appName, message: "Are you sure want to purchase this product?", preferredStyle: .alert)
        let buyAction = UIAlertAction(title: "Buy", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if  let data  = self.itemArray.object(at: btn.tag) as? NSDictionary {
                self.openChat(chatUser: data)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(buyAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
@available(iOS 14.0, *)

extension PhysicalProductVC {
    open func openChat(chatUser:NSDictionary) {
        if self.globalRoomId == "" {
            SVProgressHUD.show()
            self.getRoomIdApi(chatUser: chatUser)
        }else {
            self.openChatViewControllers(chatUser: chatUser)
        }
    }
    open func getRoomIdApi(chatUser:NSDictionary){
        if let user_details = chatUser["userDetails"] as? NSDictionary {
            let params:[String:Any] = [
                "user_id": ApplicationStates.getUserID(),
                "chatUserId":user_details["user_id"] ?? ""
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
    }
    func openChatViewControllers(chatUser:NSDictionary) {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
        if let user_details = chatUser["userDetails"] as? NSDictionary {
            let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
            let CMDVC = storyBoard.instantiateViewController(withIdentifier: "ChatDetailVC") as! ChatDetailVC
            if let object = user_details["user_id"] {
                CMDVC.chatUserId = "\(object)"
            }
            if let productName = chatUser["productTitle"] as? String {
                CMDVC.productName = productName
            }
            if let productId = chatUser["productId"] as? String {
                CMDVC.productId = productId
            }
            CMDVC.roomId = globalRoomId
            CMDVC.receiverName = user_details["name"] as? String ?? ""
            self.navigationController?.pushViewController(CMDVC, animated: true)
        }
    }
}
