//
//  SelectGroupTblCell.swift
//  Divineray
//
//  Created by dr mac on 03/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit

class SelectGroupTblCell: UITableViewCell {
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lblParticipant: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func selectedAction(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
