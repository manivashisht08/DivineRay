//
//  ChatCell.swift
//  CoWorkerUser
//
//  Created by Rakesh Kumar on 08/05/18.
//  Copyright © 2018 SevenSkyLander. All rights reserved.
//

import UIKit
import SDWebImage


enum ChatDirection {
    case left
    case right
}

class ChatCell: UITableViewCell {

    let leadingConstraintValue:CGFloat = 12.0
    let trailingConstraintValue:CGFloat = 100.0
    let timeConstraintRightSide:CGFloat = 22.0
    let timeConstraintRightSideWithRead:CGFloat = 30.0
    let timeConstraintLeftSide:CGFloat = 10.0
        
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var chatBg: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var leftImage: UIImageView!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingTimeLabelConstraint: NSLayoutConstraint!
    

    
   
    
    var previousDate: String?
    var selectedModel: MessageData?
    var selectedIndexPath : IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.timeLabel.textAlignment    = .left
        self.messageLabel.text    = "message label"
        self.timeLabel.text      = "12:14"
        self.leftImage.contentMode = .scaleAspectFill
    }

    func configure(model : MessageData? , indexPath : IndexPath, previousDate:String? = nil, chatType: String?) {
        self.selectedModel = model
        self.selectedIndexPath = indexPath
        self.previousDate = previousDate
        self.setChatData(model: model)
        self.setChatDirection()
    }
    
    func setChatData(model: MessageData?) {
        
        let unixtimeInterval = NSString(string: model?.comment_time ?? "")   
        
        let date = Date(timeIntervalSince1970:  unixtimeInterval.doubleValue)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "hh:mm a"
        let strDate = dateFormatter.string(from: date)
        
        self.timeLabel.text     = strDate
        self.messageLabel.text  = model?.comment
        self.nameLabel.isHidden = model?.name == nil
        if model?.user_id == ApplicationStates.getUserID() {
            self.nameLabel.text = "Me"
        } else {
            self.nameLabel.text = model?.name
        }
        
        self.leftImage.sd_setImage(with: URL(string: model?.photo ?? ""), placeholderImage: UIImage(named: "user_pl"))
    }
    
    func setChatDirection() {
        let side: ChatDirection = .left

        self.leadingConstraint = self.leadingConstraint.setRelation(relation: .equal, constant: leadingConstraintValue)
        self.trailingConstraint = self.trailingConstraint.setRelation(relation: .greaterThanOrEqual, constant: self.trailingConstraintValue)
        self.timeLabel.textAlignment = .left
        self.messageLabel.textColor = .white
        self.nameLabel.textColor = .white

        
    }
    
    func setIcon(side:ChatDirection) {

    }
   
}
