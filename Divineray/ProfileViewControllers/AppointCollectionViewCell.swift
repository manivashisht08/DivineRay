//
//  AppointCollectionViewCell.swift
//  Divineray
//
//  Created by Aravind Kumar on 24/07/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit

class AppointCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTimeZone: UILabel!
    @IBOutlet weak var lbvlType: UILabel!
    @IBOutlet weak var btnBook: UIButton!
    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var imgMainBg: UIImageView!
    @IBOutlet weak var vsf: UIButton!
    @IBOutlet weak var lblCounsPoins: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!

    @IBOutlet weak var lblTime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

}
