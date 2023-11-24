//
//  CreateGroupVC.swift
//  Divineray
//
//  Created by dr mac on 03/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD

@available(iOS 14.0, *)
class CreateGroupVC: UIViewController, CreateGroupDetailDelegate {
    func updateAddData() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var createTableView: UITableView!
    @IBOutlet weak var createCollectionView: UICollectionView!
    var followerListArray = [FollowerUserData]()
    var interArr = [UserInterest]()
    var selectedArr = [FollowerUserData]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        interArr.append(UserInterest(id:"1",name: "Wrongu",isSelected: false))
        interArr.append(UserInterest(id:"2",name: "Losa",isSelected: false))
        interArr.append(UserInterest(id:"3",name: "Poseic",isSelected: false))
        interArr.append(UserInterest(id:"4",name: "Kestaye",isSelected: false))
        interArr.append(UserInterest(id:"5",name: "Beota",isSelected: false))
        interArr.append(UserInterest(id:"6",name: "Qoala",isSelected: false))
        interArr.append(UserInterest(id:"7",name: "Jayebx",isSelected: false))
        interArr.append(UserInterest(id:"8",name: "IOqae",isSelected: false))
        interArr.append(UserInterest(id:"9",name: "Leoap",isSelected: false))
        interArr.append(UserInterest(id:"10",name: "Wrongu",isSelected: false))
        interArr.append(UserInterest(id:"11",name: "Losa",isSelected: false))
        interArr.append(UserInterest(id:"12",name: "Prabh",isSelected: false))
        
    }
    
    func setup(){
        createTableView.delegate = self
        createTableView.dataSource = self
        createCollectionView.delegate = self
        createCollectionView.dataSource = self
        createCollectionView.register(UINib(nibName: "CreateGroupCVCell", bundle: nil), forCellWithReuseIdentifier: "CreateGroupCVCell")
        
        self.createTableView.register(UINib(nibName: "SelectGroupTblCell", bundle: nil), forCellReuseIdentifier: "SelectGroupTblCell")
        self.collectionViewHeight.constant = 0
        getFollowerUserApi()
    }
    
    func getFollowerUserApi(){
        var userModel = SignupModel()
        userModel.user_id = ApplicationStates.getUserID()
        userModel.followType = "3"
        userModel.perPage = "100"
        userModel.profileUserId = ApplicationStates.getUserID()
        userModel.lastUserId = "0"
        userModel.search = ""
        SVProgressHUD.show()
        UserApiModel().getFollowUser(model: userModel) { response, error in
            SVProgressHUD.dismiss()
            if let jsonResponse = response{
                if let parsedData = try? JSONSerialization.data(withJSONObject: jsonResponse,options: .prettyPrinted){
                    let userDict  = try? JSONDecoder().decode(ApiResponseModel<[FollowerUserData]>.self, from: parsedData)
                    if userDict?.status == 1 {
                        self.followerListArray.removeAll()
                        self.followerListArray = userDict?.data ?? []
                        self.createTableView.reloadData()
                    }else if userDict?.status == 0 {
                        self.followerListArray.removeAll()
                        self.createTableView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAction(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CreateGroupDetailVC") as! CreateGroupDetailVC
        vc.delegate = self
        vc.createGroupArray = self.selectedArr
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
@available(iOS 14.0, *)
extension CreateGroupVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateGroupCVCell", for: indexPath) as! CreateGroupCVCell
        cell.nameLbl.text = self.selectedArr[indexPath.row].name
        cell.btnCross.tag = indexPath.row
        cell.mainImg.sd_setImage(with: URL(string: self.selectedArr[indexPath.row].photo ?? ""), placeholderImage: UIImage(named: "user"))

        cell.btnCross.addTarget(self, action: #selector(crossAct(sender:)), for: .touchUpInside)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 110)
    }
    @objc func crossAct(sender:UIButton){
        let dlt = sender.tag
        self.selectedArr.remove(at: dlt)
//        let dataid = self.selectedArr.map({$0.id})
//        if dataid.contains(interArr[sender.tag].id ?? ""){
//            let valueToDelete = interArr[sender.tag].id ?? ""
//            for (index, value) in selectedArr.enumerated() {
//                if selectedArr[index].id == valueToDelete{
//                    self.interArr[index].isSelected = false
////                    self.interArr.remove(at: index)
//                }
//            }
//        }
//        self.selectedArr.removeValue(forKey: selectedArr[sender.tag])
        self.interArr[sender.tag].isSelected = false
        if selectedArr.count == 0 {
            self.collectionViewHeight.constant = 0
        }else{
            self.collectionViewHeight.constant = 110
        }
        self.createCollectionView.reloadData()
        self.createTableView.reloadData()
    }
}
@available(iOS 14.0, *)
extension CreateGroupVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followerListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectGroupTblCell", for: indexPath) as! SelectGroupTblCell
        cell.lblParticipant.isHidden = true
        cell.nameLbl.text = followerListArray[indexPath.row].name ?? ""
        cell.mainImg.sd_setImage(with: URL(string: self.followerListArray[indexPath.row].photo ?? ""), placeholderImage: UIImage(named: ""))
        if followerListArray[indexPath.row].isSelected == true{
            cell.btnCheck.setImage(UIImage(named: "SelectGroupImage"), for: .normal)
        }else{
            cell.btnCheck.setImage(UIImage(named: "UnSelectGroupImage"), for: .normal)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if followerListArray[indexPath.row].isSelected  == true {
            followerListArray[indexPath.row].isSelected = false
        }else {
            followerListArray[indexPath.row].isSelected = true
        }
        self.selectedArr = followerListArray.filter({$0.isSelected == true})
        if self.selectedArr.count > 0{
            self.collectionViewHeight.constant = 110
        }else{
            self.collectionViewHeight.constant = 0
            self.selectedArr.removeAll()
        }
        print(self.selectedArr.count,"Count")
        DispatchQueue.main.async {
            self.createCollectionView.reloadData()
            self.createTableView.reloadData()
        }
        
    
        
    }
    
}
struct UserInterest: Codable {
    var id, name: String?
    var isSelected :Bool?
    
    mutating func updateSelected(isSelected:Bool){
        self.isSelected = isSelected
    }
}
struct UserInterestt: Codable {
    var id, name: String?
    var isSelected :Bool?
    
    mutating func updateSelected(isSelected:Bool){
        self.isSelected = isSelected
    }
}
