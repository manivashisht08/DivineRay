//
//  BuyCoinsViewController.swift
//  Divineray
//
//  Created by Aravind Kumar on 24/07/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
@available(iOS 14.0, *)
class BuyCoinsViewController: UIViewController {
    @IBOutlet weak var lblCoins: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var itemArray : NSArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblCoins.text = "0"
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.isScrollEnabled = true
        self.itemArray = NSArray.init()
        self.registerNib()
        self.getAllBuyCoins()
        // Do any additional setup after loading the view.
    }
    
    func registerNib(){
        let nibImgView = UINib(nibName: "BuyCoinCollectionViewCell", bundle: nil)
        collectionView.register(nibImgView, forCellWithReuseIdentifier: "BuyCoinCollectionViewCell")
    }
    func getAllBuyCoins() {
        SVProgressHUD.show()
        let params:[String:Any] = [
            "user_id":ApplicationStates.getUserID()
        ]
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAllCoinsURL, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let result:[String:Any] = json as? Dictionary {
                    
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            if let data =  result["ProductCoins"] as? NSArray {
                                self.itemArray = NSArray.init(array: data)
                                self.collectionView.reloadData()
                            }
                            if let totalCoins = result["totalCoins"] as? String {
                                self.lblCoins.text = totalCoins
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
extension BuyCoinsViewController {
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
                lblInfo.text = "Buy Coins"
            }
            if let btnSetting = navigationBar.viewWithTag(12) as? UIButton {
                btnSetting.isHidden = true
            }
            if let backBtn = navigationBar.viewWithTag(13) as? UIButton {
                backBtn.isHidden = false
                backBtn.addTarget(self, action: #selector(backToBuyCoins), for: .touchUpInside)
            }
        }
    }
    
    @objc func backToBuyCoins() {
        self.navigationController?.popViewController(animated: true)
    }
    func addCustomNavigation() {
        if let navigationBar = self.navigationController?.navigationBar {
            self.navigationItem.setHidesBackButton(true, animated: true);
            
            let firstFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: navigationBar.frame.height)
            let firstLabel = UILabel(frame: firstFrame)
            firstLabel.text = "Buy Coins"
            
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
                backBtn.removeTarget(self, action: #selector(backToBuyCoins), for: .touchUpInside)
            }
        }
    }
}
@available(iOS 14.0, *)
extension BuyCoinsViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.itemArray.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : BuyCoinCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier:"BuyCoinCollectionViewCell", for: indexPath as IndexPath) as! BuyCoinCollectionViewCell
        
        if  let dict = self.itemArray.object(at: indexPath.row) as? NSDictionary {
            cell.lblPrice.text = dict["price"] as? String
            cell.lblCounsPoins.text = dict["coins"] as? String
            cell.imgBg.image = UIImage(named: "imgBg")
            if let image : String = dict["image"] as? String{
                if image != ""{
                    let url = URL(string: image)
                    cell.imgBg.kf.setImage(with: url, placeholder:UIImage(named: "imgBg"))
                }
            }
        }
        
        cell.vsf.backgroundColor = UIColor.white
        cell.cornerRadius = 5.0
        self.buttonShowadCreate(globeButton: cell.vsf)
        cell.btnValidate.addTarget(self, action: #selector(buyAction(btn:)), for: .touchUpInside)
        cell.btnValidate.tag = indexPath.row
        return cell      //return your cell
    }
    @objc func buyAction(globeButton : UIButton) {
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
extension BuyCoinsViewController : UICollectionViewDelegate{
    
}
@available(iOS 14.0, *)
extension BuyCoinsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let width = self.view.frame.size.width/2-32;
        
        return CGSize(width: width, height: width*4/3)
    }
    @objc func buyAction(btn:UIButton) {
        if  let info = self.itemArray.object(at: btn.tag) as? NSDictionary {
            let buyObject : BuyInAppViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyInAppViewController") as! BuyInAppViewController
            buyObject.delegate = self
            buyObject.info = info
            self.navigationController?.pushViewController(buyObject, animated: true)
        }
    }
    func serveHitAfterBuy(userData: [String : Any],transID:String) {
        let params:[String:Any] = ["orderId":transID,"deviceName":UIDevice.current.name,"deviceType":"iOS",
            "user_id":ApplicationStates.getUserID(),"id":userData["id"] ?? ""
        ]
        SVProgressHUD.show()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.purchaseCoins, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        DispatchQueue.main.async {
                            if status == 1 {
                                if let totalCoins = result["totalCoins"] as? String {
                                    self.lblCoins.text = totalCoins
                                }
                                else if let totalCoins = result["totalCoins"] as? Int {
                                    
                                    self.lblCoins.text = String(totalCoins)
                                }
                            }
                            self.showAlertWith(title:API.appName, message:result["message"] as! String)
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
extension BuyCoinsViewController : BuyAlertDelegate {
    func purchaseSucess(userData:[String : Any],transID:String) {
        self.serveHitAfterBuy(userData: userData,transID:transID)
    }
    
    func purchaseFail() {
        //
    }
    
}
