//
//  StreamUsersTableCell.swift
//  Divineray
//
//  Created by apple on 13/05/22.
//  Copyright © 2022 Dharmani Apps. All rights reserved.
//

import UIKit

protocol StreamUsersTableCellDelegate: NSObjectProtocol {
    func hostAcceptRejectRequest(isAccept: Bool, user: UserDetail?)
    func hostKickUser(user: UserDetail?)

}


class StreamUsersTableCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    @IBOutlet weak var kickUserButton: UIButton!
    
    
    var user: UserDetail?
    var delegate: StreamUsersTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setCellData(user: UserDetail?, isRequest: Bool, _ delegate: StreamUsersTableCellDelegate?,hostID:String) {
        self.user     = user
        self.delegate = delegate
        let photoStr = user?.photo?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        userImage.sd_setImage(with: URL(string: photoStr), placeholderImage: UIImage(named: "user"))
        nameLabel.text = user?.name
        if hostID == ApplicationStates.getUserID(){
            if isRequest == true {
                acceptButton.isHidden = user?.status == "1"
                rejectButton.isHidden = user?.status == "1"
                kickUserButton.isHidden = user?.status == "0"
            } else {
                acceptButton.isHidden = true
                rejectButton.isHidden = true
                kickUserButton.isHidden = true
            }
        }
        else{
            acceptButton.isHidden = true
            rejectButton.isHidden = true
            kickUserButton.isHidden = true
        }
        
        print("users status is *** \(user?.status)")
    }
    
    @IBAction func kickUserAction(_ sender: UIButton) {
        self.delegate?.hostKickUser(user: self.user)
    }
    
    @IBAction func acceptAction(_ sender: UIButton) {
        self.delegate?.hostAcceptRejectRequest(isAccept: true, user: self.user)
    }
    
    @IBAction func rejectAction(_ sender: UIButton) {
        self.delegate?.hostAcceptRejectRequest(isAccept: false, user: self.user)
    }
    
}
