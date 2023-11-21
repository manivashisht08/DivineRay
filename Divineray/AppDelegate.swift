//
//  AppDelegate.swift
//  Divineray
//
//  Created by     on 08/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import FBSDKCoreKit
import Firebase
import Branch
import AVFoundation
import AVKit


@available(iOS 14.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var navigationDelagate : UINavigationController?
    var tabbar : UITabBarController?
    var chatUserId = ""
    var userId     = ""
    var window: UIWindow?
    var share:AppDelegate?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        self.share = self
        configureKeboard()
        FBSDKCoreKit.ApplicationDelegate.shared.application(application,didFinishLaunchingWithOptions: launchOptions)
        IQKeyboardManager.shared.enable = true
        let navigation = UINavigationController(rootViewController: rootViewController())
        navigation.navigationBar.isHidden =  true;
        self.window?.rootViewController = navigation;
        self.navigationDelagate = navigation
        
        if launchOptions != nil {
            if let option = launchOptions {
                let info = option[UIApplication.LaunchOptionsKey.remoteNotification]
                if (info != nil) {
                }
            }
        }
        
        application.applicationIconBadgeNumber = 0
        if #available(iOS 14.0, *) {
            self.configureNotification()
        } else {
            // Fallback on earlier versions
        }
        let branch: Branch = Branch.getInstance()
        branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: {params, error in
            guard error == nil else {
                return
            }
            if let pars = params as? [String: AnyObject] {
                self.openBranchShareLink(params: pars)
            }
        })
        
        self.setupIAP()
        self.getUpdatesInfo()
        return true
    }
    func configureKeboard() {
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        //        IQKeyboardManager.shared.toolbarTintColor = SSColor.appBlack
        IQKeyboardManager.shared.enableAutoToolbar = true
        //        IQKeyboardManager.shared.disabledDistanceHandlingClasses = [ChatDetailsVC.self, ChatViewController.self]
        IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses = [UIScrollView.self,UIView.self,UITextField.self,UITextView.self,UIStackView.self]
        
    }
    func applicationDidBecomeActive(_ application: UIApplication) {

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch {
            print("AVAudioSessionCategoryPlayback not work")
        }
    }

    func rootViewController() -> UIViewController {
        if ApplicationStates.isUserLoggedIn() && ApplicationStates.isUserTokenIn() {
            let storyboard = UIStoryboard(storyboard: .main)
            return storyboard.instantiateViewController(withIdentifier: "DivinerayTabBarViewController")
        } else {
            let storyboard = UIStoryboard(storyboard: .main)
            return storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        }
    }
    
    func loginSucess() {
        let navigation = UINavigationController(rootViewController: rootViewController())
        navigation.navigationBar.isHidden =  true;
        self.window?.rootViewController = navigation;
    }
    
    func logoutSucess() {
        ApplicationStates.removeUserData()
        let navigation = UINavigationController(rootViewController: rootViewController())
        navigation.navigationBar.isHidden =  true;
        self.window?.rootViewController = navigation;
    }
    
    func logoutSessionSucess() {
        ApplicationStates.removeUserData()
        let navigation = UINavigationController(rootViewController: rootViewController())
        navigation.navigationBar.isHidden =  true;
        self.window?.rootViewController = navigation;
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        Branch.getInstance().continue(userActivity)
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        Branch.getInstance().application(app, open: url, options: options)
        return true
    }
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Divineray")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

