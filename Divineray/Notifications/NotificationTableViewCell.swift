//
//  NotificationTableViewCell.swift
//  Divineray
//
//  Created by Aravind Kumar on 13/10/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func loadCellData(dict:NSDictionary) {
        
        if let profilePic = dict["photo"] {
            let url = URL(string: (profilePic as! String))
            self.userImageView.kf.setImage(with: url, placeholder:UIImage(named: "user"))
        }
        self.infoLbl.text = dict["message"] as? String
        if let time : String = dict["notificationTime"] as? String {
            let timeDouble = Double(time)
            self.timeLbl.text = self.getDateString(timeResult: timeDouble ?? 0)
        }
    }
        func getDateString(timeResult:Double) -> String{
             let date = NSDate(timeIntervalSince1970: timeResult)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
             dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            dateFormatter.timeZone = NSTimeZone() as TimeZone
            return dateFormatter.string(from: date as Date)
    }
}
