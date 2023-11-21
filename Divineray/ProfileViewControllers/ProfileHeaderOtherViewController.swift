//
//  ProfileHeaderOtherViewController.swift
//  Divineray
//
//  Created by     on 12/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileHeaderOtherViewController: UIViewController {
    @IBOutlet weak var lblFollowersTxt: UILabel!
    @IBOutlet weak var lblFollowingsTxt: UILabel!
    @IBOutlet weak var btnFollowing: UIButton!
    @IBOutlet weak var btnFollowers: UIButton!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var desprtion: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var namelbl: UIButton!
    
    @IBOutlet weak var msgBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func updateUIForProfileOther(userInfo:NSDictionary) {
        self.namelbl.setTitle("", for: .normal)
        self.desprtion.text = ""
        
        if let userData = userInfo as? [String:Any]{
            if let profilePic = userData["photo"] {
                let url = URL(string: (profilePic as! String))
                profileImage.kf.setImage(with: url, placeholder:UIImage(named: "user"))
            }
            DispatchQueue.main.async {
                
                if let name = userData["name"] as? String {
                    self.namelbl.setTitle(name.uppercased(), for: .normal)
                }
                if let txt = userData["totalFollowers"] as? String {
                    self.lblFollowers.text = txt
                    let count : Int = Int(txt) ?? 0
                    if count > 1 {
                        self.lblFollowersTxt.text = "Followers"
                    }else {
                        self.lblFollowersTxt.text = "Followers"
                    }
                }
                self.lblFollowingsTxt.text = "Following"
                if let txt = userData["totalFollowing"] as? String {
                    self.lblFollowing.text = txt
                    let count : Int = Int(txt) ?? 0
                    if count > 1 {
                        self.lblFollowingsTxt.text = "Following"
                    }else {
                        self.lblFollowingsTxt.text = "Following"
                    }
                }
                if var description = userData["description"] as? String {
                    if description == "0" || description == "" || description == "N/A"{
                        description = "Welcome Divineray"
                    }
                    let sr = NSMutableAttributedString(string: description)
                    // sr.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 14), range: NSRange(location: 0, length: 12))
                    
                    self.desprtion.attributedText = sr
                    
                    self.lblFollowers.text = "0"
                    self.lblFollowing.text = "0"
                    if let totalFollowersV = userData["totalFollowers"] as? String {
                        
                        self.lblFollowers.text = totalFollowersV
                    }
                    if let totalFollowingV = userData["totalFollowing"] as? String {
                        self.lblFollowing.text = totalFollowingV
                    }
                }
            }
        }
    }
    
}
