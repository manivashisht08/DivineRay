//
//  LikeCommentBottomPopupVC.swift
//  Divineray
//
//  Created by Tejas Dattani on 09/01/22.
//  Copyright © 2022 Dharmani Apps. All rights reserved.
//

import UIKit
import Alamofire
import BottomPopup

protocol streamingRoomBottomPopupVCDelegate {
    func leaveTheCurrrentRoom(strRoomID: String)
    func removeUserFromTheCurrrentRoom()
    func leaveRoom()
}

@available(iOS 14.0, *)
class StreamingRoomBottomPopupVC: PresentableController {
    
    @IBOutlet weak var IBTblRoomJoinedUserList: UITableView!
    @IBOutlet weak var IBTblHeight: NSLayoutConstraint!
    @IBOutlet weak var viewersTable: UITableView!
    @IBOutlet weak var viewersTableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var IBLblRoomTitle: UILabel!
    @IBOutlet weak var IBImgVwlLeaveRoom: UIImageView!
    @IBOutlet weak var IBLblLeaveRoomTitle: UILabel!
    @IBOutlet weak var IBBtnLeaveRoom: UIButton!
    
    
    //    @IBOutlet weak var IBLblNoPersonInRoom: UILabel!
    
    var strClientRole:Int = ClientRole.AUDIENCE
    var delegate       : streamingRoomBottomPopupVCDelegate?
    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    var viewModel      : LiveStreamVM?
    
    //------------------------------------------------------------------
    // MARK:- View life cycle methods
    //------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel?.bottomSheetObserver = self
        print("viewers count *** \(self.viewModel?.liveUsers.count) ***** joinedUsers ** \(self.viewModel?.streamModel?.joinuser?.count)")
        self.IBLblRoomTitle.textColor = UIColor.black
        self.IBLblLeaveRoomTitle.textColor = UIColor.black
        self.IBLblRoomTitle.text = StringConstant.IN_THIS_ROOM
        
        self.IBImgVwlLeaveRoom.layer.cornerRadius = self.IBImgVwlLeaveRoom.frame.size.height / 2
        self.IBImgVwlLeaveRoom.clipsToBounds = true
        self.IBImgVwlLeaveRoom.image = UIImage(named: "img_liveusers")
        
        self.setTableView(IBTblRoomJoinedUserList)
        self.setTableView(viewersTable)
        self.setViewForHostAndUser()
        self.setLayout()
    }
    
    func setViewForHostAndUser() {
        if self.strClientRole == ClientRole.BROADCASTER {
            self.IBLblLeaveRoomTitle.text =  StringConstant.LEAVE_THE_ROOM
        } else {
            self.IBLblLeaveRoomTitle.text =  StringConstant.REQUEST_TO_JOIN
        }
    }
    
    
    @objc func getPopupTopCornerRadius() -> CGFloat {
        return topCornerRadius ?? CGFloat(10)
    }
    
    //------------------------------------------------------------------
    
    @objc func getPopupPresentDuration() -> Double {
        return presentDuration ?? 1.0
    }
    
    //------------------------------------------------------------------
    
    @objc func getPopupDismissDuration() -> Double {
        return dismissDuration ?? 1.0
    }
    
    //------------------------------------------------------------------
    
    @objc func shouldPopupDismissInteractivelty() -> Bool {
        return shouldDismissInteractivelty ?? true
    }
    
    //------------------------------------------------------------------
}

//------------------------------------------------------------------
// MARK: Action Methods
//------------------------------------------------------------------

@available(iOS 14.0, *)
extension StreamingRoomBottomPopupVC {
    
    //------------------------------------------------------------------
    
    func setNoDataFoundView(dataCount: Int) {
        if dataCount == 0 {
            self.IBTblRoomJoinedUserList.backgroundView = NoDataLabel(bounds: self.IBTblRoomJoinedUserList.bounds, title: StringConstant.NO_ONE_JOINED_THE_ROOM)
        } else {
            self.IBTblRoomJoinedUserList.backgroundView?.isHidden = true
        }
    }
    
    //------------------------------------------------------------------
    
    @IBAction func IBBtnDismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //-----------------------------------------------------------------
    
    @IBAction func IBBtnLeaveRoomTapped(_ sender: UIButton) {
        if self.IBLblLeaveRoomTitle.text ==  StringConstant.LEAVE_THE_ROOM {
            self.dismiss(animated: true) {
                self.delegate?.leaveRoom()
            }
        }
        else {
            self.viewModel?.userJoinLiveStream()
            self.dismissView()
        }
    }
    
    //------------------------------------------------------------------
    
}

//------------------------------------------------------------------
// MARK: Custom Methods
//------------------------------------------------------------------
@available(iOS 14.0, *)

