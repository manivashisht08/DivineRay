//
//  GroupRequestTVCell.swift
//  Divineray
//
//  Created by dr mac on 03/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit

class GroupRequestTVCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
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
