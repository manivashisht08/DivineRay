//
//  LiveStreamingViewController.swift
//  Divineray
//
//  Created by Tejas Dattani on 09/01/22.
//  Copyright © 2022 Dharmani Apps. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import BottomPopup
import NextGrowingTextView
import AgoraRtcKit
import IQKeyboardManagerSwift


protocol LiveVCDataSource: NSObjectProtocol {
    func liveVCNeedAgoraKit() -> AgoraRtcEngineKit
    func liveVCNeedSettings() -> Settings
}
@available(iOS 14.0, *)

class LiveStreamingViewController: UIViewController {
    
    @IBOutlet weak var broadcastersView: AGEVideoContainer!
    @IBOutlet weak var IBImgVwProfilePic: UIImageView!
    @IBOutlet weak var IBImgVwOtherProfilePic: UIImageView!
    
    @IBOutlet weak var IBLblUserName: UILabel!
    @IBOutlet weak var IBBtnProfile: UIButton!
    
    @IBOutlet weak var IBBtnClose: UIButton!
    @IBOutlet weak var IBBtnSwitchCamera: UIButton!
    @IBOutlet weak var IBBtnBeautification: UIButton!
    @IBOutlet weak var IBBtnMuteAudio: UIButton!
    @IBOutlet weak var IBBtnLiveVideoGridLayout: UIButton!
    @IBOutlet weak var IBBtnAddComment: UIButton!
    @IBOutlet weak var IBBtnHeart: UIButton!
    @IBOutlet weak var IBBtnThreeDotBottomSheet: UIButton!
    @IBOutlet weak var inputContainerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var IBStackVwAgoraOptions: UIStackView!
    @IBOutlet weak var IBStackVTableViewAgoraOptions: UIStackView!

    @IBOutlet weak var IBTxtVwComment: GrowingTextView!
    @IBOutlet weak var tableHeightConstrinat: NSLayoutConstraint!
    @IBOutlet weak var chatTable: UITableView!
    
    @IBOutlet weak var liveUsersCountLabel: UILabel!
    @IBOutlet weak var liveTagLabel: UILabel!
    @IBOutlet weak var seeRequestButton: UIButton!
    @IBOutlet weak var joinRequestButton: UIButton!
    @IBOutlet weak var joinRequestView: UIView!
    @IBOutlet weak var userViewListView: UIView!

    var isFrontCamera = Bool()
    
    private var isVisibleKeyboard = true
    var strClientRole   = ClientRole.BROADCASTER
    let imagesArray     = [#imageLiteral(resourceName: "img_heart")]
    var fbAnimationView : HeartAnimationView!
    var viewModel       : LiveStreamVM?
    var keyboard: KeyboardVM?
    
    
    private let beautyOptions: AgoraBeautyOptions = {
        let options = AgoraBeautyOptions()
        options.lighteningContrastLevel = .normal
        options.lighteningLevel = 0.7
        options.smoothnessLevel = 0.5
        options.rednessLevel = 0.1
        return options
    }()
    var agoraKit: AgoraRtcEngineKit = {
        let engine = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: nil)
        
        return engine
    }()
    
    private let maxVideoSession = 4
    weak var dataSource: LiveVCDataSource?
    
