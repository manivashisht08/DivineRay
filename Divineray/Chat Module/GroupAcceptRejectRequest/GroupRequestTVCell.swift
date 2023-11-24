//
//  GroupRequestTVCell.swift
//  Divineray
//
//  Created by dr mac on 03/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit
protocol GroupRequestListDelegate{
    func acceptRequest(cell:GroupRequestTVCell)
    func rejectRequest(cell:GroupRequestTVCell)
//    func openProfile(cell:NotificationCell)
}
class GroupRequestTVCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    var groupListArray : GroupRequestListData?
    var delegate : GroupRequestListDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func dataPass(data:GroupRequestListData){
        self.groupListArray = data
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnAccept(_ sender: UIButton) {
        self.delegate?.acceptRequest(cell: self)
    }
    
    @IBAction func btnReject(_ sender: UIButton) {
        self.delegate?.rejectRequest(cell: self)
    }
    
}
