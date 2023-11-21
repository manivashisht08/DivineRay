//
//  ReportOptionTableViewCell.swift
//  Arabs
//
//  Created by apple on 23/02/23.
//

import UIKit

class ReportOptionTableViewCell: UITableViewCell {
    @IBOutlet weak var selectReportBtn: UIButton!
    @IBOutlet weak var reportReasonLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