    private var videoSessions = [VideoSession]() {
        didSet {
            self.updateBroadcastersView()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.viewModel == nil {
            self.viewModel = LiveStreamVM(observer: self)
        }
        self.viewModel?.connectToSocket()
        if strClientRole == ClientRole.AUDIENCE {
            self.viewModel?.apiViewLiveStream(is_view: "1")
        }
        
        self.IBBtnThreeDotBottomSheet.isHidden = self.strClientRole == ClientRole.AUDIENCE
        self.viewModel?.apiHostLiveDetails(joinChannel: true)
        self.viewModel?.apiAllStreamCommnetsV2()
        self.setTableView()
        self.IBImgVwProfilePic.layer.cornerRadius = self.IBImgVwProfilePic.frame.size.height / 2.0
        self.IBImgVwOtherProfilePic.layer.cornerRadius = self.IBImgVwOtherProfilePic.frame.size.height / 2.0
        
        self.IBImgVwProfilePic.clipsToBounds = true
        self.IBImgVwOtherProfilePic.clipsToBounds = true
        
        self.IBLblUserName.textColor = UIColor.white
        self.IBBtnMuteAudio.tintColor = UIColor.white
        self.IBBtnMuteAudio.setImage(UIImage(named: "btn_audio_enabled"), for: .normal)
        self.IBBtnMuteAudio.setImage(UIImage(named: "btn_audio_disabled"), for: .selected)
        self.IBBtnBeautification.tintColor = UIColor.white
        self.IBBtnBeautification.setImage(UIImage(named: "btn_beauty_disabled"), for: .normal)
        self.IBBtnBeautification.setImage(UIImage(named: "btn_beauty_enabled"), for: .selected)
        self.IBBtnLiveVideoGridLayout.tintColor = UIColor.white
        self.IBBtnLiveVideoGridLayout.setImage(UIImage(named: "btn_video_enabled"), for: .normal)
        self.IBBtnLiveVideoGridLayout.setImage(UIImage(named: "btn_video_disabled"), for: .selected)
        self.seeRequestButton.setImage(UIImage(named: "ic_new_add_user"), for: .normal)
        self.seeRequestButton.isHidden = true
        self.IBTxtVwComment.delegate   = self
        self.IBTxtVwComment.layer.cornerRadius = 4
        self.IBTxtVwComment.placeholder      = StringConstant.TYPE_SOMETHING
        self.IBTxtVwComment.placeholderColor = UIColor.white
        self.setupFBAnimationView()
        self.showorHideButtons()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillTerminate(_:)), name: UIApplication.willTerminateNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.willResignActiveNotification(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        IQKeyboardManager.shared.enable = false
        
        keyboard = KeyboardVM()
        keyboard?.setKeyboardNotification(self)
        self.navigationController?.navigationBar.isHidden = true
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        keyboard?.removeKeyboardNotification()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func appWillTerminate(_ sender: Notification) {
        print("appWillTerminate")
        self.endLiveStream()
    }
    
    @objc func willResignActiveNotification(_ sender: Notification) {
        print("willResignActiveNotification")
        self.endLiveStream()
    }
    
    @objc func setViewData(_ dict: NSDictionary) {
        self.viewModel     = LiveStreamVM(observer: self)
        
        self.viewModel?.stream_id = dict.value(forKey: "stream_id") as? String ?? ""
        self.viewModel?.stream_room = dict.value(forKey: "stream_room") as? String ?? ""
        
        let userId     = dict.value(forKey: "user_id") as? String ?? ""
        
        self.viewModel?.hostUserId = userId
        self.strClientRole = userId == ApplicationStates.getUserID() ? ClientRole.BROADCASTER : ClientRole.AUDIENCE
        
    }
    
    func setViewData(_ data: LiveStreamModel) {
        self.strClientRole   = ClientRole.BROADCASTER
        
        self.viewModel               = LiveStreamVM(observer: self)
        self.viewModel?.stream_room   = data.streamDetail?.stream_room ?? ""
        self.viewModel?.stream_id    = data.streamDetail?.stream_id ?? ""
        self.viewModel?.streamModel  = data
    }
    
    func showorHideButtons() {
        if self.strClientRole == ClientRole.BROADCASTER {
            self.IBBtnBeautification.isHidden = false
            self.IBBtnSwitchCamera.isHidden = false
            self.IBBtnMuteAudio.isHidden = false
            self.IBBtnLiveVideoGridLayout.isHidden = false
            self.IBBtnMuteAudio.isSelected = false
            self.IBBtnLiveVideoGridLayout.isSelected = false
        }
        else {
            self.IBBtnSwitchCamera.isHidden = true
            self.IBBtnBeautification.isHidden = true
            self.IBBtnMuteAudio.isHidden = true
            self.IBBtnLiveVideoGridLayout.isHidden = true
            self.IBBtnMuteAudio.isSelected = false
            self.IBBtnLiveVideoGridLayout.isSelected = false
        }
    }
    
    func setTableView() {
        self.chatTable.delegate = self
        self.chatTable.dataSource = self
        self.chatTable.separatorStyle = .none
        self.chatTable.showsVerticalScrollIndicator = false
        self.chatTable.register(UINib(nibName: "ChatCell", bundle: nibBundle), forCellReuseIdentifier: "ChatCell")
    }
    
    func setupFBAnimationView() {
        self.fbAnimationView = HeartAnimationView()
        self.fbAnimationView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(fbAnimationView)
        [self.fbAnimationView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: -150),
         self.fbAnimationView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
         self.fbAnimationView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
         self.fbAnimationView.heightAnchor.constraint(equalToConstant: self.view.frame.height)].forEach { ($0.isActive = true)  }
        
        self.view.bringSubviewToFront(self.IBBtnProfile)
        self.view.bringSubviewToFront(self.IBBtnAddComment)
        self.view.bringSubviewToFront(self.IBBtnHeart)
        self.view.bringSubviewToFront(self.IBStackVTableViewAgoraOptions)
        self.view.bringSubviewToFront(self.IBStackVwAgoraOptions)
        self.view.bringSubviewToFront(self.userViewListView)

        
    }
    
    @objc func handleTapped() {
        let randomIndex = Int(arc4random_uniform(UInt32(self.imagesArray.count)))
        let randomImage = self.imagesArray[randomIndex]
        self.fbAnimationView.animate(icon: randomImage)
    }
    
    @IBAction func sendCommnet(_ sender: UIButton) {
        if self.IBTxtVwComment.text.trimmingCharacters(in: .whitespaces).count > 0{
            self.viewModel?.sendNewMessasge(self.IBTxtVwComment.text, sender: sender)
        }
    }
    
    @IBAction func IBBtnLikeTapped(_ sender: UIButton) {
        self.viewModel?.likestreamandUnlikestream(sender: sender)
    }
    
    @IBAction func joinRequestButtonAction(_ sender: UIButton) {
        if self.strClientRole ==  ClientRole.BROADCASTER {
            self.leaveRoom()
        }
        else {
            self.viewModel?.userJoinLiveStream()
        }
    }
    
    @IBAction func viewListButtonAction(_ sender: UIButton) {
        self.opneSheet()
    }
}

//------------------------------------------------------------------
// MARK: Custom methods
//------------------------------------------------------------------
@available(iOS 14.0, *)

extension LiveStreamingViewController {
    
