//
//  AppointmentBookingVC.swift
//  Divineray
//
//  Created by Aravind Kumar on 23/09/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
import DateTimePicker
@available(iOS 14.0, *)
class AppointmentBookingVC: UIViewController {
    @IBOutlet weak var confirmEmailTxt: UITextField!
    
    @IBOutlet weak var nameTxtF: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var moreInfoView: UIView!
    var timeSlotId = ""
    var dateSlot = ""
    
    var duration = 1
    var selctedDate = ""
    @IBOutlet weak var btnApp: UIButton!
    @IBOutlet weak var dateSelection: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var picker : DateTimePicker!
    @IBOutlet weak var nodatafound: UILabel!
    var userInfo : NSDictionary!
    var itemArray : NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.moreInfoView.isHidden = true
        self.nodatafound.isHidden = true
        self.btnApp.isHidden = false
        self.btnApp.setTitle(" CHOOSE APPOINTMENT DATE", for: .normal)
        self.registerNib()
        self.dateSelection.isHidden = true
        self.itemArray = NSMutableArray.init()
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.isScrollEnabled = true
        
        self.dateSelection.isHidden = true
        self.getAppointmentBooking(withDate: "")
        self.addDatePicker()
        // Do any additional setup after loading the view.
    }
    
    
    func registerNib(){
        let nibtitleHeader = UINib(nibName: "titleHeaderCollectionViewCell", bundle: nil)
        collectionView.register(nibtitleHeader, forCellWithReuseIdentifier: "titleHeaderCollectionViewCell")
        self.collectionView.register(nibtitleHeader, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "titleHeaderCollectionViewCell")
        
        let nibImgView = UINib(nibName: "AppointCollectionViewCell", bundle: nil)
        collectionView.register(nibImgView, forCellWithReuseIdentifier: "AppointCollectionViewCell")
    }
    
    func getAppointmentBooking(withDate:String) {
        SVProgressHUD.show()
        var profileUserId = ""
        if let pfUserid = self.userInfo["user_id"] as? String{
            profileUserId = pfUserid
        }
        let timeZone = TimeZone.current.identifier
        let params:[String:Any] = [
            "user_id":ApplicationStates.getUserID(),"profileUserId":profileUserId,"appointment_date":withDate,"timeZone":timeZone]
    
        self.selctedDate = withDate;
        print(params)
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAllAppointmentListing, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let result:[String:Any] = json as? Dictionary {
                    self.itemArray.removeAllObjects()
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            if let data =  result["data"] as? NSArray {
                                for ids  in data {
                                    if let idsValue = ids as? NSDictionary {
                                        if let idsValueData =  idsValue["data"] as? NSArray {
                                            if idsValueData.count > 0 {
                                                self.itemArray.add(ids)
                                            }
                                        }
                                    }
                                }
                            }
                        }else {
                        }
                    }
                    if self.itemArray.count == 0 {
                        self.nodatafound.isHidden = false
                        self.nodatafound.numberOfLines  = 5
                        let formatter = DateFormatter()
                        formatter.dateFormat = "YYYY-MM-dd"
                        if let date = formatter.date(from: self.selctedDate) {
                            formatter.dateFormat = "dd MMMM, YYYY"
                            if let str = formatter.string(from: date) as? String {
                                if withDate.isEmpty {
                                self.nodatafound.text = "No booking slots available"

                                }else {
                                self.nodatafound.text = "\(str) has no booking slots,\nPlease choose another date!"
                                }
                            }
                        }
                    }else {
                        self.nodatafound.isHidden = true
                    }
                } else {
                }
                self.collectionView.reloadData()
                break
            case .failure(let error):
                self.showAlertWith(title:API.appName, message:error)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                break;
            }
        }
    }
}
@available(iOS 14.0, *)
extension AppointmentBookingVC : DateTimePickerDelegate {
    func dateTimePicker(_ picker: DateTimePicker, didSelectDate: Date) {
    }
    
