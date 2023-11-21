//
//  RightImageTVCell.swift
//  Divineray
//
//  Created by dr mac on 03/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit

class RightImageTVCell: UITableViewCell {

    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var mainImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
