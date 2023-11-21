//
//  ProfileViewController.swift
//  Divineray
//
//  Created by     on 11/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
@available(iOS 14.0, *)
class ProfileViewController : WMStickyPageController {
    @objc var isFromBranch = false
    var firstTimeLoad = false;
    var favLoaded = false;
    lazy var globalRoomId = String()
    @objc var userData:NSDictionary!
    var myUserData = NSDictionary.init()
    var favData : NSArray!
    var  headerView : ProfileHeaderViewController!
    var  headerViewOther : ProfileHeaderOtherViewController!
    var  firstViewController : AllViewController!
    var  secondViewController : FavViewController!
    var  thirdViewController : MoreMenuViewController!
    
    var isViewDisAppier = false;
    var userInfo: NSDictionary?
    @IBOutlet weak var childView: UIView!
    var kWMHeaderViewHeight : CGFloat = 404.0
    
    // MARK: Override methods
    
    override func viewDidLoad() {
        
        //        if self.userData != nil {
        kWMHeaderViewHeight = kWMHeaderViewHeight + 30;
        //}
        self.setUI()
        
        self.title = ""
        self.navigationItem.setHidesBackButton(true, animated: true);
        
        self.firstViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllViewController") as? AllViewController
        if self.userData != nil {
            self.firstViewController.isUserSef = false
            if let usdf = self.userData?["user_id"] as? String {
                self.firstViewController.userProfileUserId = usdf
            }
        }
        self.secondViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FavViewController") as? FavViewController
        
        self.thirdViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MoreMenuViewController") as? MoreMenuViewController
        
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self;
        self.userInfo = NSDictionary.init()
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
        // Do any additional setup after loading the view.
        self.getProfileDetails()
    }
    
