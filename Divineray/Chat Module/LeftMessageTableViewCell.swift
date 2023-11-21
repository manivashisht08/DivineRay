//
//  LeftMessageTableViewCell.swift
//  Divineray
//
//  Created by Dharmani Apps mini on 7/17/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit

class LeftMessageTableViewCell: UITableViewCell {

    @IBOutlet var messageLBL: UITextView!
    @IBOutlet var backView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var senderTxtProfileImageView: UIImageView!
    @IBOutlet weak var dropDownBtn: UIButton!
    @IBOutlet weak var recieverUserNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        backView.layer.cornerRadius = 11.0
        backView.clipsToBounds = true
        senderTxtProfileImageView.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
