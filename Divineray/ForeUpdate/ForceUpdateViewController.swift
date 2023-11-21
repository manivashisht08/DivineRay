//
//  ForceUpdateViewController.swift
//  Divineray
//
//  Created by Aravind Kumar on 13/06/21.
//  Copyright © 2021 Dharmani Apps. All rights reserved.
//

import UIKit

class ForceUpdateViewController: UIViewController {
    @IBOutlet weak var hspT: NSLayoutConstraint!
    @IBOutlet weak var ss: NSLayoutConstraint!
    var goBackAction:(() -> Void)?

    var isForceUpdate = false
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesp: UILabel!
    var titleInfo: String?
    var despInfo: String?
    var appstore: String = ""

    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var hsConst: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.updateBoxHeight()
    }

    func updateBoxHeight() {
        self.hspT.constant = 30.0
        self.ss.constant = 50.0
        self.lblTitle.text = self.titleInfo
        self.lblDesp.text = self.despInfo
        self.hsConst.constant = 140
            + self.lblDesp.frame.size.height
        self.btnCancel.isHidden = isForceUpdate
        

    }

    @IBAction func cancelAction(_ sender: Any) {
        goBackAction?()

//        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateAction(_ sender: Any) {
        if self.appstore.isEmpty {
            goBackAction?()
        }
        if let url = URL(string: self.appstore) {
            UIApplication.shared.open(url, options: [:]) { tr in
                
            }
        }else {
            goBackAction?()
        }
    }
}