    func addDatePicker() {
        let min = Date()
        let max = Date().addingTimeInterval(60 * 60 * 24 * 4*30)
        self.picker = DateTimePicker.create(minimumDate: min, maximumDate: max)
        self.picker.dateFormat = "dd MMMM, YYYY"
        self.picker.isDatePickerOnly = true
        self.picker.frame = CGRect(x: 0, y: 0, width: picker.frame.size.width, height: 240)
        self.picker.is12HourFormat = true
        self.dateSelection.addSubview(picker)
        //        self.picker.darkColor = UIColor(red: 232.0/255.0, green: 69.0/255.0, blue: 89.0/255.0, alpha: 1.0)
        self.picker.doneBackgroundColor = UIColor(red: 232.0/255.0, green: 69.0/255.0, blue: 89.0/255.0, alpha: 1.0)
        picker.highlightColor = UIColor(red: 232.0/255.0, green: 69.0/255.0, blue: 89.0/255.0, alpha: 1.0)
        
        self.picker.delegate = self
        picker.completionHandler = { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            self.dateSelection.isHidden = true
            let dateVaue = formatter.string(from: date)
            self.getAppointmentBooking(withDate: dateVaue)
            
        }
        picker.dismissHandler = {
            self.dateSelection.isHidden = true
        }
    }
    @IBAction func bookAppointment(_ sender: Any) {
        self.dateSelection.isHidden  = false
        self.picker.show()
    }
    func openPicker() {
        self.dateSelection.isHidden  = false
        self.picker.show()
    }
    
}
@available(iOS 14.0, *)
extension AppointmentBookingVC {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.updatenavigationBar()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.updatenavigationBarBack()
        self.navigationController?.navigationBar.isHidden = true
    }
    func updatenavigationBar(){
        if let navigationBar = self.navigationController?.navigationBar {
            // remove left buttons (in case you added some)
            self.navigationItem.leftBarButtonItems = []
            // hide the default back buttons
            self.navigationItem.hidesBackButton = true
            
            if let lblInfo = navigationBar.viewWithTag(11) as? UILabel {
                lblInfo.text = "Appointment Booking"
            }
            if let btnSetting = navigationBar.viewWithTag(12) as? UIButton {
                btnSetting.isHidden = true
            }
            if let backBtn = navigationBar.viewWithTag(13) as? UIButton {
                backBtn.isHidden = false
                backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
                
            }
        }
    }
    
    func updatenavigationBarBack(){
        if let navigationBar = self.navigationController?.navigationBar {
            if let backBtn = navigationBar.viewWithTag(13) as? UIButton {
                backBtn.removeTarget(self, action: #selector(backAction), for: .touchUpInside)
            }
        }
    }
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
@available(iOS 14.0, *)
extension AppointmentBookingVC : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.itemArray.count;
    }
    func collectionView(_ collectionView: UICollectionView, layout  collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        let w = self.view.frame.size.width
        let size = CGSize(width: w, height: 46)
        return size
    }
    func collectionView(_ collectionView: UICollectionView, layout  collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize{
        let w = self.view.frame.size.width
        let size = CGSize(width: w, height: 0)
        return size
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionView.elementKindSectionFooter) {
            let titleHeader : titleHeaderCollectionViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "titleHeaderCollectionViewCell", for: indexPath) as! titleHeaderCollectionViewCell
            // Customize headerView here
            titleHeader.backgroundColor = UIColor.clear
            titleHeader.lblTitle.text = ""
            return titleHeader
        }else {
            let titleHeader : titleHeaderCollectionViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "titleHeaderCollectionViewCell", for: indexPath) as! titleHeaderCollectionViewCell
            // Customize headerView here
            titleHeader.backgroundColor = UIColor.clear
            if let dict = self.itemArray.object(at: indexPath.section) as? NSDictionary{
                if let ss = dict["title"] as? String {
                    titleHeader.lblTitle.text = "\(ss)"
                    
//                    let formatter = DateFormatter()
//                    formatter.dateFormat = "YYYY-MM-dd"
//                    if let date = formatter.date(from: self.selctedDate) {
//                        formatter.dateFormat = "dd MMMM, YYYY"
//                        if let str = formatter.string(from: date) as? String {
//                            titleHeader.lblTitle.text = ss
//                        }
//                    }
                }
            }
            titleHeader.lblTitle.text = titleHeader.lblTitle.text?.uppercased()
            return titleHeader
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if let dict = self.itemArray.object(at: section) as? NSDictionary{
            if let items = dict["data"] as? NSArray {
                return items.count
            }
        }
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : AppointCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier:"AppointCollectionViewCell", for: indexPath as IndexPath) as! AppointCollectionViewCell
        
        if  let dictMain = self.itemArray.object(at: indexPath.section) as? NSDictionary {
            if let items = dictMain["data"] as? NSArray {
                if let dict = items.object(at: indexPath.row) as? NSDictionary {
                    cell.lblStartTime.isHidden = false
                    cell.lblEndTime.isHidden = false
                    
                    cell.btnBook.addTarget(self, action: #selector(buyAction(btn:)), for: .touchUpInside)
                    cell.btnBook.tag = indexPath.row
                    
                    if let startTime = dict["startTime"] as? String {
                        cell.lblStartTime.text = startTime.uppercased()
                    }else {
                        cell.lblStartTime.isHidden = true
                        
                    }
                    if let advisory = dict["advisory"] as? String {
                        cell.lbvlType.text = advisory
                    }
                    if let endTime = dict["endTime"] as? String {
                        if endTime.isEmpty  {
                            cell.lblEndTime.isHidden = true
                        }
                        cell.lblEndTime.text = endTime.uppercased()
                    }else {
                        cell.lblEndTime.isHidden = true
                    }
                    if let timeZone = dict["timeZone"] as? String {
                        if timeZone.isEmpty  {
                            cell.lblTimeZone.isHidden = true
                        }
                        cell.lblTimeZone.text = timeZone.uppercased()
                    }else {
                        cell.lblTimeZone.isHidden = true
                    }
                    
                    if let coins = dict["appointmentRate"] as? String {
                        cell.lblCounsPoins.text = "\(coins) Coins"
                    }
                    cell.imgBg.image = UIImage(named: "imgBg")
                    if let image : String = dict["image"] as? String{
                        if image != ""{
                            let url = URL(string: image)
                            cell.imgBg.kf.setImage(with: url, placeholder:UIImage(named: "imgBg"))
                        }
                    }
                }
            }
        }
        
        cell.vsf.backgroundColor = UIColor.white
        cell.cornerRadius = 5.0
        self.buttonShowadCreate(globeButton: cell.vsf)
        return cell      //return your cell
    }
    
    func buttonShowadCreate(globeButton : UIButton) {
        
        // Shadow and Radius
        globeButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.55).cgColor
        globeButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        globeButton.layer.shadowOpacity = 1.0
        globeButton.layer.shadowRadius = 5.0
        globeButton.layer.masksToBounds = false
        globeButton.layer.cornerRadius = 5.0
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}
@available(iOS 14.0, *)
extension AppointmentBookingVC : UICollectionViewDelegate{
    
}
@available(iOS 14.0, *)
extension AppointmentBookingVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let width = self.view.frame.size.width/2-35;
        
        return CGSize(width: width, height: 165)
    }
}
@available(iOS 14.0, *)
extension AppointmentBookingVC {
    @objc func buyAction(btn:UIButton) {
        if let cell : AppointCollectionViewCell  = btn.superview?.superview?.superview as? AppointCollectionViewCell{
            if  let indexPath = self.collectionView.indexPath(for: cell) {
                if  let dictMain = self.itemArray.object(at: indexPath.section) as? NSDictionary {
                    if let items = dictMain["data"] as? NSArray {
                        if let dict = items.object(at: indexPath.row) as? NSDictionary {
                            if let ss = dictMain["bookDate"] as? String {
                                self.selctedDate = ss
                            }
                            if let timeSlotId = dict["id"] as? String  {
                                
                                self.addBooking(timeSlotId: timeSlotId, dateSlot: self.selctedDate)
                            }
                        }
                    }
                }
            }
        }
    }
    func addBooking(timeSlotId:String,dateSlot:String) {
        self.showMessage(title: API.appName, message: "You are choosing to book a session for entertainment purposes only. the creator in no way guarantees he or she can heal anyone nor do they affirm they are doctors or physicians that can provide medical or psychological advise. You take sole responsibility for your actions by agreeing to this purchase and clicking ok. You agree to exempt the creator, Divine Ray inc and any of its affiliates from legal actions from services offered through the Divine Ray Inc app. You agree by purchasing these services the seller makes no guarantees of life or health improvement and is to be accepted as entertainment only.Do you agree to proceed. Hit ok if yes", okButton: "OK", cancelButton: "Cancel", controller: self, okHandler: {
            self.timeSlotId =  timeSlotId
            self.dateSlot = dateSlot
            self.moreInfoView.isHidden = false
        }) {
            //cancell
        }
    }
    func validateEmailFields() ->String? {
        var err:String? = nil
        do {
            _ = try self.emailTxt.validatedText(validationType: ValidatorType.email)
        } catch(let error) {
            err = (error as! ValidationError).message
        }
        return err
    }
    func validateCEmailFields() ->String? {
        var err:String? = nil
        do {
            _ = try self.confirmEmailTxt.validatedText(validationType: ValidatorType.emailC)
        } catch(let error) {
            err = (error as! ValidationError).message
        }
        return err
    }
    @IBAction func subMitAction(_ sender: Any) {
        emailTxt.resignFirstResponder()
        nameTxtF.resignFirstResponder()
        confirmEmailTxt.resignFirstResponder()
        
        let email : String = emailTxt.text!
        let confirmemail : String = confirmEmailTxt.text!
        
        let name : String = nameTxtF.text!
        if name.isEmpty {
            self.showToastMessage("Please enter name")
            return
        }
        if email.isEmpty {
            self.showToastMessage("Please enter email address")
            return
        }
        if confirmemail.isEmpty {
            self.showToastMessage("Please enter confirm email address")
            return
        }
        if let errorMessage = self.validateEmailFields() {
            self.showToastMessage(errorMessage)
            return
        }
        if let errorMessage = self.validateCEmailFields() {
            self.showToastMessage(errorMessage)
            return
        }
        if email != confirmemail{
            self.showToastMessage("email address & confirm email does not matched")
            return
        }
        
        self.moreInfoView.isHidden = false
        self.addBookingService()
    }
    @IBAction func moreCancelAction(_ sender: Any) {
        self.moreInfoView.isHidden = true
        
    }
    func addBookingService() {
        SVProgressHUD.show()
        var profileUserId = ""
        if let pfUserid = self.userInfo["user_id"] as? String{
            profileUserId = pfUserid
        }
        let params:[String:Any] = [
            "user_id":ApplicationStates.getUserID(),"RequestAppointmentid":profileUserId,"appointment_date":self.dateSlot,"slot_id":self.timeSlotId,"email":self.emailTxt.text!,"name":self.nameTxtF.text!]
                
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.addRequestAppointment, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    self.moreInfoView.isHidden = true
                    self.emailTxt.text = ""
                    self.nameTxtF.text = ""
                    SVProgressHUD.dismiss()
                }
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            if let msg = result["message"] as? String {
                                self.showMessage(title: API.appName, message: msg, okButton: "OK", cancelButton: "", controller: self, okHandler: {
                                    self.backAction()
                                }) {
                                    
                                }
                            }else {
                                if let msg = result["message"] as? String {
                                    self.showMessage(title: API.appName, message: msg, okButton: "OK", cancelButton: "", controller: self, okHandler: {
                                    }) {
                                        //
                                        if status == 201 {
                                            self.redirectBuy()
                                        }
                                    }
                                }
                                
                            }
                        }else {
                            if let msg = result["message"] as? String {
                                self.showMessage(title: API.appName, message: msg, okButton: "OK", cancelButton: "", controller: self, okHandler: {
                                    if status == 201 {
                                        self.redirectBuy()
                                    }
                                }) {
                                    //
                                    
                                }
                            }
                            
                        }
                    }
                    
                }
                break
            case .failure(let error):
                self.showAlertWith(title:API.appName, message:error)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                break;
            }
        }
    }
    func redirectBuy() {
        let buyCoinsViewController : BuyCoinsViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyCoinsViewController") as! BuyCoinsViewController
        self.navigationController?.pushViewController(buyCoinsViewController, animated: true)
    }
}
