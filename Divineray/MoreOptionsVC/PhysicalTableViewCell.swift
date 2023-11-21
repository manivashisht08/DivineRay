//
//  PhysicalTableViewCell.swift
//  Divineray
//
//  Created by Aravind Kumar on 05/09/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit

class PhysicalTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var despLbl: UILabel!
    @IBOutlet weak var buyBtn: UIButton!
    
    @IBOutlet weak var nameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