    @IBAction func IBBtnCloseTapped(_ sender: UIButton) {
        if self.viewModel?.streamModel?.userDetail != nil{
            if self.viewModel?.streamModel?.userDetail?.user_id == ApplicationStates.getUserID(){
                var params: Parameters = Parameters()
                params["user_id"]      = ApplicationStates.getUserID()
                params["sid"]          = self.viewModel?.stream_id ?? ""
                params["cname"]        = self.viewModel?.streamModel?.streamDetail?.channel_name
                params["resourceid"]   = self.viewModel?.resourceId ?? ""
                self.viewModel?.showMessageToExitStream(_vc: self, params: params)
            } else {
                var params: Parameters = Parameters()
                params["user_id"]      = ApplicationStates.getUserID()
                params["stream_id"]    = self.viewModel?.streamModel?.streamDetail?.stream_id ?? ""
                self.viewModel?.showMessageToLeaveStream(_vc: self, params: params)
            }
        }
    }
    
    @IBAction func IBBtnSwitchCamera(_ sender: UIButton) {
        agoraKit.switchCamera()
    }
    
    @IBAction func IBBtnUserProfileTapped(_ sender: UIButton) {
        self.opneSheet()
    }
    
    @IBAction func IBBtnThreeDotBottomSheetTapped(_ sender: Any) {
        let controller : LikeCommentBottomPopupVC  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LikeCommentBottomPopupVC") as! LikeCommentBottomPopupVC
        let stream_details = self.viewModel?.streamModel?.streamDetail
        print("disable commenting \(stream_details?.disable_like == "0") ** \(stream_details?.disable_comment == "0")")
        controller.isLikingOn = (stream_details?.disable_like == "0")
        controller.isCommentingOn = (stream_details?.disable_comment == "0")
        controller.delegate = self
        controller.height = 190
        controller.topCornerRadius = 0
        controller.presentDuration = 0.44
        controller.dismissDuration = 0.44
        controller.shouldDismissInteractivelty = true
        controller.popupDelegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func IBBtnMuteAudioTapped(sender: UIButton) {
        sender.isSelected.toggle()
        agoraKit.muteLocalAudioStream(sender.isSelected)
    }
    
    @IBAction func IBBtnBeautificationTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.setBeautyEffectOptions(sender.isSelected, options: sender.isSelected ? self.beautyOptions : nil)
    }
    
