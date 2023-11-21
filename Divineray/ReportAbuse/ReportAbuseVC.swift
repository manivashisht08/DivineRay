//
//  ReportAbuseVC.swift
//
//
//  Created by Aravind kumar on 8/31/17.

//

import UIKit
import Alamofire
import SVProgressHUD
@available(iOS 14.0, *)

class ReportAbuseVC: UIViewController {
    
    var  filteredUserData : NSArray!
    var selectedIndex = 0;
    @objc var reportId = "";
    @objc var reportType = "1"
    
    @IBOutlet weak var tbView: UITableView!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.filteredUserData = NSArray.init()
        self.tbView.delegate =  self;
        self.tbView.dataSource =  self
        
        selectedIndex=0
        self.getAllReportInformations()
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
        
    }
    func addCustomNavigation() {
        if let navigationBar = self.navigationController?.navigationBar {
            self.navigationItem.setHidesBackButton(true, animated: true);
            
            let firstFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: navigationBar.frame.height)
            let firstLabel = UILabel(frame: firstFrame)
            firstLabel.text = "Report Abuse"
            
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
                lblInfo.text = "Report Abuse"
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
    
    
    func getAllReportInformations() {
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID()
        ]
        SVProgressHUD.show()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAllReportReasonURL, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            if let data = result["data"] as? NSArray {
                                self.filteredUserData = data;
                            }
                            self.tbView.reloadData()
                        }
                    }
                } else {
                    self.showAlertWith(title:API.appName, message:AlertMessages.GeneralErrorMsg)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func submitAction(button: UIButton) {
        var reasonId = ""
        if let dict = self.filteredUserData[self.selectedIndex] as? NSDictionary{
            reasonId = dict["reasonId"] as? String ?? ""
        }
        
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID(),"reasonId":reasonId,"reportedId":self.reportId,"reportType":self.reportType,"reportedBy": ApplicationStates.getUserID()
        ]
        SVProgressHUD.show()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAddReportAbuseURL, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            DispatchQueue.main.async {
                                
                                self.navigationController?.popViewController(animated: true)
                                self.showToastSucessMessage(result["message"] as? String ?? "")
                                
                            }
                        }
                    }
                } else {
                    self.showAlertWith(title:API.appName, message:AlertMessages.GeneralErrorMsg)
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

extension ReportAbuseVC : UITableViewDataSource,UITableViewDelegate
{
    //MARK: Table View Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if self.filteredUserData.count == indexPath.row{
            return 100
        }
        return 60;//Choose your custom row height
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.filteredUserData.count == 0 {
            return 0
        }
        return self.filteredUserData.count+1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.filteredUserData.count
        {
            let   cell = tableView.dequeueReusableCell(withIdentifier: "submitCell")!
            let submitButton:UIButton = cell.contentView.viewWithTag(11) as! UIButton
            submitButton.addTarget(self, action: #selector(ReportAbuseVC.submitAction(button:)), for: UIControl.Event.touchUpInside)
            cell.backgroundColor = UIColor.clear
            return cell;
        }else
        {
            let   cell = tableView.dequeueReusableCell(withIdentifier: "infoCell")!
            
            let selectButton:UIButton = cell.contentView.viewWithTag(1) as! UIButton
            selectButton.isUserInteractionEnabled = false;
            if indexPath.row == selectedIndex {
                selectButton.isSelected =  true;
            }else {
                selectButton.isSelected =  false;
                
            }
            let titleLbl:UILabel = cell.contentView.viewWithTag(2) as! UILabel
            if let dict = self.filteredUserData[indexPath.row] as? NSDictionary{
                titleLbl.text = dict["reportReasons"] as? String
            }
            cell.backgroundColor = UIColor.clear
            
            return cell;
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedIndex = indexPath.row
        self.tbView.reloadData()
    }
}