    func getProfileDetails() {
        var userId = ApplicationStates.getUserID()
        if self.userData != nil {
            if let usdf = self.userData?["user_id"] as? String {
                userId = usdf
            }
        }
        let params:[String:Any] = [
            "user_id":ApplicationStates.getUserID(),"lastId":"0","perPage":"20","profileUserId":userId
        ]
        SVProgressHUD.show()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getProfileDetailsURL, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.firstTimeLoad = true
                }
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            if let data =  result["data"] as? [String : Any] {
                                if self.userData != nil {
                                    self.userData = data as NSDictionary
                                    self.updateFollowInformation()
                                }else {
                                    self.myUserData = data as NSDictionary
                                    self.headerView.updateUIForProfile(userInfo: self.myUserData)
                                }
                            }
                            if let UserVideos = result["UserVideos"] as? NSArray {
                                if(self.firstViewController != nil) {
                                    self.firstViewController.updateData(data: UserVideos)
                                }
                            }
                            self.favLoaded = false;
                            if let FavVideos = result["FavVideos"] as? NSArray {
                                self.favData = FavVideos;
                                
                            }
                            if self.isFromBranch && self.userData != nil  {
                                self.selectIndex = 2
                                self.isFromBranch = false
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
    func addCustomNavigation() {
        if let navigationBar = self.navigationController?.navigationBar {
            self.navigationItem.setHidesBackButton(true, animated: true);
            
            let firstFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: navigationBar.frame.height)
            let firstLabel = UILabel(frame: firstFrame)
            firstLabel.text = "Profile"
            firstLabel.textAlignment = .center
            firstLabel.font = UIFont(name: "Poppins-Medium", size: 17)
            firstLabel.tag = 11
            navigationBar.addSubview(firstLabel)
            
            let btnFrame = CGRect(x: UIScreen.main.bounds.size.width-54, y: 0, width: 44, height: navigationBar.frame.height)
      
            
            let btnBackFrame = CGRect(x: 9, y: 0, width: 44, height: navigationBar.frame.height)
            let btnBack = UIButton(type: .custom)
            btnBack.frame = btnBackFrame
            btnBack.setImage(UIImage(named: "back"), for: .normal)
            navigationBar.addSubview(btnBack)
            btnBack.tag = 13
            btnBack.isHidden = true
            
            let btnSetting = UIButton(type: .custom)
            btnSetting.frame = btnFrame
            btnSetting.setImage(UIImage(named: "st"), for: .normal)
            navigationBar.addSubview(btnSetting)
            btnSetting.tag = 12
            if self.userData == nil {
                btnSetting.isHidden = false
                btnSetting.setImage(UIImage(named: "st"), for: .normal)
                self.headerView.updateUIForProfile(userInfo:  self.myUserData)
            }else {
                btnSetting.isHidden = true
                self.headerViewOther.updateUIForProfileOther(userInfo:self.userData ?? NSDictionary.init())
            }
        }
    }
    func updatenavigationBar(){
        if let navigationBar = self.navigationController?.navigationBar {
            if let bs = navigationBar.viewWithTag(78) as? UIButton {
                bs.removeFromSuperview()
            }
            if self.userData == nil {
                let btn = UIButton(type: .custom)
                btn.frame = CGRect(x: navigationBar.frame.size.width - 98 ,y: 0,width: 44,height: 44)
                btn.tag = 78
                btn.setImage(UIImage(named: "notT"), for: .normal)
                btn.addTarget(self, action: #selector(notTop), for: .touchUpInside)
                navigationBar.addSubview(btn)
            }
            if let lblInfo = navigationBar.viewWithTag(11) as? UILabel {
                lblInfo.text = "Profile"
            }
            
            
            if let btnSetting = navigationBar.viewWithTag(12) as? UIButton {
                btnSetting.addTarget(self, action: #selector(self.settingsAction), for: .touchUpInside)
                btnSetting.isHidden = false
                if self.userData != nil {
                    btnSetting.isHidden = false
                    btnSetting.setImage(UIImage(named: "Vector-8"), for: .normal)
                }else {
                    btnSetting.isHidden = false
                    btnSetting.setImage(UIImage(named: "st"), for: .normal)
                }
            }
            
            if let backBtn = navigationBar.viewWithTag(13) as? UIButton {
                backBtn.isHidden = true
                backBtn.addTarget(self, action: #selector(backToTop), for: .touchUpInside)
                if self.userData != nil {
                    backBtn.isHidden = false
                }
            }
        }
    }
    
    @objc func backToTop() {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func notTop() {
        let notificationViewController : NotificationViewController = NotificationViewController(nibName: "NotificationViewController", bundle: nil)
        notificationViewController.isFromPush = false
        notificationViewController.notificationInfo = nil
        self.navigationController?.pushViewController(notificationViewController, animated: true)
    }
    @objc func followAction() {
        var userIdUser = ""
        var followType = "1"
        if self.userData != nil {
            if let usdf = self.userData?["user_id"] as? String {
                userIdUser = usdf
            }
            if let isFollow = self.userData?["follow"] as? String {
                if isFollow == "1" {
                    followType = "0"
                }
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
                            let dict : NSMutableDictionary = NSMutableDictionary.init(dictionary: self.userData)
                            dict.setValue(followType, forKey: "follow")
                            self.userData = dict;
                            self.updateFollowInformation()
                            self.getProfileDetailsInBG()
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
    func updateFollowInformation() {
        if(self.userData != nil && (self.headerViewOther != nil)) {
            self.headerViewOther.btnFollow.setTitle("Follow", for: .normal)
            if let follow = self.userData.value(forKey: "follow") as? String {
                if follow == "1" {
                    self.headerViewOther.btnFollow.setTitle("Unfollow", for: .normal)
                }
            }
            self.headerViewOther.updateUIForProfileOther(userInfo:self.userData ?? NSDictionary.init())
        }
    }
    @objc func settingsAction() {
        if self.userData != nil {
            let pop = BlockAndReportUserPopUp()
            pop.blockUserDelegate = self
            pop.modalPresentationStyle = .overFullScreen
            self.present(pop, animated: true)
        }
        else{
            let settingsViewController : SettingsViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            self.navigationController?.pushViewController(settingsViewController, animated: true)
        }
        
    }
    @objc func openMessage() {
        if self.userData != nil {
            if !self.globalRoomId.isEmpty {
                self.openChatViewControllers()
            }else {
                self.getRoomIdFromServiceAndCallChat()
            }
        }
    }
    func getRoomIdFromServiceAndCallChat() {
        var chatUserId = ""
        if self.userData != nil {
            if let usdf = self.userData?["user_id"] as? String {
                chatUserId = usdf
            }
        }
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID(),
            "chatUserId":chatUserId
        ]
        SVProgressHUD.show()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.generateRoomIDURL, postData: params){ (result) -> Void in
            
            SVProgressHUD.dismiss()
            switch (result) {
            case .success(let json):
                let resultDict = json as? [String:AnyObject] ?? [:]
                let dataArr = resultDict["data"] as? [AnyObject] ?? []
                let respDict = dataArr[0] as? [String:AnyObject] ?? [:]
                self.globalRoomId = respDict["roomId"] as? String ?? ""
                self.openChatViewControllers()
                break
            case .failure(let _):
                break;
            }
        }
    }
    func openChatViewControllers() {
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
        let CMDVC = storyBoard.instantiateViewController(withIdentifier: "ChatDetailVC") as! ChatDetailVC
        if let object = self.userData?["user_id"] {
            CMDVC.chatUserId = "\(object)"
        }
        CMDVC.roomId = globalRoomId
        CMDVC.receiverName = self.userData?["name"] as! String
        self.navigationController?.pushViewController(CMDVC, animated: true)
    }
    func updatenavigationBarBack(){
        
        if let navigationBar = self.navigationController?.navigationBar {
            if let backBtn = navigationBar.viewWithTag(78) as? UIButton {
                backBtn.removeTarget(self, action: #selector(notTop), for: .touchUpInside)
                backBtn.removeFromSuperview()
            }
            
            if let backBtn = navigationBar.viewWithTag(13) as? UIButton {
                backBtn.removeTarget(self, action: #selector(backToTop), for: .touchUpInside)
            }
            if let btnSetting = navigationBar.viewWithTag(12) as? UIButton {
                btnSetting.removeTarget(self, action: #selector(settingsAction), for: .touchUpInside)
                
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
        if self.userData != nil {
            self.getProfileDetailsInBG()
        }else {
            self.getMYProfileDetails()
        }
        
        if self.isViewDisAppier {
            self.isViewDisAppier = false
            if (self.firstViewController != nil) {
                self.firstViewController.updateConstValue()
            }
            if (self.secondViewController != nil) {
                self.secondViewController.updateConstValue()
            }
        }
        self.updatenavigationBar()
        if self.userData == nil {
            if self.headerView != nil {
                self.headerView.updateUIForProfile(userInfo:  self.myUserData)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        self.updatenavigationBarBack()
        isViewDisAppier = true
    }
    func setUI() {
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 15;
        self.menuViewStyle = .line;
        self.titleFontName = "Poppins-Medium"
        self.menuItemWidth = 80;//[UIScreen mainScreen].bounds.size.width / self.menuCategories.count;
        self.menuViewHeight = 50;
        
        self.maximumHeaderViewHeight = kWMHeaderViewHeight;
        self.minimumHeaderViewHeight = 50;
        self.menuView?.contentMargin = 0;
        self.titleColorSelected = UIColor(red: 0.0/255.0, green: 62.0/255.0, blue: 152.0/255.0, alpha: 1.0)
        self.titleColorNormal = UIColor.black
        self.menuView?.lineColor = UIColor(red: 0.0/255.0, green: 62.0/255.0, blue: 152.0/255.0, alpha: 1.0)
        self.headerView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileHeaderViewController") as? ProfileHeaderViewController
        self.headerViewOther = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileHeaderOtherViewController") as? ProfileHeaderOtherViewController
        
        if self.userData != nil {
            self.headerViewOther.view.backgroundColor = UIColor.white
            self.headerViewOther.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: kWMHeaderViewHeight)
            self.view.addSubview(self.headerViewOther.view)
            self.headerViewOther.viewWillLayoutSubviews()
            self.headerViewOther.updateUIForProfileOther(userInfo:self.userData ?? NSDictionary.init())
            self.headerViewOther.btnFollow.addTarget(self, action: #selector(followAction), for: .touchUpInside)
            self.headerViewOther.btnFollow.setTitle("Follow", for: .normal)
            self.updateFollowInformation()
            self.headerViewOther.btnFollowing.addTarget(self, action: #selector(followingAction), for: .touchUpInside)
            self.headerViewOther.btnFollowers.addTarget(self, action: #selector(followersAction), for: .touchUpInside)
            self.headerViewOther.msgBtn.addTarget(self, action: #selector(openMessage), for: .touchUpInside)
            
        }else {
            self.headerView.view.backgroundColor = UIColor.white
            self.headerView.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: kWMHeaderViewHeight)
            self.view.addSubview(self.headerView.view)
            self.headerView.viewWillLayoutSubviews()
            self.headerView.btnFollowing.addTarget(self, action: #selector(followingAction), for: .touchUpInside)
            self.headerView.btnFollowers.addTarget(self, action: #selector(followersAction), for: .touchUpInside)
            self.headerView.btnShare.addTarget(self, action: #selector(shareProfileAction), for: .touchUpInside)
            
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let scrollView : UIScrollView = self.view as! UIScrollView
        scrollView.delegate = self
        if self.userData != nil {
            self.headerViewOther.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: kWMHeaderViewHeight)
        }else {
            self.headerView.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: kWMHeaderViewHeight)
        }
    }
    
    override func numbersOfChildControllers(in pageController: WMPageController) -> Int {
//        if self.userData != nil {
//            return 3
//        }
        return 2
    }
    override func pageController(_ pageController: WMPageController, titleAt index: Int) -> String {
        if index == 0 {
            return "All"
        }else  if index == 1{
            return "Favourite"
        }else {
            return "Services"
        }
    }
    override func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        if index == 0 {
            return self.firstViewController
        }else if index == 1 {
            return self.secondViewController
        }
        else {
            return self.thirdViewController
        }
    }
    
    override func pageController(_ pageController: WMPageController, didEnter viewController: UIViewController, withInfo info: [AnyHashable : Any]) {
        
        if let asp : AllViewController = viewController as?  AllViewController {
            asp.updateConstValue()
        }
        if let asp : FavViewController = viewController as?  FavViewController {
            asp.updateConstValue()
            if self.userData != nil {
                self.firstViewController.isUserSef = false
                if let usdf = self.userData?["user_id"] as? String {
                    self.secondViewController.userProfileUserId = usdf
                }
            }
            
            if self.favData != nil {
                if(self.secondViewController != nil) {
                    self.secondViewController.updateData(data: self.favData)
                    self.favData = nil;
                    self.favLoaded = true;
                }
            }else {
                if(self.secondViewController != nil) {
                    //self.secondViewController.updateData(data:self.favData )
                }
            }
        }
        if let asp : MoreMenuViewController = viewController as?  MoreMenuViewController {
            asp.userInfo = self.userData
        }
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        if scrollView.contentOffset.y < 0 {
            self.view.setNeedsLayout()
        }
    }
    @objc func followingAction() {
        
        let followSystemViewController : FollowSystemViewController = FollowSystemViewController(nibName: "FollowSystemViewController", bundle: nil)
        followSystemViewController.isFollowing = true
        var userId = ApplicationStates.getUserID()
        if self.userData != nil {
            if let usdf = self.userData?["user_id"] as? String {
                userId = usdf
            }
        }
        followSystemViewController.userInfoID = userId;
        self.navigationController?.pushViewController(followSystemViewController, animated: true)
        
    }
    @objc func shareProfileAction() {
        
        let params:[String:Any] = [
            "profileUserId": ApplicationStates.getUserID(),
            "type":"1"
        ]
        SVProgressHUD.show()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.ShareUserProfile, postData: params){ (result) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            switch (result) {
            case .success(let json):
                let resultDict = json as? [String:AnyObject] ?? [:]
                if let share  = resultDict["shareUrl"] as? String {
                    self.openShareDSP(share: share)
                }else if let message  = resultDict["message"] as? String {
                    self.showAlertWith(title: API.appName, message: message)
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
    func openShareDSP(share:String) {
        DispatchQueue.main.async {
            if let url = URL(string: share) {
                let items:Array = [url] as [Any]
                let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                self.present(ac, animated: true)
            }
        }
    }
    @objc func followersAction() {
        let followSystemViewController : FollowSystemViewController = FollowSystemViewController(nibName: "FollowSystemViewController", bundle: nil)
        followSystemViewController.isFollowing = false
        var userId = ApplicationStates.getUserID()
        if self.userData != nil {
            if let usdf = self.userData?["user_id"] as? String {
                userId = usdf
            }
        }
        followSystemViewController.userInfoID = userId;
        self.navigationController?.pushViewController(followSystemViewController, animated: true)
    }
}
@available(iOS 14.0, *)
extension ProfileViewController  {
    func getProfileDetailsInBG() {
        var userId = ApplicationStates.getUserID()
        if self.userData != nil {
            if let usdf = self.userData?["user_id"] as? String {
                userId = usdf
            }
        }
        let params:[String:Any] = [
            "user_id":ApplicationStates.getUserID(),"onlyProfile":"1","profileUserId":userId
        ]
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getProfileDetailsURL, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        
                        if status == 1 {
                            if let data =  result["data"] as? [String : Any] {
                                print(data,"data")
                                if self.userData != nil {
                                    self.userData = data as NSDictionary
                                    self.updateFollowInformation()
                                }else {
                                    self.myUserData = data as NSDictionary
                                    self.headerView.updateUIForProfile(userInfo: self.myUserData)
                                }
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
    
    func getMYProfileDetails() {
        if(!firstTimeLoad) {
            return
        }
        let userId = ApplicationStates.getUserID()
        let params:[String:Any] = [
            "user_id":ApplicationStates.getUserID(),"lastId":"0","perPage":"20","profileUserId":userId
        ]
        //        SVProgressHUD.show()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getProfileDetailsURL, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        
                        if status == 1 {
                            if let data =  result["data"] as? [String : Any] {
                                print(data,"data")
                                if self.userData != nil {
                                    self.userData = data as NSDictionary
                                    self.updateFollowInformation()
                                }else {
                                    self.myUserData = data as NSDictionary
                                    self.headerView.updateUIForProfile(userInfo: self.myUserData)
                                }
                            }
                            if let UserVideos = result["UserVideos"] as? NSArray {
                                if(self.firstViewController != nil) {
                                    self.firstViewController.removeData()
                                    self.firstViewController.updateData(data: UserVideos)
                                }
                            }
                            if let FavVideos = result["FavVideos"] as? NSArray {
                                if(self.favLoaded) {
                                    self.secondViewController.removeData()
                                    self.secondViewController.updateData(data: FavVideos)
                                }
                            }
                        }
                    }
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
extension ProfileViewController :BlockUserProtocal{
    func blockUnBlockUser() {
        self.blockUnBlockUserAction()
    }
    
    func reportUser() {
        var userId = ""
        if self.userData != nil {
            if let usdf = self.userData?["user_id"] as? String {
                userId = usdf
            }
        }
        let profileObject : ReportUserOptionVC  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReportUserOptionVC") as! ReportUserOptionVC
        profileObject.title = userId
        profileObject.modalPresentationStyle = .overFullScreen
        self.present(profileObject, animated: true)
    }
    
    
    func blockUnBlockUserAction() {
        var userId = ""
        if self.userData != nil {
            if let usdf = self.userData?["user_id"] as? String {
                userId = usdf
            }
        }
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID(),
            "blockTo":userId
        ]
        SVProgressHUD.show()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.blockUser, postData: params){ (result) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            switch (result) {
            case .success(let json):
                print(json,"blockUnBlockUserAction")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.loginSucess()
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
