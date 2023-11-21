//
//  GiftOptionsVC.swift
//  Divineray
//
//  Created by Aravind Kumar on 01/09/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD

@available(iOS 14.0, *)
class GiftOptionsVC: UIViewController {
    var userInfo : NSDictionary!
    
    @IBOutlet weak var lblNoDataFound: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var itemArray : NSMutableArray!
    var isPageEnd = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblNoDataFound.isHidden = true
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.isScrollEnabled = true
        self.itemArray = NSMutableArray.init()
        self.registerNib()
        self.getAllGiftOptions()
        // Do any additional setup after loading the view.
    }
    func registerNib(){
        let nibImgView = UINib(nibName: "GiftCollectionViewCell", bundle: nil)
        collectionView.register(nibImgView, forCellWithReuseIdentifier: "GiftCollectionViewCell")
    }
    func getAllGiftOptions() {
        var lastId = ""
        if self.itemArray.count > 0 {
            if let dict = self.itemArray.lastObject as? NSDictionary {
                lastId = dict["productId"] as! String;
            }
        }else {
            SVProgressHUD.show()
        }
        let params:[String:Any] = [
            "user_id":ApplicationStates.getUserID(),"lastId":lastId,"perPage":"20"
        ]
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAllGiftListing, postData: params) { (result) -> Void in
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
                                self.collectionView.reloadData()
                            }
                            
                        }else {
                            self.isPageEnd = true
                        }
                    }
                } 
                if self.itemArray.count == 0 {
                    self.lblNoDataFound.isHidden = false
                }else {
                    self.lblNoDataFound.isHidden = true
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
extension GiftOptionsVC {
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
                lblInfo.text = "Gift Item"
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

extension GiftOptionsVC : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.itemArray.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : GiftCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier:"GiftCollectionViewCell", for: indexPath as IndexPath) as! GiftCollectionViewCell
        
        if  let dict = self.itemArray.object(at: indexPath.row) as? NSDictionary {
            var ts = dict["coins"] as! String
            ts = ts  + " Coins"
            cell.lblCounsPoins.text = ts
            if let image : String = dict["image"] as? String{
                if image != ""{
                    let url = URL(string: image)
                    cell.imgLogo.kf.setImage(with: url, placeholder:UIImage(named: ""))
                }
            }
        }
        cell.vsf.backgroundColor = UIColor.white
        cell.cornerRadius = 5.0
        self.buttonShowadCreate(globeButton: cell.vsf)
        cell.btnValidate.addTarget(self, action: #selector(buyAction(btn:)), for: .touchUpInside)
        cell.btnValidate.tag = indexPath.row
        if indexPath.row == self.itemArray.count - 10 && self.itemArray.count > 9 &&  !self.isPageEnd {
            self.getAllGiftOptions()
        }
        return cell      //return your cell
    }
    
    func buttonShowadCreate(globeButton : UIButton) {
        
        // Shadow and Radius
        globeButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.55).cgColor
        globeButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        globeButton.layer.shadowOpacity = 1.0
        globeButton.layer.shadowRadius = 5.0
        globeButton.layer.masksToBounds = false
        globeButton.layer.cornerRadius = 5.0
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}
@available(iOS 14.0, *)
extension GiftOptionsVC : UICollectionViewDelegate{
    
    
}
@available(iOS 14.0, *)
extension GiftOptionsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let width = self.view.frame.size.width/2-32;
        
        return CGSize(width: width, height: width*4/3)
    }
    @objc func buyAction(btn:UIButton) {
        if  let info = self.itemArray.object(at: btn.tag) as? NSDictionary {
            if let giftId = info["id"] as? String {
                self.shareGiftAPI(giftID: giftId)
            }
        }
    }
    open func shareGiftAPI(giftID:String){
        let optionMenu = UIAlertController(title: API.appName, message: "Are you sure want to share this gift?", preferredStyle: .alert)
        let buyAction = UIAlertAction(title: "Share", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.shareGiftAction(giftID: giftID)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(buyAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    func shareGiftAction(giftID:String) {
        SVProgressHUD.show()
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID(),
            "gift_id": giftID,
            "shareTo": self.userInfo["user_id"]!
        ]
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.shareGiftURL, postData: params){ (result) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            switch (result) {
            case .success(let json):
                if let result:[String:Any] = json as? Dictionary {
                    if let msg = result["message"] as? String {
                        self.showMessage(title: API.appName, message: msg, okButton: "OK", cancelButton: "", controller: self, okHandler: {
                            if let status = result["status"] as? String {
                            if status == "201" {
                                self.redirectBuy()
                            }
                            }
                        }) {
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
    func redirectBuy() {
        let buyCoinsViewController : BuyCoinsViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyCoinsViewController") as! BuyCoinsViewController
            self.navigationController?.pushViewController(buyCoinsViewController, animated: true)
        }
}
