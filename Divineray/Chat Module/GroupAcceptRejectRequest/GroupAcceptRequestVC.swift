//
//  GroupAcceptRequestVC.swift
//  Divineray
//
//  Created by dr mac on 03/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD

class GroupAcceptRequestVC: UIViewController {

    @IBOutlet weak var groupRequestTable: UITableView!
    @IBOutlet weak var nameLbl: UILabel!
    var groupListArray = [GroupRequestListData]()
    var name = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
    }
    func setTableView(){
        self.groupRequestTable.delegate = self
        self.groupRequestTable.dataSource = self
        self.groupRequestTable.register(UINib(nibName: "GroupRequestTVCell", bundle: nil), forCellReuseIdentifier: "GroupRequestTVCell")
        groupRequestListingApi()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func groupRequestListingApi(){
        var userModel = SignupModel()
        userModel.user_id = ApplicationStates.getUserID()
        SVProgressHUD.show()
        UserApiModel().groupRequestListing(model: userModel) { response, error in
        SVProgressHUD.dismiss()
            if let jsonResponse = response{
                if let parsedData = try? JSONSerialization.data(withJSONObject: jsonResponse,options: .prettyPrinted){
                    let userDict  = try? JSONDecoder().decode(ApiResponseModel<[GroupRequestListData]>.self, from: parsedData)
                    if userDict?.status == 1 {
                        self.groupListArray.removeAll()
                        self.groupListArray = userDict?.data ?? []
                        self.groupRequestTable.reloadData()
                    }else if userDict?.status == 0 {
                        self.groupListArray.removeAll()
                        self.groupRequestTable.reloadData()
                        self.showAlertWith(title: API.appName, message: userDict?.message ?? "")
                    }
                }
            }
        }
    }
    
    func acceptRejectRequestApi(userID:String,type:String,roomId:String,groupCreatedBy:String){
        var userModel = SignupModel()
        userModel.user_id = userID
        userModel.roomId = roomId
        userModel.groupCreatedBy = groupCreatedBy
        userModel.type = type
        SVProgressHUD.show()
        UserApiModel().acceptRejectGroupRequest(model: userModel) { response, error in
            SVProgressHUD.dismiss()
            if let jsonResponse = response{
                if let parsedData = try? JSONSerialization.data(withJSONObject: jsonResponse,options: .prettyPrinted){
                    let userDict  = try? JSONDecoder().decode(ApiResponseModel<[GroupRequestListData]>.self, from: parsedData)
                    if userDict?.status == 1 {
                        self.groupRequestListingApi()
                    }else if userDict?.status == 0 {
                        self.showAlertWith(title: API.appName, message: userDict?.message ?? "")
                    }

                }
            }
        }
    }

}
extension GroupAcceptRequestVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupRequestTVCell", for: indexPath) as! GroupRequestTVCell
        cell.delegate = self
        cell.dataPass(data: groupListArray[indexPath.row])
        cell.nameLbl.text = self.groupListArray[indexPath.row].name ?? ""
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width/2
        cell.userImage.layer.masksToBounds = true
        cell.userImage.sd_setImage(with: URL(string: self.groupListArray[indexPath.row].image ?? ""), placeholderImage: UIImage(named: "user"))
        return cell
    }
 
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension GroupAcceptRequestVC :GroupRequestListDelegate{
    func acceptRequest(cell: GroupRequestTVCell) {
        self.acceptRejectRequestApi(userID: cell.groupListArray?.userID ?? "", type: "1", roomId: cell.groupListArray?.roomID ?? "", groupCreatedBy: cell.groupListArray?.groupCreatedBy ?? "")
    }
    
    func rejectRequest(cell: GroupRequestTVCell) {
        self.acceptRejectRequestApi(userID: cell.groupListArray?.userID ?? "", type: "2", roomId: cell.groupListArray?.roomID ?? "", groupCreatedBy: cell.groupListArray?.groupCreatedBy ?? "")
    }
    
    
}
