//
//  RightMessageTableViewCell.swift
//  Divineray
//
//  Created by Dharmani Apps mini on 7/17/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit

class RightMessageTableViewCell: UITableViewCell {

    @IBOutlet var messageLBL: UITextView!
    @IBOutlet var backView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dropDownBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        backView.layer.cornerRadius = 11.0
        backView.clipsToBounds = true
        //    _senderTxtProfileImageView.layer.cornerRadius = 7.0;

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
