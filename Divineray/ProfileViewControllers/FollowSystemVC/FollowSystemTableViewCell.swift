//
//  FollowSystemTableViewCell.swift
//  Divineray
//
//  Created by Ansh Kumar on 04/07/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit

class FollowSystemTableViewCell: UITableViewCell {
    @IBOutlet weak var btnProfile: UIButton!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
