//
//  BuyInAppViewController.swift
//  Divineray
//
//  Created by Aravind Kumar on 11/01/21.
//  Copyright © 2021 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol BuyAlertDelegate:AnyObject {
    func purchaseSucess(userData:[String : Any],transID:String)
    func purchaseFail()
}

class BuyInAppViewController: UIViewController {
    var info:NSDictionary!
    @IBOutlet weak var upgadeTxtLbl: UILabel!
    @IBOutlet weak var lblDesp: UILabel!
    weak var delegate:BuyAlertDelegate?
    
    @IBOutlet weak var tbView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tbView.delegate = self
        self.tbView.dataSource = self
        let price = info["price"] as! String
        let coins = info["coins"] as! String
        upgadeTxtLbl.text = "BUY \(coins)";
        self.lblDesp.text = price
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.updatenavigationBar()
        self.tbView.reloadData()
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
    @IBAction func buyAction(_ sender: Any) {
        self.buyInformationCall()
    }
    @IBAction func pAction(_ sender: Any) {
        let inAppBrowserViewController : InAppBrowserViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InAppBrowserViewController") as! InAppBrowserViewController
        inAppBrowserViewController.optionFrom = 1
        self.navigationController?.pushViewController(inAppBrowserViewController, animated: true)
    }
    @IBAction func tAction(_ sender: Any) {
        let inAppBrowserViewController : InAppBrowserViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InAppBrowserViewController") as! InAppBrowserViewController
        inAppBrowserViewController.optionFrom = 2
        self.navigationController?.pushViewController(inAppBrowserViewController, animated: true)
        
    }
}
extension BuyInAppViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let hv = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0))
        return hv;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 0
    }
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 3
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.row == 0{
            return 70
        }
        else if indexPath.row == 1{
            return 80
        }
        else{
            return 140
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell")
            let titleLbl =  cell?.contentView.viewWithTag(11) as! UILabel
            let titleLblInfo =  cell?.contentView.viewWithTag(12) as! UILabel
            titleLbl.text = "Divineray Coins";
            titleLblInfo.text = "Tune in your divine wisdom";
            return cell!
        }else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell1")
            cell?.backgroundColor =  UIColor.clear
            let titleLbl =  cell?.contentView.viewWithTag(11) as! UILabel
            let coins = info["coins"] as! String
            titleLbl.text = "Buy \(coins)"
            return cell!
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell2")
            let titleLbl =  cell?.contentView.viewWithTag(11) as! UILabel
            titleLbl.text = "Payment will be charged to iTunes Account at confirmation of purchase."
            return cell!
            
        }
    }
    func buyInformationCall() {
        SVProgressHUD.show()
        let productId = info["appleId"] as! String
        SwiftyStoreKit.purchaseProduct(productId, atomically: true,simulatesAskToBuyInSandbox: false) { result in
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                self.delegate?.purchaseSucess(userData: self.info as! [String : Any], transID: purchase.transaction.transactionIdentifier ?? "")
                self.backAction()
            } else if case .error(let error) = result {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }                    // purchase error
                self.showAlertWith(title:API.appName, message: "\(error)")
            }else{
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
}
