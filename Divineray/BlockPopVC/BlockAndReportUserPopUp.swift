//
//  BlockAndReportUserPopUp.swift
//  Arabs
//
//  Created by apple on 22/02/23.
//

import UIKit
protocol BlockUserProtocal{
    func blockUnBlockUser()
    func reportUser()
}
class BlockAndReportUserPopUp: PresentableController {
    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var blockLbl: UILabel!
    var isBlock = Int()
    var blockUserDelegate:BlockUserProtocal?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.optionView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        self.optionView.layer.cornerRadius = 25
        if self.isBlock == 0{
            self.blockLbl.text = "Block User"
        }
        else{
            self.blockLbl.text = "Unblock User"
        }
    }
    
    
    @IBAction func blockUserBtnAction(_ sender: Any) {
        self.dismiss(animated: true){
            self.blockUserDelegate?.blockUnBlockUser()
        }
    }
    
    @IBAction func reportBtnAction(_ sender: Any) {
        self.dismiss(animated: true){
            self.blockUserDelegate?.reportUser()
        }
    }
    
    @IBAction func dismissBtnAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
