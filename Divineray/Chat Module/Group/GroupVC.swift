//
//  GroupVC.swift
//  Divineray
//
//  Created by dr mac on 02/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD

@available(iOS 14.0, *)
class GroupVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var newGroupBgViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var newGroupBgView: UIView!
    @IBOutlet weak var searchBarBgView: UIView!
    @IBOutlet weak var lblGroupName: UILabel!
    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnCross: UIButton!
    var isHide:Bool = false
    var groupJoinListArray = [GroupListData]()
    var filteredTableData = [GroupListData]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapgesture))
        lblGroupName.addGestureRecognizer(tapGesture)
        txtSearch.delegate = self
        txtSearch.addTarget(self, action: #selector(searchRecord), for: .editingChanged)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc func tapgesture(){
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CreateGroupVC") as! CreateGroupVC
//        let vc = CreateGroupVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func searchRecord(sender: UITextField) {
        if sender.text != ""{
            self.filteredTableData = self.groupJoinListArray.filter({$0.groupName!.lowercased().contains(sender.text!.lowercased())})
            if self.filteredTableData.count == 0 {
//                let toast = Toast.text("No Data Found!")
//                toast.show()
                self.filteredTableData.removeAll()
                self.groupJoinListArray.removeAll()
            }else{
                self.groupJoinListArray = self.filteredTableData
            }
            self.groupTableView.reloadData()
        }
        else{
            self.filteredTableData.removeAll()
            self.getAllGroupListApi()
        }
        updateCrossButtonVisibility()
    }
    func updateCrossButtonVisibility() {
        btnCross.isHidden = false
        btnCross.isHidden = txtSearch.text?.isEmpty ?? true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func setTableView(){
        self.groupTableView.dataSource = self
        self.groupTableView.delegate = self
        self.groupTableView.register(UINib(nibName: "GroupTVCell", bundle: nil), forCellReuseIdentifier: "GroupTVCell")
        self.groupTableView.register(UINib(nibName: "HeaderTvCell", bundle: nil), forCellReuseIdentifier: "HeaderTvCell")
        getAllGroupListApi()
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)

    }
    
    func getAllGroupListApi(){
        var userModel = SignupModel()
        userModel.user_id = ApplicationStates.getUserID()
        SVProgressHUD.show()
        UserApiModel().groupListing(model: userModel) { response, error in
            SVProgressHUD.dismiss()
            if let jsonResponse = response{
                if let parsedData = try? JSONSerialization.data(withJSONObject: jsonResponse,options: .prettyPrinted){
                    let userDict  = try? JSONDecoder().decode(ApiResponseModel<[GroupListData]>.self, from: parsedData)
                    if userDict?.status == 1 {
                        self.groupJoinListArray.removeAll()
                        self.groupJoinListArray = userDict?.data ?? []
                        self.groupTableView.reloadData()
                    }else if userDict?.status == 0 {
                        self.groupJoinListArray.removeAll()
                        self.groupTableView.reloadData()
                    }
                }
            }
        }
    }
    @IBAction func searchAction(_ sender: Any) {
        self.isHide = true
        self.groupTableView.reloadData()
        btnCancel.isHidden = false
        btnSearch.isHidden = true
        self.newGroupBgView.isHidden = true
        self.searchBarBgView.isHidden = false
        self.newGroupBgViewHeightCons.constant = 55
    }
    @IBAction func cancelAction(_ sender: Any) {
        self.isHide = false
        self.groupTableView.reloadData()
        btnCancel.isHidden = true
        btnSearch.isHidden = false
        self.newGroupBgView.isHidden = false
        self.searchBarBgView.isHidden = true
        self.newGroupBgViewHeightCons.constant = 90
    }
    
    @IBAction func crossAction(_ sender: Any) {
        txtSearch.text = ""
        btnCross.isHidden = true
    }
    

}
@available(iOS 14.0, *)
extension GroupVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
           return 1
        }else{
            return groupJoinListArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderTvCell", for: indexPath) as! HeaderTvCell
            if isHide{
                cell.lblGroup.text = ""
            }else{
                cell.lblGroup.text = "Groups"
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTVCell", for: indexPath) as! GroupTVCell
            cell.participantLbl.text = "\(self.groupJoinListArray[indexPath.row].userCount ?? "") Participants"
            cell.lblName.text = self.groupJoinListArray[indexPath.row].groupName ?? ""
            cell.userImage.sd_setImage(with: URL(string: self.groupJoinListArray[indexPath.row].groupImage ?? ""), placeholderImage: UIImage(named: "user"))
            cell.showOnlineImg.isHidden = true
            cell.btnJoin.tag = indexPath.row
            if self.groupJoinListArray[indexPath.row].isJoined ?? 0 == 0 {
                cell.btnJoin.setTitle("Join", for: .normal)
                cell.btnJoin.isUserInteractionEnabled = true
                cell.btnJoin.backgroundColor = .red
            }else if self.groupJoinListArray[indexPath.row].isJoined ?? 0 == 1{
                cell.btnJoin.setTitle("Joined", for: .normal)
                cell.btnJoin.isUserInteractionEnabled = false
                cell.btnJoin.backgroundColor = .gray
            }else if self.groupJoinListArray[indexPath.row].isJoined ?? 0 == 2 {
                cell.btnJoin.setTitle("Requested", for: .normal)
                cell.btnJoin.isUserInteractionEnabled = false
                cell.btnJoin.backgroundColor = .gray
            }
            cell.btnJoin.addTarget(self, action: #selector(joinRequestAct(sender:)), for: .touchUpInside)
            return cell
        }
    }
    @objc func joinRequestAct(sender:UIButton){
        var userModel = SignupModel()
        userModel.user_id = ApplicationStates.getUserID()
        userModel.roomId = self.groupJoinListArray[sender.tag].roomID ?? ""
        SVProgressHUD.show()
        UserApiModel().joinGrpRequest(model: userModel) { response, error in
        SVProgressHUD.dismiss()
            if let jsonResponse = response{
                if let parsedData = try? JSONSerialization.data(withJSONObject: jsonResponse,options: .prettyPrinted){
                    let userDict  = try? JSONDecoder().decode(ApiResponseModel<GroupRequestModel>.self, from: parsedData)
                    if userDict?.status == 1 {
                        self.showAlertWith(title: API.appName, message: userDict?.message ?? "")
                        self.getAllGroupListApi()
                    }else if userDict?.status == 0{
                        self.showAlertWith(title: API.appName, message: userDict?.message ?? "")
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.groupJoinListArray[indexPath.row].isJoined ?? 0 == 1{
            let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "ChatDetailVC") as! ChatDetailVC
            vc.profileImg = self.groupJoinListArray[indexPath.row].groupImage ?? ""
            vc.receiverName = self.groupJoinListArray[indexPath.row].groupName ?? ""
            vc.roomId = self.groupJoinListArray[indexPath.row].roomID ?? ""
            vc.isGroup = self.groupJoinListArray[indexPath.row].isGroup ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
//        if indexPath.row == 0 || indexPath.row == 1{
//            let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
//            let vc = storyBoard.instantiateViewController(withIdentifier: "ChatDetailVC") as! ChatDetailVC
////            let vc = GroupChatVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    
}
