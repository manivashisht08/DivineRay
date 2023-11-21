//
//  ChatListTBCell.swift
//  Divineray
//
//  Created by Dharmani Apps mini on 7/17/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit

class ChatListTBCell: UITableViewCell {

    @IBOutlet weak var timeLbl: UILabel!
    
    @IBOutlet weak var liveView: UIView!
    @IBOutlet weak var profileImgView: UIImageView!
    
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var messageLbl: UILabel!
    
    @IBOutlet weak var notificationBadgeCountBtn: UIButton!
    @IBOutlet weak var profileBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
