//
//  FollowSystemViewController.swift
//  Divineray
//
//  Created by Ansh Kumar on 03/07/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD

@available(iOS 14.0, *)
class FollowSystemViewController: UIViewController {
    var dataArray : NSMutableArray!
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    private let kFollowSystemTableViewCell = "FollowSystemTableViewCell"
    
    @IBOutlet weak var tbView: UITableView!
    var isFollowing:Bool!
    var userInfoID:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataArray = NSMutableArray.init()
        self.registerNib()
        self.tbView.delegate = self
        self.tbView.dataSource = self
        self.searchBar.delegate = self
        // Do any additional setup after loading the view.
        self.lblMsg.isHidden = true
    }
    
    func registerNib(){
        NotificationCenter.default.addObserver(self, selector: #selector(FollowSystemViewController.keyboardWasShown(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FollowSystemViewController.keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let nibhView = UINib(nibName: kFollowSystemTableViewCell, bundle: nil)
        self.tbView.register(nibhView, forCellReuseIdentifier: kFollowSystemTableViewCell)
    }
    @objc func keyboardWasShown (notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tbView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            tbView.scrollIndicatorInsets = tbView.contentInset
        }
    }
    
    @objc func keyboardWillBeHidden (notification: NSNotification) {
        tbView.contentInset = UIEdgeInsets.zero
        tbView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.updatenavigationBar()
        self.getDataAction(withSeachOption: false,withSeachText: "")

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
                if self.isFollowing {
                    lblInfo.text = "Following"
                }else {
                    lblInfo.text = "Followers"
                }
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
    
    @objc func getDataAction(withSeachOption:Bool , withSeachText:String) {
        
        var followType = "1"
        if self.isFollowing  {
            followType = "2"
        }else {
            followType = "3"
        }
        var lastUserId = "0"
        if self.dataArray.count > 0 && !withSeachOption{
            if let dict = self.dataArray.lastObject as? NSDictionary  {
                if let lastInfo = dict.value(forKey: "user_id") as? String {
                    lastUserId = lastInfo
                }
            }
        }
        //user_id, followType, profileUserId, seach, lastUserId, perPage
        let params:[String:Any] = [
            "user_id":ApplicationStates.getUserID(),"profileUserId": self.userInfoID ?? "", "followType":followType,"search":withSeachText ,"lastUserId":lastUserId,"perPage":"20"
        ]
        
        if self.dataArray.count == 0 && !withSeachOption{
            SVProgressHUD.show()
        }
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getFollowUsersURL, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            if let data =  result["data"] as? NSArray {
                                if(withSeachOption) {
                                    self.dataArray.removeAllObjects()
                                }
                                self.dataArray.addObjects(from: data as! [Any])
                                if let message =  result["message"] as? String {
                                    self.lblMsg.text = message
                                }
                                
                                if self.dataArray.count == 0 {
                                    self.lblMsg.isHidden = false
                                }else {
                                    self.lblMsg.isHidden = true
                                }
                                self.tbView.reloadData()
                            }
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
    
}
@available(iOS 14.0, *)
extension FollowSystemViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hv = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
        
        hv.backgroundColor = UIColor.clear
        return hv
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell : FollowSystemTableViewCell = tableView.dequeueReusableCell(withIdentifier: kFollowSystemTableViewCell, for: indexPath) as? FollowSystemTableViewCell else {
            fatalError("Unable to Dequeue Reusable Table View Cell")
        }
        if let dict = self.dataArray.object(at: indexPath.row) as? NSDictionary
        {
            if let profilePic = dict["photo"] {
                let url = URL(string: (profilePic as! String))
                cell.userImageView.kf.setImage(with: url, placeholder:UIImage(named: "user"))
            }
            cell.nameLbl.text = dict["name"] as? String
            cell.infoLbl.text = "Divineray"
            cell.followBtn.setTitle("Follow", for: .normal)
            cell.followBtn.isHidden = false
            if let isFollow = dict["follow"] as? String {
                if isFollow == "1" {
                    cell.followBtn.setTitle("Following", for: .normal)
                }
            }
            if let usdf = dict["user_id"] as? String {
                if usdf == ApplicationStates.getUserID() {
                    cell.followBtn.isHidden = true
                }
            }
        }
        
        cell.followBtn.addTarget(self, action: #selector(followAction(btn:)), for: .touchUpInside)
        cell.followBtn.tag = indexPath.row
        
        cell.btnProfile.addTarget(self, action: #selector(openProfileAction(btn:)), for: .touchUpInside)
        cell.btnProfile.tag = indexPath.row
        
        if indexPath.row == self.dataArray.count - 10 {
            if let serch = self.searchBar.text {
                self.getDataAction(withSeachOption: false,withSeachText: serch)
            }else {
                self.getDataAction(withSeachOption: false,withSeachText: "")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
@available(iOS 14.0, *)
extension FollowSystemViewController : UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString(searchText as NSString)
        
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        searchString(searchBar.text! as NSString)
    }
    
    func searchString(_ searchText: NSString)  {
        self.getDataAction(withSeachOption: true,withSeachText:searchText as String)
    }
    
}
@available(iOS 14.0, *)
extension FollowSystemViewController {
    @objc func openProfileAction(btn:UIButton) {
        if  let userData = self.dataArray.object(at: btn.tag) as? NSDictionary {
            if let usdf = userData["user_id"] as? String {
                if usdf == ApplicationStates.getUserID() {
                    self.navigationController?.popToRootViewController(animated: false)
                    self.tabBarController?.selectedIndex = 4
                    return;
                }
            }
            
            let profileObject : ProfileViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            profileObject.userData = userData;
            self.navigationController?.pushViewController(profileObject, animated: true)
        }
    }
    @objc func followAction(btn:UIButton) {
        if  let userData = self.dataArray.object(at: btn.tag) as? NSDictionary {
            var userIdUser = ""
            var followType = "1"
            if let usdf = userData["user_id"] as? String {
                userIdUser = usdf
            }
            if let isFollow = userData["follow"] as? String {
                if isFollow == "1" {
                    followType = "0"
                }
            }
            let params:[String:Any] = [
                "user_id":ApplicationStates.getUserID(),"follow_id":userIdUser,"followType":followType
            ]
            SVProgressHUD.show()
            SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.followUnfollowUserURL, postData: params) { (result) -> Void in
                switch (result) {
                case .success(let json):
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                    if let result:[String:Any] = json as? Dictionary {
                        if let status = result["status"] as? Int {
                            if status == 1 {
                                if self.isFollowing == false{
                                    let dict : NSMutableDictionary = NSMutableDictionary.init(dictionary: userData)
                                    dict.setValue(followType, forKey: "follow")
                                    self.dataArray.replaceObject(at: btn.tag, with: dict)
                                    self.tbView.reloadData()
                                }
                                else{
                                    self.dataArray.removeObject(at: btn.tag)
                                    self.tbView.reloadData()
                                }
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
    }
}