    @IBAction func IBBtnLiveVideoGridLayoutTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true{
            self.agoraKit.disableVideo()
        }
        else{
            self.agoraKit.enableVideo()
        }
        self.agoraKit.muteLocalVideoStream(sender.isSelected)
    }
    
    func opneSheet(){
        if self.seeRequestButton.isHidden == false {
            self.seeRequestButton.isHidden.toggle()
        }
        let controller = Storyboard.getViewController(StreamingRoomBottomPopupVC.self, storyboard: .main)
        controller.viewModel = self.viewModel
        controller.strClientRole = self.strClientRole
        controller.delegate = self
        controller.height = 600
        controller.topCornerRadius = 0
        controller.presentDuration = 0.44
        controller.dismissDuration = 0.44
        controller.shouldDismissInteractivelty = true
        self.present(controller, animated: true, completion: nil)
    }
    
}
@available(iOS 14.0, *)

extension LiveStreamingViewController: likeCommentBottomPopupVCDelegate {
    
    func getLikeAndCommentStatus(isLikingOn: Bool, isCommentingOn: Bool) {
        self.viewModel?.disableLikeComment(isLike: isLikingOn)
    }
    
    func endLiveStream(){
        if self.viewModel?.streamModel?.userDetail != nil{
            if self.viewModel?.streamModel?.userDetail?.user_id == ApplicationStates.getUserID(){
                var params: Parameters = Parameters()
                params["user_id"]      = ApplicationStates.getUserID()
                params["sid"]          = self.viewModel?.stream_id ?? ""
                params["cname"]        = self.viewModel?.streamModel?.streamDetail?.channel_name
                params["resourceid"]   = self.viewModel?.resourceId ?? ""
                self.viewModel?.endStreamingV2(params: params)
            }
            else{
                var params: Parameters = Parameters()
                params["user_id"]      = ApplicationStates.getUserID()
                params["stream_id"]    = self.viewModel?.streamModel?.streamDetail?.stream_id ?? ""
                self.viewModel?.leavestreamv2(params: params)
            }
        }
    }
}

//------------------------------------------------------------------
// MARK: streamingRoomBottomPopupVC Delegate Methods
//------------------------------------------------------------------
@available(iOS 14.0, *)

extension LiveStreamingViewController: streamingRoomBottomPopupVCDelegate {
    func leaveRoom() {
        if self.viewModel?.streamModel?.userDetail != nil{
            if self.viewModel?.streamModel?.userDetail?.user_id == ApplicationStates.getUserID(){
                var params: Parameters = Parameters()
                params["user_id"]      = ApplicationStates.getUserID()
                params["sid"]          = self.viewModel?.stream_id ?? ""
                params["cname"]        = self.viewModel?.streamModel?.streamDetail?.channel_name
                params["resourceid"]   = self.viewModel?.resourceId ?? ""
                self.viewModel?.showMessageToExitStream(_vc: self, params: params)
            } else {
                var params: Parameters = Parameters()
                params["user_id"]      = ApplicationStates.getUserID()
                params["stream_id"]    = self.viewModel?.streamModel?.streamDetail?.stream_id ?? ""
                self.viewModel?.showMessageToLeaveStream(_vc: self, params: params)
            }
        }
    }
    
    
    func leaveTheCurrrentRoom(strRoomID: String) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func removeUserFromTheCurrrentRoom() {
        
    }
    
}
@available(iOS 14.0, *)

extension LiveStreamingViewController: BottomPopupDelegate {
    
    func bottomPopupViewLoaded() {
        print("bottomPopupViewLoaded")
    }
    
    func bottomPopupWillAppear() {
        print("bottomPopupWillAppear")
    }
    
    func bottomPopupDidAppear() {
        print("bottomPopupDidAppear")
    }
    
    func bottomPopupWillDismiss() {
        print("bottomPopupWillDismiss")
    }
    
    func bottomPopupDidDismiss() {
        print("bottomPopupDidDismiss")
    }
    
