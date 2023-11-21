//
//  BlockReportPopVC.swift
//  Divineray
//
//  Created by dr mac on 03/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
protocol updateBlockDel{
    func updateBlock(otherId:String)
    func updateData(otherId:String)
}
class BlockReportPopVC: UIViewController {
    @IBOutlet weak var bgView: UIView!
    var otherId = String()
    var delegate : updateBlockDel?
    override func viewDidLoad() {
        super.viewDidLoad()
        tapdismiss()
        
    }
    func tapdismiss(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        bgView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
    
    func blockApi(){
        var userModel = SignupModel()
        userModel.user_id = ApplicationStates.getUserID()
        userModel.blockTo = otherId
        SVProgressHUD.show()
        UserApiModel().blockUser(model: userModel) { [self] response, error in
        SVProgressHUD.dismiss()
            if let jsonResponse  = response {
                if let parsedData = try? JSONSerialization.data(withJSONObject: jsonResponse,options: .prettyPrinted){
                    let userData = try? JSONDecoder().decode(ApiResponseModel<FavouriteModel>.self, from: parsedData)
                    if userData?.status == 1 {
                        self.dismiss(animated: true)
                        self.delegate?.updateBlock(otherId:otherId)
                    }else if userData?.status == 0 {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func btnReport(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.updateData(otherId:self.otherId)
        }
    }
    @IBAction func btnBlock(_ sender: Any) {
        showMessage(title: API.appName, message: "Are you sure you want to block this user?", okButton: "Yes", cancelButton: "No", controller: self) {
            self.blockApi()

        } cancelHandler: {
            self.dismiss(animated: true)
        }

//        self.dismiss(animated: true) {
//            self.delegate?.updateBlock(otherId:self.otherId)
//        }
    }
    

}
