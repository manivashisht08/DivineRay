//
//  SelectGroupVC.swift
//  Divineray
//
//  Created by dr mac on 02/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD

@available(iOS 14.0, *)
class SelectGroupVC: UIViewController {

    @IBOutlet weak var sgTableView: UITableView!
    var interArr = [UserInterestt]()
    var groupListArray = [GroupListData]()
    var descript = String()
    var taggs = String()
    var typp = String()
    var postImg = Data()
    var postVideo = Data()
    var postWidth = String()
    var postHeight = String()
    var mediaTyp = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableViewDelegate()
        interArr.append(UserInterestt(id:"1",name: "Wrongu",isSelected: false))
        interArr.append(UserInterestt(id:"2",name: "Losa",isSelected: false))
        interArr.append(UserInterestt(id:"3",name: "Poseic",isSelected: false))
        interArr.append(UserInterestt(id:"4",name: "Kestaye",isSelected: false))
        interArr.append(UserInterestt(id:"5",name: "Beota",isSelected: false))
        interArr.append(UserInterestt(id:"6",name: "Qoala",isSelected: false))
        
    }
    // MARK: - Functions
    
    func setTableViewDelegate(){
        self.sgTableView.delegate = self
        self.sgTableView.dataSource = self
        self.sgTableView.register(UINib(nibName: "SelectGroupTblCell", bundle: nil), forCellReuseIdentifier: "SelectGroupTblCell")
        getAllGroupListApi()
    }
    @IBAction func backbtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func postGroupAction(_ sender: UIButton) {
//        let selectedArray = groupListArray.filter({$0.isSelected == true})
//        let selAry =  selectedArray.map({$0.groupCreatedBy ?? "0"})
//        if (selectedArray.count < 1){
//     showAlertWith(title: "DivineRay", message: "Please select minimum 1 person.")
//        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DivinerayTabBarViewController") as! DivinerayTabBarViewController
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    func addPostGroupApi(groupId:String){
        var userModel = SignupModel()
        userModel.user_id = ApplicationStates.getUserID()
        userModel.title = ""
        userModel.description = descript
        userModel.tags = taggs
        userModel.musicId = ""
        if self.mediaTyp == "1"{
            userModel.postVideo = postVideo
            userModel.postImage = postImg
            userModel.type = typp
            userModel.postWidth = postWidth
            userModel.postHeight = postHeight
        }else{
            userModel.postImage = postImg
            userModel.type = typp
        }
        userModel.isGroupPost = "1"
        userModel.groupIds = groupId
        SVProgressHUD.show()
        UserApiModel().addEditPost(model: userModel) { response, error in
            SVProgressHUD.dismiss()
            if let jsonResponse = response{
                if let parsedData = try? JSONSerialization.data(withJSONObject: jsonResponse,options: .prettyPrinted){
                    let userDict = try? JSONDecoder().decode(ApiResponseModel<AddPostModel>.self, from: parsedData)
                    if userDict?.status == 1{
                        self.showAlertMessage(title: "DivineRay", message: userDict?.message ?? "", okButton: "OK", controller: self) {
                            NotificationCenter.default.post(name: .init("updateUserImage"), object: nil)
                        }
                    }

                }
            }
        }
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
                        self.groupListArray.removeAll()
                        self.groupListArray = userDict?.data ?? []
                        self.sgTableView.reloadData()
                    }else if userDict?.status == 0 {
                        self.groupListArray.removeAll()
                        self.sgTableView.reloadData()
                    }
                }
            }
        }
    }
    
}
// MARK: - TableViewExtension
@available(iOS 14.0, *)

extension SelectGroupVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectGroupTblCell", for: indexPath) as! SelectGroupTblCell
        cell.lblParticipant.isHidden = false
        cell.lblParticipant.text = "\(self.groupListArray[indexPath.row].userCount ?? "") Participants"
        cell.nameLbl.text = self.groupListArray[indexPath.row].groupName ?? ""
        cell.mainImg.sd_setImage(with: URL(string: self.groupListArray[indexPath.row].groupImage ?? ""),placeholderImage: UIImage(named: "user12"))
        if groupListArray[indexPath.row].isSelected == true{
            cell.btnCheck.setImage(UIImage(named: "SelectGroupImage"), for: .normal)
        }else{
            cell.btnCheck.setImage(UIImage(named: "UnSelectGroupImage"), for: .normal)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if groupListArray[indexPath.row].isSelected  == true {
            groupListArray[indexPath.row].isSelected = false
        }else{
            groupListArray[indexPath.row].isSelected = true
        }
        self.sgTableView.reloadData()
    }
}
