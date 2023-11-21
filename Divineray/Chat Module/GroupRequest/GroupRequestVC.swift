//
//  GroupRequestVC.swift
//  Divineray
//
//  Created by dr mac on 02/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit
protocol GroupRequestDelegate{
   
    func updateGroupData()
}
class GroupRequestVC: UIViewController {
    @IBOutlet weak var bgView: UIView!
    var delegate : GroupRequestDelegate?
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
    
    @IBAction func btnGroupRequest(_ sender: UIButton) {
        self.dismiss(animated: true){
            self.delegate?.updateGroupData()
        }
    }
    
    

}