extension StreamingRoomBottomPopupVC {
    
    //------------------------------------------------------------------
    
    @objc func dismissView() {
        self.dismiss(animated: false, completion: nil)
    }
    
    //------------------------------------------------------------------
    
}

//------------------------------------------------------------------
// MARK: SetLayout Methods
//------------------------------------------------------------------
@available(iOS 14.0, *)

extension StreamingRoomBottomPopupVC {
    
    //------------------------------------------------------------------
    
    func setLayout()  {
        self.title = ""
        IBTblRoomJoinedUserList.backgroundColor = UIColor.clear
        IBTblRoomJoinedUserList.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.setNoDataFoundView(dataCount: 0)
        
        self.IBImgVwlLeaveRoom.layer.cornerRadius = self.IBImgVwlLeaveRoom.frame.size.height / 2.0
        self.IBImgVwlLeaveRoom.layer.masksToBounds = true
    }
    
    //------------------------------------------------------------------
    
    @objc func IBBtnDismissVCTapped() {
        self.navigationController?.popViewController(animated: false)
    }
    //------------------------------------------------------------------
    
    func setTableView(_ tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "StreamUsersTableCell", bundle: nil), forCellReuseIdentifier: "StreamUsersTableCell")
    }
    
    func setBackgourndMessage(_ tblView: UITableView, message: String) {
        let label = UILabel(frame: tblView.bounds)
        label.text = message
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        tblView.backgroundView = label
    }
    
}
@available(iOS 14.0, *)

extension StreamingRoomBottomPopupVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewersTable == tableView {
            let count = self.viewModel?.liveUsers.count ?? 0
            self.viewersTable.backgroundView = nil
            if count == 0 {
                self.viewersTableHeight.constant = 100
                self.setBackgourndMessage(viewersTable, message: "No users found!")
            } else
            if count > 3 {
                self.viewersTableHeight.constant = 220
            } else {
                self.viewersTableHeight.constant = CGFloat(count * 72)
            }
            return count
        }
        else {
            if self.viewModel?.streamModel?.userDetail?.user_id == ApplicationStates.getUserID(){
                let count = self.viewModel?.streamModel?.joinuser?.count ?? 0
                self.IBTblRoomJoinedUserList.backgroundView = nil
                if count == 0 {
                    self.IBTblHeight.constant = 100
                    self.setBackgourndMessage(IBTblRoomJoinedUserList, message: "No joined users found!")
                } else
                if count > 3 {
                    self.IBTblHeight.constant = 220
                } else {
                    self.IBTblHeight.constant = CGFloat(count * 72)
                }
                return count
                
            }
            else{
                let count = self.viewModel?.streamModel?.joinuser?.filter({$0.status == "1"}).count ?? 0
                self.IBTblRoomJoinedUserList.backgroundView = nil
                if count == 0 {
                    self.IBTblHeight.constant = 100
                    self.setBackgourndMessage(IBTblRoomJoinedUserList, message: "No joined users found!")
                } else
                if count > 3 {
                    self.IBTblHeight.constant = 220
                } else {
                    self.IBTblHeight.constant = CGFloat(count * 72)
                }
                return count
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StreamUsersTableCell", for: indexPath) as! StreamUsersTableCell
        if viewersTable == tableView {
            cell.setCellData(user: self.viewModel?.liveUsers[indexPath.row], isRequest: false, self, hostID: self.viewModel?.streamModel?.userDetail?.user_id ?? "0")
        } else {
            cell.setCellData(user: self.viewModel?.streamModel?.joinuser?[indexPath.row], isRequest: true, self, hostID: self.viewModel?.streamModel?.userDetail?.user_id ?? "0")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
}
@available(iOS 14.0, *)

extension StreamingRoomBottomPopupVC: StreamUsersTableCellDelegate {
    func hostKickUser(user: UserDetail?) {
        self.viewModel?.kickUserApi(user: user, tableView: self.IBTblRoomJoinedUserList)
    }
    
    func hostAcceptRejectRequest(isAccept: Bool, user: UserDetail?) {
        self.viewModel?.approveRejectStream(isApproved: isAccept, user: user, tableView: self.IBTblRoomJoinedUserList)
    }
}
@available(iOS 14.0, *)

extension StreamingRoomBottomPopupVC: LiveStreamVMObsever {
    
    func observeAllLiveUserByStreamID() {
        DispatchQueue.main.async {
            if self.IBTblRoomJoinedUserList != nil {
                self.IBTblRoomJoinedUserList.reloadData()
            }
            if self.viewersTable != nil {
                self.viewersTable.reloadData()
            }
        }
    }
    
}
