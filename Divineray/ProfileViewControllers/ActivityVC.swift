//
//  ActivityVC.swift
//  Divineray
//
//  Created by dr mac on 06/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit

class ActivityVC: UIViewController {

    @IBOutlet weak var creatorVideoSharedLbl: UILabel!
    @IBOutlet weak var creatorVideoLbl: UILabel!
    @IBOutlet weak var userVideoShared: UILabel!
    @IBOutlet weak var userVideoLbl: UILabel!
    @IBOutlet weak var userTimeLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
