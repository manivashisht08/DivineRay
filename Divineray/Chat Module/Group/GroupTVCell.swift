//
//  GroupTVCell.swift
//  Divineray
//
//  Created by dr mac on 02/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit

class GroupTVCell: UITableViewCell {

    @IBOutlet weak var btnJoin: UIButton!
    @IBOutlet weak var participantLbl: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var showOnlineImg: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2
        self.userImage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