    func bottomPopupDismissInteractionPercentChanged(from oldValue: CGFloat, to newValue: CGFloat) {
        print("bottomPopupDismissInteractionPercentChanged fromValue: \(oldValue) to: \(newValue)")
    }
}

@available(iOS 14.0, *)

private extension LiveStreamingViewController {
    func updateBroadcastersView() {
        
        
        var rank: CGFloat
        var row: CGFloat
        if self.videoSessions.count == 0 {
            self.broadcastersView.removeLayout(level: 0)
            return
        }
        else if self.videoSessions.count == 1 {
            rank = 1
            row = 1
        }
        else if self.videoSessions.count == 2 {
            rank = 1
            row = 2
        }
        else if self.videoSessions.count == 3 {
            rank = 1
            row = 3
        }
        else {
            rank = 2
            row = 2
        }
        
        let itemWidth  = CGFloat(1.0) / rank
        let itemHeight = CGFloat(1.0) /  row
        let itemSize   = CGSize(width: itemWidth, height: itemHeight)
        
        print("layout frame is 0 **** \(itemSize)  ****  \(self.videoSessions.count)")
        
        let layout  = AGEVideoLayout(level: 0).itemSize(.scale(itemSize))
        
        self.broadcastersView
            .listCount { [unowned self] (_) -> Int in
                return self.videoSessions.count
            }
            .listItem { [unowned self] (index) -> UIView in
                return self.videoSessions[index.item].hostingView
            }
        
        self.broadcastersView.setLayouts([layout], animated: true)
    }
    
    func setIdleTimerActive(_ active: Bool) {
        UIApplication.shared.isIdleTimerDisabled = !active
    }
    
}
@available(iOS 14.0, *)

private extension LiveStreamingViewController {
    func getSession(of uid: UInt) -> VideoSession? {
        for session in videoSessions {
            if session.uid == uid {
                return session
            }
        }
        return nil
    }
    
    func videoSession(of uid: UInt) -> VideoSession {
        if let fetchedSession = getSession(of: uid) {
            return fetchedSession
        } else {
            let newSession = VideoSession(uid: uid)
            newSession.hostingView.backgroundColor = .clear
            videoSessions.append(newSession)
            return newSession
        }
    }
}

@available(iOS 14.0, *)

//MARK: - Agora Media SDK
private extension LiveStreamingViewController {
    
    func loadAgoraKit() {
        self.joinRequestView.isHidden = self.viewModel?.streamModel?.userDetail?.user_id == ApplicationStates.getUserID()
        self.agoraKit.setChannelProfile(.liveBroadcasting)
        self.setIdleTimerActive(false)
        
        self.agoraKit.delegate = self
        
        let uid = UInt(ApplicationStates.getUserID()) ?? 0
        print("uid is ******* \(uid)")
        
        
        
        let result =  self.agoraKit.joinChannel(byToken: self.viewModel?.streamModel?.streamDetail?.stream_token ?? "", channelId: self.viewModel?.streamModel?.streamDetail?.channel_name ?? "", info: nil, uid: uid) { str, int, vl in
            print("items are \(str) * \(int) * \(vl)")
        }
        
        
        if self.strClientRole == ClientRole.BROADCASTER {
            self.agoraKit.setEnableSpeakerphone(true)
            self.setUserRole(.broadcaster)
            self.agoraKit.startPreview()
        }
        else{
            self.joinRequestButton.setTitle("REQUEST TO JOIN", for: .normal)
            self.setUserRole(.audience)
        }
        self.agoraKit.enableVideo()
        print(result,"result")
    }
    
    func setUserRole(_ role: AgoraClientRole) {
        self.agoraKit.setClientRole(role)
        if role == .broadcaster {
            self.addLocalSession()
        }
    }
    
    func addLocalSession() {
        let localSession = VideoSession.localSession()
        localSession.canvas.renderMode = .hidden
        localSession.canvas.mirrorMode = .auto
        localSession.canvas.setupMode = .add
        self.videoSessions.append(localSession)
        self.agoraKit.setupLocalVideo(localSession.canvas)
    }
    