@available(iOS 14.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate{
    func configureNotification() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        }else{
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let userInfo = response.notification.request.content.userInfo as? [String:AnyObject]{
            self.openNotificationInformation(remoteNotification: userInfo)
        }
        //touch action
        // tell the app that we have finished processing the user’s action / response
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("application will termiate")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        UserDefaults.standard.set(deviceTokenString as AnyObject, forKey: "device_token")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo,"userInfouserInfo")
        completionHandler (.newData)
        
        //
    }
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge,.banner,.list,.sound])
    }
    
    
    func openNotificationInformation (remoteNotification:[String:AnyObject]) {
        print(remoteNotification,"remoteNotification")
        // background or inactive
        if let userInfo = remoteNotification as? [AnyHashable : Any] {
            let typeStr = ((userInfo["aps"] as? [AnyHashable : Any])?["data"] as? [AnyHashable : Any])?["notificationType"] as? String
            if typeStr == "Message" {
                if let chatUserId = ((userInfo["aps"] as? [AnyHashable : Any])?["data"] as? [AnyHashable : Any])?["chatUserId"] as? String {
                    let storyBoard = UIStoryboard.init(name: "Chat", bundle: nil)
                    
                    let rootVc = storyBoard.instantiateViewController(withIdentifier: "ChatDetailVC") as! ChatDetailVC
                    
                    rootVc.fromAppDelegate = "YES"
                    let userProfilePic = UserDefaults.standard.value(forKey: "userProfilePic") as? String ?? ""
                    // UserDefaults.standard.set(selectedID, forKey: "IID")
                    print(userProfilePic)
                    //                                rootVc.groupName = groupDetails["title"] as? String ?? ""
                    if let object = ((userInfo["aps"] as? [AnyHashable : Any])?["data"] as? [AnyHashable : Any])?["user_id"] as? String {
                        rootVc.userId = "\(object)"
                    }
                    if let object = ((userInfo["aps"] as? [AnyHashable : Any])?["data"] as? [AnyHashable : Any])?["chatUserId"] as? String {
                        rootVc.chatUserId = "\(object)"
                    }
                    
                    if let object = ((userInfo["aps"] as? [AnyHashable : Any])?["data"] as? [AnyHashable : Any])?["roomId"] as? String{
                        
                        rootVc.roomId = "\(object)"
                    }
                    
                    if let object = ((userInfo["aps"] as? [AnyHashable : Any])?["data"] as? [AnyHashable : Any])?["name"] as? String {
                        rootVc.receiverName = "\(object)"
                    }else{
                        rootVc.receiverName = ((userInfo["aps"] as? [AnyHashable : Any])?["data"] as? [AnyHashable : Any])?["username"] as? String ?? ""
                    }
                    if let  topViewController =   UIApplication.topViewController(){
                        topViewController.navigationController?.pushViewController(rootVc, animated: true)
                    }
                    else{
                        let nav = UINavigationController()
                        nav.viewControllers = [self.rootViewController(),rootVc]
                        nav.isNavigationBarHidden = true
                        if #available(iOS 13.0, *){
                            if let scene = UIApplication.shared.connectedScenes.first{
                                guard let windowScene = (scene as? UIWindowScene) else { return }
                                let window: UIWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
                                window.windowScene = windowScene
                                window.rootViewController = nav
                                window.makeKeyAndVisible()
                                self.window = window
                            }
                        } else {
                            self.window?.rootViewController = nav
                            self.window?.makeKeyAndVisible()
                        }
                    }
                }
            }
            else if typeStr == "7" {
                
                if let data = (userInfo["aps"] as? [AnyHashable : Any])?["data"] as? NSDictionary {
                    let liveStreamingVC : LiveStreamingViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LiveStreamingViewController") as! LiveStreamingViewController
                    liveStreamingVC.setViewData(data)
                    
                    if let  topViewController =   UIApplication.topViewController(){
                        topViewController.navigationController?.pushViewController(liveStreamingVC, animated: true)
                    }
                    else{
                        let nav = UINavigationController()
                        nav.viewControllers = [self.rootViewController(),liveStreamingVC]
                        nav.isNavigationBarHidden = true
                        if #available(iOS 13.0, *){
                            if let scene = UIApplication.shared.connectedScenes.first{
                                guard let windowScene = (scene as? UIWindowScene) else { return }
                                let window: UIWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
                                window.windowScene = windowScene
                                window.rootViewController = nav
                                window.makeKeyAndVisible()
                                self.window = window
                            }
                        } else {
                            self.window?.rootViewController = nav
                            self.window?.makeKeyAndVisible()
                        }
                    }
                }
            }
            else if typeStr == "1"{
                if let  notificationViewController : NotificationViewController =   UIApplication.topViewController() as? NotificationViewController {
                    notificationViewController.isFromPush = true
                    notificationViewController.notificationInfo = userInfo["aps"]  as? NSDictionary
                    notificationViewController.getDataActionForPush()
                    return
                }
                else{
                    let notificationViewController : NotificationViewController = NotificationViewController(nibName: "NotificationViewController", bundle: nil)
                    notificationViewController.isFromPush = true
                    notificationViewController.notificationInfo = userInfo["aps"]  as? NSDictionary
                    
                    if let  vc =   UIApplication.topViewController(){
                        vc.navigationController?.pushViewController(notificationViewController, animated: true)
                    }
                    else{
                        let nav = UINavigationController()
                        nav.viewControllers = [self.rootViewController(),notificationViewController]
                        nav.isNavigationBarHidden = true
                        if #available(iOS 13.0, *){
                            if let scene = UIApplication.shared.connectedScenes.first{
                                guard let windowScene = (scene as? UIWindowScene) else { return }
                                let window: UIWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
                                window.windowScene = windowScene
                                window.rootViewController = nav
                                window.makeKeyAndVisible()
                                self.window = window
                            }
                        } else {
                            self.window?.rootViewController = nav
                            self.window?.makeKeyAndVisible()
                        }
                    }
                }
            }
            else{
                let notificationViewController : NotificationViewController = NotificationViewController(nibName: "NotificationViewController", bundle: nil)

                
                if let  vc =   UIApplication.topViewController(){
                    vc.navigationController?.pushViewController(notificationViewController, animated: true)
                }
                else{
                    let nav = UINavigationController()
                    nav.viewControllers = [self.rootViewController(),notificationViewController]
                    nav.isNavigationBarHidden = true
                    if #available(iOS 13.0, *){
                        if let scene = UIApplication.shared.connectedScenes.first{
                            guard let windowScene = (scene as? UIWindowScene) else { return }
                            let window: UIWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
                            window.windowScene = windowScene
                            window.rootViewController = nav
                            window.makeKeyAndVisible()
                            self.window = window
                        }
                    } else {
                        self.window?.rootViewController = nav
                        self.window?.makeKeyAndVisible()
                    }
                }
            }
        }
    }
    
    @objc func delayCall() {
        NotificationCenter.default.post(name: Notification.Name("chatUpdate"), object: nil, userInfo:["chatUserId":self.chatUserId])
        
    }
    func setupIAP() {
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.compactMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                print("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }
}
extension UIViewController {
    
    func showToast(message : String, font: UIFont) {
        self.tabBarController?.tabBar.items?[4].badgeValue = "1"
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(1.0)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}

extension UIApplication {
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

@available(iOS 14.0, *)
extension AppDelegate {
    func openBranchShareLink(params:[String: AnyObject]) {
        //  print(params)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let profileUserId = params["profileUserId"] as? String {
                // your code here
                NotificationCenter.default.post(name: Notification.Name("openShareLink"), object: nil, userInfo:["profileUserId":profileUserId])
            }
        }
    }
}

@available(iOS 14.0, *)
extension AppDelegate {
    func getUpdatesInfo() {
        
        let params:[String:Any] = [
            "user_id":ApplicationStates.getUserID()
        ]
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getForceUpdateDetails, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                
                if let result:[String:Any] = json as? Dictionary {
                    if let data =  result["data"] as? [String:Any] {
                        if let version =  data["ios"] as? String {
                            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                            let appVersionF = (appVersion! as NSString).floatValue
                            let versionF = (version as NSString).floatValue
                            if versionF > appVersionF {
                                let forceUpdateViewController : ForceUpdateViewController = ForceUpdateViewController(nibName: "ForceUpdateViewController", bundle: nil)
                                if let forceUpdate =  data["forceUpdate"] as? String {
                                    
                                    forceUpdateViewController.isForceUpdate = forceUpdate == "0" ? false : true
                                }
                                forceUpdateViewController.titleInfo = data["ios_title"] as? String
                                forceUpdateViewController.despInfo = data["ios_description"] as? String
                                
                                forceUpdateViewController.appstore = data["ios_redirect"] as? String ?? ""
                                forceUpdateViewController.modalPresentationStyle = .currentContext
                                self.navigationDelagate?.view.addSubview(forceUpdateViewController.view)
                                
                                forceUpdateViewController.goBackAction = {
                                    forceUpdateViewController.view.removeFromSuperview()
                                }
                            }
                        }
                    }
                    
                } else {
                }
                break
            case .failure(let error):
                break;
            }
        }
    }
}

