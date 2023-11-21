//
//  CreateGroupCVCell.swift
//  Divineray
//
//  Created by dr mac on 03/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit

class CreateGroupCVCell: UICollectionViewCell {

    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var mainImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.mainImg.layer.cornerRadius = self.mainImg.frame.size.width/2
        self.mainImg.layer.masksToBounds = true
    }

}
