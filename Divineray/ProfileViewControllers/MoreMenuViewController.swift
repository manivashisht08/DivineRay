//
//  MoreMenuViewController.swift
//  Divineray
//
//  Created by Aravind Kumar on 22/07/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
@available(iOS 14.0, *)

class MoreMenuViewController: UIViewController {
    var userInfo : NSDictionary!
    private let kSettingsIdentifierMore = "MoreSTableViewCell"
    @IBOutlet weak var tbView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerNib()
        tbView.delegate = self
        tbView.dataSource = self
        // Do any additional setup after loading the view.
    }
    func registerNib(){
        let nibImgView = UINib(nibName: kSettingsIdentifierMore, bundle: nil)
        self.tbView.register(nibImgView, forCellReuseIdentifier: kSettingsIdentifierMore)
    }
}
@available(iOS 14.0, *)
extension MoreMenuViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hv = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1))
        
        hv.backgroundColor = UIColor(red: 191.0/255.0, green: 191.0/255.0, blue: 191.0/255.0, alpha: 1.0)
        return hv
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell : MoreSTableViewCell = tableView.dequeueReusableCell(withIdentifier: kSettingsIdentifierMore, for: indexPath) as? MoreSTableViewCell else {
            fatalError("Unable to Dequeue Reusable Table View Cell")
        }
        if indexPath.row == 0 {
            cell.nameLbl.text = "Appointment Booking"
            cell.iconImg.image = UIImage(named: "appointment")
        }else if indexPath.row == 1 {
            cell.nameLbl.text = "Physical Product Purchase"
            cell.iconImg.image = UIImage(named: "physicalP")
        }
        else if indexPath.row == 2 {
            cell.nameLbl.text = "Activation's & Meditations"
            cell.iconImg.image = UIImage(named: "video")
        }
//        else if indexPath.row == 3 {
//            cell.nameLbl.text = "Gift Item"
//            cell.iconImg.image = UIImage(named: "gift")
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let appointmentBookingVC : AppointmentBookingVC  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AppointmentBookingVC") as! AppointmentBookingVC
            appointmentBookingVC.userInfo = self.userInfo
        self.navigationController?.pushViewController(appointmentBookingVC, animated: true)
        }else if indexPath.row == 1 {
            let physicalProductVC : PhysicalProductVC  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhysicalProductVC") as! PhysicalProductVC
            physicalProductVC.userInfo = self.userInfo
        self.navigationController?.pushViewController(physicalProductVC, animated: true)
        }
        else if indexPath.row == 2 {
            let moreVideosVC : MoreVideosVC  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MoreVideosVC") as! MoreVideosVC
            moreVideosVC.userInfo = self.userInfo
        self.navigationController?.pushViewController(moreVideosVC, animated: true)
        }
        else if indexPath.row == 3 {
            let giftOptionsVC : GiftOptionsVC  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GiftOptionsVC") as! GiftOptionsVC
            giftOptionsVC.userInfo = self.userInfo
        self.navigationController?.pushViewController(giftOptionsVC, animated: true)
        }
    }
}
