//
//  LeftImageTVCell.swift
//  Divineray
//
//  Created by dr mac on 03/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit

class LeftImageTVCell: UITableViewCell {

    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var profileImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
