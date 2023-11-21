//
//  DivinerayTabBarViewController.swift
//  Divineray
//
//  Created by     on 11/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
class DivinerayTabBarViewController: UITabBarController, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationNotifactaion(notification:)), name: Notification.Name("chatUpdate"), object: nil)
        let playerClass = PlaylistViewController.init(nibName: "PlaylistViewController", bundle: Bundle.main)
        self.viewControllers?[0] = playerClass;
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
        let chatVC = storyBoard.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC
        self.viewControllers?[3] = chatVC!

        self.setTabBarItems()
        self.delegate = self
        UITabBar.appearance().barTintColor = UIColor.white // your color
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.tabbar = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileScreenOPen()
    }
    
    @objc func methodOfReceivedNotificationNotifactaion(notification: Notification) {
        if self.selectedIndex == 3 {
            if let dict  =  notification.userInfo {
                self.navigationController?.popToRootViewController(animated: false)
                if let chatUserId  = dict["chatUserId"] as? String {
                    if  let CVC = self.viewControllers?[3] as?  ChatVC {
                        CVC.senderIdFromPush = chatUserId;
                        CVC.fromAppDelegate = "YES"
                        CVC.chatListApi()
                    }
                }
            }
            
        }else {
            self.selectedIndex  = 3
            if let dict  =  notification.userInfo {
                if let chatUserId  = dict["chatUserId"] as? String {
                    if  let CVC = self.viewControllers?[3] as?  ChatVC {
                        CVC.senderIdFromPush = chatUserId;
                        CVC.fromAppDelegate = "YES"
                    }
                }
            }
        }
    }
    
    func profileScreenOPen() {
            NotificationCenter.default.addObserver(self, selector: #selector(self.profileScreen), name: .init("updateUserImage"), object: nil)
        }
    
    @objc func profileScreen(){
        self.selectedIndex = 0
    }
    
    var hasTopNotch: Bool {
        if #available(iOS 13.0,  *) {
            return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0 > 20
        }else{
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
    }
    func setTabBarItems(){
        let imgV : CGFloat = 2.0;
        let vc3 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddPostsVC") as! AddPostsVC
        self.viewControllers?[2] = vc3
        let myTabBarItem1 = (self.tabBar.items?[0])! as UITabBarItem
        
        myTabBarItem1.image = UIImage(named: "home")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem1.selectedImage = UIImage(named: "hm")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem1.title = ""
        myTabBarItem1.imageInsets = UIEdgeInsets(top: imgV, left: 0, bottom: 0, right: 0)
        
        let myTabBarItem2 = (self.tabBar.items?[1])! as UITabBarItem
        myTabBarItem2.image = UIImage(named: "serch")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem2.selectedImage = UIImage(named: "srch")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem2.title = ""
        myTabBarItem2.imageInsets = UIEdgeInsets(top: imgV, left: 0, bottom: 0, right: 0)
        
        let myTabBarItem3 = (self.tabBar.items?[2])! as UITabBarItem
        myTabBarItem3.image = UIImage(named: "add")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem3.selectedImage = UIImage(named: "add1")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem3.title = ""
        myTabBarItem3.imageInsets = UIEdgeInsets(top: imgV, left: 0, bottom: 0, right: 0)
    
        
        let myTabBarItem4 = (self.tabBar.items?[3])! as UITabBarItem
        myTabBarItem4.image = UIImage(named: "chat")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem4.selectedImage = UIImage(named: "chats")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem4.title = ""
        myTabBarItem4.imageInsets = UIEdgeInsets(top: imgV, left: 0, bottom: 0, right: 0)
        
        
        let myTabBarItem5 = (self.tabBar.items?[4])! as UITabBarItem
        myTabBarItem5.image = UIImage(named: "pf1")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem5.selectedImage = UIImage(named: "pf")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem5.title = ""
        myTabBarItem5.imageInsets = UIEdgeInsets(top: imgV, left: 0, bottom: 0, right: 0)
//        self.addCentreBtn()
        
    }
    
//    func addCentreBtn(){
//        let centerBtn = UIButton.init(type: .custom)
//        centerBtn.backgroundColor = UIColor.clear
//        centerBtn.addTarget(self, action: #selector(cleckMiddle), for: .touchUpInside)
//        let screenWidth = UIScreen.main.bounds.size.width
//        let btnSize =  screenWidth/5;
//        var xPostion = screenWidth - btnSize
//        xPostion = xPostion/2
//
//        centerBtn.frame = CGRect(x: xPostion, y: 0, width: btnSize, height: self.tabBar.frame.size.height)
//        self.tabBar.addSubview(centerBtn)
//    }
}

@available(iOS 14.0, *)
extension DivinerayTabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController == tabBarController.viewControllers?[2] {
//            return false
            self.tabBar.tintColor = UIColor.white
            self.tabBar.isTranslucent = false;
        }
        if viewController == tabBarController.viewControllers?[0]  {
            self.tabBar.tintColor = UIColor.clear
            self.tabBar.isTranslucent = true;
        }else {
            self.tabBar.tintColor = UIColor.white
            self.tabBar.isTranslucent = false;
        }
        if viewController == tabBarController.viewControllers?[4] {
            self.tabBarController?.tabBar.items?[4].badgeValue = nil
        }
        return true
    }
    
//    @objc func cleckMiddle() {
//        let recorder = SLRecordingViewController.init(nibName: "SLRecordingViewController", bundle: Bundle.main)
//        self.navigationController?.pushViewController(recorder, animated: true)
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddPostsVC") as! AddPostsVC
//        vc.hidesBottomBarWhenPushed = false
//        print("Tabbardd33")
//        self.tabBarController?.tabBar.isHidden = false
//        self.navigationController?.pushViewController(vc, animated: false)
//    }
    
}