    func leaveChannel() {
        self.agoraKit.disableVideo()
        self.agoraKit.setupLocalVideo(nil)
        
        self.agoraKit.leaveChannel(nil)
        self.setIdleTimerActive(true)
        if self.strClientRole == ClientRole.BROADCASTER{
            self.agoraKit.stopPreview()
            let appdelegate = UIApplication.shared.delegate as? AppDelegate
            appdelegate?.loginSucess()
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
    }
}
@available(iOS 14.0, *)

// MARK: - AgoraRtcEngineDelegate
extension LiveStreamingViewController: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        print(ApplicationStates.getUserID())
        let userSession = self.videoSession(of: uid)
        self.agoraKit.setupRemoteVideo(userSession.canvas)
    }
    
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        print("AgoraRtcEngineKit ** sesstion id 5 ** \(uid)")
        if let index = videoSessions.firstIndex(where: {$0.uid == uid}){
            let deletedSession = videoSessions.remove(at: index)
            deletedSession.hostingView.removeFromSuperview()
            deletedSession.canvas.view = nil
        }
    }
}
@available(iOS 14.0, *)

extension LiveStreamingViewController: LiveStreamVMObsever {
    func hostKickUserFromLiveStream() {
        self.joinRequestButton.setTitle("REQUEST TO JOIN", for: .normal)
        self.agoraKit.leaveChannel()
        self.strClientRole = ClientRole.AUDIENCE
        self.showorHideButtons()
        self.videoSessions.removeAll()
        self.loadAgoraKit()
    }
    
    func observeApiHostLiveDetails(joinChannel: Bool) {
        let hostName = self.viewModel?.streamModel?.userDetail?.name?.capitalized ?? ""
        if let profilePic = self.viewModel?.streamModel?.userDetail?.photo?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let url = URL(string: profilePic)
            self.IBImgVwProfilePic.kf.setImage(with: url, placeholder: UIImage(named: "user"))
        }
        else {
            self.IBImgVwProfilePic.image = UIImage(named: "user")
        }
        
        
        self.liveUsersCountLabel.text  = self.viewModel?.streamModel?.viewcount ?? "0"
        let coHostUser = self.viewModel?.streamModel?.joinuser?.filter({$0.status == "1"}) ?? []
        if coHostUser.count != 0{
            if let profilePic = coHostUser.first?.photo?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                let url = URL(string: profilePic)
                self.IBImgVwOtherProfilePic.kf.setImage(with: url, placeholder: UIImage(named: "user"))
            }
            else{
                self.IBImgVwOtherProfilePic.image = UIImage(named: "user")
            }
            if coHostUser.count == 1{
                self.IBLblUserName.text = hostName + " and " + "\(coHostUser.first?.name?.capitalized ?? "")"
            }
            else{
                self.IBLblUserName.text = hostName + " and " + "\(coHostUser.count) others"
            }
        }
        else{
            self.IBLblUserName.text = hostName
            self.IBImgVwOtherProfilePic.image = UIImage(named: "")
        }
        if self.viewModel?.streamModel?.userDetail?.user_id == ApplicationStates.getUserID(){
            self.IBTxtVwComment.isUserInteractionEnabled = true
            self.IBBtnHeart.isHidden = false
            self.IBBtnAddComment.isHidden = false
            self.IBTxtVwComment.placeholder = StringConstant.TYPE_SOMETHING
        }
        else{
            self.IBBtnAddComment.isHidden = self.viewModel?.streamModel?.streamDetail?.disable_comment != "0"
            self.IBBtnHeart.isHidden = self.viewModel?.streamModel?.streamDetail?.disable_like != "0"
            self.IBTxtVwComment.isUserInteractionEnabled = self.viewModel?.streamModel?.streamDetail?.disable_comment == "0"
            self.IBTxtVwComment.placeholder = self.viewModel?.streamModel?.streamDetail?.disable_comment != "0" ? "Can't send comment" : StringConstant.TYPE_SOMETHING
        }
        
        if joinChannel == true{
            self.loadAgoraKit()
        }
    }
    
    func showAlertMessageWith(title: String, message: String) {
        self.showAlertWith(title: title, message: message)
    }
    
    func observeApiGoingliveV3() {
    }
    
    func observeApiEndStreamingV2() {
        self.leaveChannel()
    }
    
    func observeApiLeavestreamv2Response() {
        self.leaveChannel()
    }
    
    func observeApiUserJoinStreamv2() {
        print("user joined live stream")
        self.viewModel?.apiAllStreamCommnetsV2()
    }
    
    func observeNewMessageSendSussfully() {
        print("observe New Message Send Sussfully")
        self.IBTxtVwComment.text = nil
        self.IBBtnAddComment.isEnabled = false
    }
    
    func observeNewMessageRecieved(indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.chatTable.reloadData()
        } else {
            self.chatTable.beginUpdates()
            self.chatTable.insertRows(at: [indexPath], with: .bottom)
            self.chatTable.endUpdates()
        }
        self.chatTable.isScrollEnabled = true
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            let height = self.chatTable.contentSize.height
            self.tableHeightConstrinat.constant = height > 250.0 ? 250.0 : height
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.chatTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    func observeLikestreamAndUnlikestream() {
        print("observeLikestreamAndUnlikestream")
        let randomIndex = Int(arc4random_uniform(UInt32(imagesArray.count)))
        let randomImage = imagesArray[randomIndex]
        self.fbAnimationView.animate(icon: randomImage)
    }
    
    func observeDisableCommentForViewers(isLike:Bool, isEnabled:Bool) {
        DispatchQueue.main.async {
            if isLike == false {
                self.IBTxtVwComment.resignFirstResponder()
                self.IBTxtVwComment.text = ""
                self.IBTxtVwComment.isUserInteractionEnabled = isEnabled
                self.IBBtnAddComment.isHidden = isEnabled
                self.IBTxtVwComment.placeholder = isEnabled == true ? "Can't send comment" : StringConstant.TYPE_SOMETHING
            }
            else {
                self.IBBtnHeart.isHidden = isEnabled
            }
        }
    }
    
    func observeLiveUsersCount(count: String) {
        self.liveUsersCountLabel.text = count
    }
    
    func observeAllLiveUserByStreamID() {
        
    }
    
    func joinStreamRequestsReceived() {
        if self.viewModel?.streamModel?.userDetail != nil{
            if self.viewModel?.streamModel?.userDetail?.user_id == ApplicationStates.getUserID(){
                self.seeRequestButton.isHidden = false
            }
            else{
                self.seeRequestButton.isHidden = true
            }
        }
        else{
            self.seeRequestButton.isHidden = true
        }
    }
    
    func acceptingRequestToJoinStreamForHost() {
        self.setUserRole(.broadcaster)
        self.strClientRole = ClientRole.BROADCASTER
        self.showorHideButtons()
        self.joinRequestButton.removeActivityIndigator()
        self.joinRequestButton.setTitle("LEAVE THE ROOM", for: .normal)
    }
    
}

