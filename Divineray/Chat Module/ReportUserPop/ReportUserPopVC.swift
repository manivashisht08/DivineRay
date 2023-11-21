//
//  ReportUserPopVC.swift
//  Divineray
//
//  Created by dr mac on 03/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
import IQKeyboardManagerSwift

class ReportUserPopVC: UIViewController,UITextViewDelegate {
    @IBOutlet weak var reportTableView: UITableView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var otherTxtView: GrowingTextView!
    var selectedIndex:Int?
    var reportListing = [ReportData]()
    var otherId = String()
    var reportTyp = String()
    var reason = String()
    var reasonId = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        tapdismiss()
        setUp()
        reportListingApi()
    
    }
    func setUp(){
        reportTableView.delegate = self
        reportTableView.dataSource = self
        reportTableView.register(UINib(nibName: "ReportTableCell", bundle: nil), forCellReuseIdentifier: "ReportTableCell")
        self.reportTableView.allowsSelection = true
        otherTxtView.delegate = self
//        self.btnOther.isSelected = false
    }
    func tapdismiss(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        bgView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
    
    func reportListingApi(){
        var userModel = SignupModel()
        userModel.user_id = ApplicationStates.getUserID()
        SVProgressHUD.show()
        UserApiModel().allReportReason(model: userModel) { response, error in
        SVProgressHUD.dismiss()
            if let jsonReponse = response{
                if let parsedData = try? JSONSerialization.data(withJSONObject: jsonReponse,options: .prettyPrinted){
                    let userDict  = try? JSONDecoder().decode(ApiResponseModel<[ReportData]>.self, from: parsedData)
                    if userDict?.status == 1 {
                        self.reportListing.removeAll()
                        self.reportListing = userDict?.data ?? []
                        self.reportTableView.reloadData()
                    }else if userDict?.status == 0 {
                        self.reportListing.removeAll()
                        self.reportTableView.reloadData()
                    }
                }
            }
        }
    }
    
    func reasonApi(reasonId:String,reason:String){
        var userModel = SignupModel()
        userModel.user_id = ApplicationStates.getUserID()
        userModel.reasonId = reasonId
        userModel.reportedId = otherId
        userModel.reportreasons = reason
        userModel.reportType = reportTyp
        SVProgressHUD.show()
        UserApiModel().ReportReasonSubmit(model: userModel) { response, error in
        SVProgressHUD.dismiss()
            if let jsonResponse  = response {
                if let parsedData = try? JSONSerialization.data(withJSONObject: jsonResponse,options: .prettyPrinted){
                    let userData = try? JSONDecoder().decode(ApiResponseModel<FavouriteModel>.self, from: parsedData)
                    if userData?.status == 1 {
                        self.showAlertMessage(title: API.appName, message: userData?.message ?? "", okButton: "OK", controller: self) {
                            self.dismiss(animated: true)
                        }
                        self.reportTableView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func btnSubmit(_ sender: UIButton) {
        if self.otherTxtView.text == "" && selectedIndex == nil{
            showAlertWith(title: API.appName, message: "Please write/select reason for report.")
        }else if otherTxtView.text != nil && otherTxtView.text != ""{
            self.reason = self.otherTxtView.text
            self.reasonId = "0"
            self.reportTyp = "1"
            reasonApi(reasonId: self.reasonId, reason: self.reason)
        }else if self.selectedIndex != nil{
            self.reason = ""
            self.reportTyp = "2"
            reasonApi(reasonId: self.reasonId, reason: self.reason)
        }
//        self.dismiss(animated: true)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.selectedIndex = nil
        self.reportTyp = "1"
        self.reason = self.otherTxtView.text
        self.reportTableView.reloadData()
            }
    
    func textViewDidEndEditing(_ textView: UITextView) {
                
            }
}
extension ReportUserPopVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportListing.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportTableCell", for: indexPath) as! ReportTableCell
        cell.reportLbl.text = self.reportListing[indexPath.row].reportreasons ?? ""
        if indexPath.row == selectedIndex{
            cell.btnReport.setImage(UIImage(named: "dotttttt"), for: .normal)
        }else{
            cell.btnReport.setImage(UIImage(named: "blnnkkkk"), for: .normal)
        }
        return cell

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.reportTyp = "2"
        self.reasonId = self.reportListing[indexPath.row].reasonID ?? ""
        self.reportTableView.reloadData()
    }
}
