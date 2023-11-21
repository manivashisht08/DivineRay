//
//  ProfileSettingHeaderTableViewCell.swift
//  Divineray
//
//  Created by     on 15/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit

class ProfileSettingHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func updateheader() {
        if let userData = UserDefaults.standard.value(forKey: "user_details") as? [String:Any]{
            
            if let profilePic = userData["photo"] {
                let url = URL(string: (profilePic as! String))
                self.userImage.kf.setImage(with: url, placeholder:UIImage(named: "user"))
            }
            if let name = userData["name"] as? String {
                self.nameLbl.text = name.uppercased()
            }
            if let email = userData["email"] as? String {
                self.emailLbl.text = email
            }
        }
    }
}