@available(iOS 14.0, *)

extension LiveStreamingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.chatHistory.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        let chatModel = self.viewModel?.chatHistory[indexPath.row]
        if indexPath.row == 0 {
            cell.configure(model: chatModel, indexPath: indexPath, chatType: nil)
        } else {
            cell.configure(model: chatModel, indexPath: indexPath, previousDate: chatModel?.comment_time, chatType: nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func checkHeaderAnimation(row: Int) {
        
    }
    
    func apiOldChat(messageId:String) {
        
    }
    
    func setChatHistory(data: [MessageData]) {
        
    }
    
}
@available(iOS 14.0, *)

extension LiveStreamingViewController: GrowingTextViewDelegate {

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let text = textView.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: text)
            
            IBBtnAddComment.isEnabled = updatedText.count > 0
            print("update text is \(updatedText) *** \(IBBtnAddComment.isEnabled) ")
        }
        return true
    }
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        self.view.setNeedsLayout()
    }
}
@available(iOS 14.0, *)

extension LiveStreamingViewController: KeyboardVMObserver {
    
    func keyboard(didChange height: CGFloat, duration: Double, animation: UIView.AnimationOptions) {
        if self.IBTxtVwComment.isFirstResponder {
            if inputContainerViewBottom.constant == height {
                return
            }
        } else {
            if inputContainerViewBottom.constant == 0 {
                return
            }
        }
        print("height is \(height)")
        self.inputContainerViewBottom.constant = height
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: duration, delay: 0.0, options: animation, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: { finished in
        })
    }
}
