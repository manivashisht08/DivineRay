//
//  CreateGroupDetailVC.swift
//  Divineray
//
//  Created by dr mac on 03/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
protocol CreateGroupDetailDelegate{
    func updateAddData()
}


@available(iOS 14.0, *)
class CreateGroupDetailVC: UIViewController {

    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var groupNameText: UITextField!
    @IBOutlet weak var createCollectionView: UICollectionView!
    var imagePickerController = UIImagePickerController()
    var delegate:CreateGroupDetailDelegate?
    var createGroupArray = [FollowerUserData]()
    var arrParticipants = [("Ellipse 11073","Wroau"),("Ellipse 11073","Losa")]
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionViewDelegate()
    }
    
    func validation() -> Bool{
        let isvalidFirstname = Validator.validateGroupName(name: groupNameText.text ?? "")
//        let isvalidlastname = Validator.validateLastName(name: lNameText.text ?? "")
//        let isvalidbio = Validator.validatebio(caption: bioText.text ?? "")
        
        guard isvalidFirstname.0 == true else {
            showAlertWith(title: "DivineRay", message: "\(isvalidFirstname.1)")
            print("isvalidFirstname  \(isvalidFirstname)")
            return false
        }
        
        return true
    }
    
    
    func setCollectionViewDelegate(){
        self.createCollectionView.delegate = self
        self.createCollectionView.dataSource = self
        self.createCollectionView.register(UINib(nibName: "CreateGroupCVCell", bundle: nil), forCellWithReuseIdentifier: "CreateGroupCVCell")
    }
    
    func addCreateGroupApi(){
        var userModel = SignupModel()
        userModel.user_id = ApplicationStates.getUserID()
        userModel.groupName = self.groupNameText.text
        userModel.ids = ""
        userModel.groupImage = self.mainImg.image?.pngData()
        SVProgressHUD.show()
        UserApiModel().CreateGroupChat(model: userModel) { response, error in
        SVProgressHUD.dismiss()
            if let jsonResponse = response{
                if let parsedData = try? JSONSerialization.data(withJSONObject: jsonResponse,options: .prettyPrinted){
                    let userModel = try?JSONDecoder().decode(ApiResponseModel<CreateGroupModel>.self, from: parsedData)
                    if userModel?.status == 1 {
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DivinerayTabBarViewController") as! DivinerayTabBarViewController
                        vc.selectedIndex = 3
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCreate(_ sender: Any) {
        let status = validation()
        if createGroupArray.count < 1{
           showAlertWith(title: "DivineRay", message: "Please add participants")
        }else{
            if status {
                addCreateGroupApi()
            }
        }
    }
    
    @IBAction func btnCamera(_ sender: Any) {
        openCamera()
    }
    
    @IBAction func btnAdd(_ sender: Any) {
        self.delegate?.updateAddData()
    }
    
    func openCamera(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Camera", style: .default){ [self] action in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera;
                imagePickerController.allowsEditing = true
                self.imagePickerController.delegate = self
                self.present(imagePickerController, animated: true, completion: nil)
            }
            else{
                let alert = UIAlertController(title: "Camera not found", message: "This device has no camera", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default,handler: nil))
                present(alert, animated: true,completion: nil)
            }
        }
        let action1 = UIAlertAction(title: "Gallery", style: .default){ action in
            self.imagePickerController.allowsEditing = false
            self.imagePickerController.sourceType = .photoLibrary
            self.imagePickerController.delegate = self
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let action2 = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(action)
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
}
@available(iOS 14.0, *)
extension CreateGroupDetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let tempImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        mainImg.image  = tempImage
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
@available(iOS 14.0, *)
extension CreateGroupDetailVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return createGroupArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateGroupCVCell", for: indexPath) as! CreateGroupCVCell
//        if indexPath.row == arrParticipants.count{
//            cell.mainImg.image = UIImage(named: "AddImage")
//            cell.nameLbl.text = "Add"
//            cell.btnCross.isHidden = true
//        }else{
//            cell.mainImg.image = UIImage(named: arrParticipants[indexPath.row].0)
            cell.nameLbl.text = self.createGroupArray[indexPath.row].name
        cell.mainImg.sd_setImage(with: URL(string: self.createGroupArray[indexPath.row].photo ?? ""), placeholderImage: UIImage(named: ""))
             cell.btnCross.isHidden = false
            cell.btnCross.tag = indexPath.row
            cell.btnCross.addTarget(self, action: #selector(crossAction(sender:)), for: .touchUpInside)
            
//        }
        return cell
    }
    @objc func crossAction(sender: UIButton){
        let dltImg = sender.tag
        createGroupArray.remove(at: dltImg)
        createCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 75, height: 110)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == arrParticipants.count{
            print("POPBack")
            
//            self.navigationController?.popViewController(animated: true)
//            self.popViewController(true)
        }else{
            
        }
        }
}
