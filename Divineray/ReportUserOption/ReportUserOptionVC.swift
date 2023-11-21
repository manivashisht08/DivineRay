//
//  ReportUserOptionVC.swift
//  Arabs
//
//  Created by apple on 23/02/23.
//

import UIKit
import SVProgressHUD
@available(iOS 14.0, *)

class ReportUserOptionVC: PresentableController {
    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var optionTableView: UITableView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var optionTableViewHeight: NSLayoutConstraint!
    var responseArr = [NSDictionary]()
    
    
    var  reasonId : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.optionView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        self.optionView.layer.cornerRadius = 25
        self.optionTableView.delegate = self
        self.optionTableView.dataSource = self
        self.optionTableView.register(UINib(nibName: "ReportOptionTableViewCell", bundle: nil), forCellReuseIdentifier: "ReportOptionTableViewCell")
        self.optionTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.fetchingReportOption()
    }
    
    func fetchingReportOption(){
        
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID(),
        ]
        
        SVProgressHUD.show()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.GetAllReportReasons, postData: params){ (result) -> Void in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            switch (result) {
            case .success(let json):
                let resultDict = json as? [String:AnyObject] ?? [:]
                self.responseArr = resultDict["data"] as? [NSDictionary] ?? []
                print(self.responseArr,"responseArr")
                self.optionTableView.reloadData()
                if self.responseArr.count == 1{
                    self.view.endEditing(true)
                }
                break
            case .failure(let error):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DashBoardDataFetch"), object: ["error":error])
                break;
            }
        }
    }
    
    
    
    @IBAction func submitBtnAction(_ sender: Any) {
        self.submitBtn.isHidden = true
        if self.reasonId != nil{
            self.addReportApi(reasonID: self.reasonId)
        }
    }
    
}
@available(iOS 14.0, *)

extension ReportUserOptionVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.responseArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportOptionTableViewCell", for: indexPath) as! ReportOptionTableViewCell
        cell.reportReasonLbl.text = self.responseArr[indexPath.row]["reportreasons"] as? String ?? ""
        let selectedReasonId = self.responseArr[indexPath.row]["reasonId"] as? String ?? "0"
        cell.selectReportBtn.setImage(self.reasonId == selectedReasonId ? UIImage(named: "Group-93") : UIImage(named: "Group-92"), for: .normal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.submitBtn.isHidden = false
        self.reasonId = self.responseArr[indexPath.row]["reasonId"] as? String ?? "0"
        tableView.reloadData()
    }
    
    func addReportApi(reasonID:String?){
        self.dismiss(animated: true) {
            let params:[String:Any] = [
                "user_id": ApplicationStates.getUserID(),
                "reasonId":reasonID!,
                "reportedId":self.title,
                "reportType":"1"
            ]
            
            SVProgressHUD.show()
            SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.AddReportAbuse, postData: params){ (result) -> Void in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                switch (result) {
                case .success(let json):
                    print(json,"json")
                    break
                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DashBoardDataFetch"), object: ["error":error])
                    break;
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                if newsize.height == 0{
                    self.optionTableViewHeight.constant = 100
                }
                else{
                    self.optionTableViewHeight.constant = newsize.height
                    
                }
            }
        }
    }
}
