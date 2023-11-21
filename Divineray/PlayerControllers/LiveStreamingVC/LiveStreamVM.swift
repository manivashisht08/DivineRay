//
//  LiveStreamVM.swift
//  Divineray
//
//  Created by mac on 22/03/22.
//  Copyright © 2022 Dharmani Apps. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox
@available(iOS 14.0, *)
class Storyboard: NSObject {
    enum Name: String {
        case main = "Main"
        case chat = "Chat"
    }
    
    class func getViewController<T>(_ type: T.Type, storyboard name: Name) -> T where T : UIViewController {
        let storyboard = UIStoryboard(name: name.rawValue, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: String(describing: T.self)) as! T
        return controller
    }
    
}

@objc protocol LiveStreamVMObsever: NSObjectProtocol {
    @objc optional func showAlertMessageWith(title: String, message: String)
    @objc optional func observeApiGoingliveV3()
    @objc optional func observeApiEndStreamingV2()
    @objc optional func observeApiHostLiveDetails(joinChannel:Bool)
    
    @objc optional func observeApiLeavestreamv2Response()
    @objc optional func observeApiUserJoinStreamv2()
    @objc optional func observeNewMessageSendSussfully()
    @objc optional func observeNewMessageRecieved(indexPath: IndexPath)
    @objc optional func observeLikestreamAndUnlikestream()
    @objc optional func observeDisableCommentForViewers(isLike:Bool, isEnabled:Bool)
    
    @objc optional func observeLiveUsersCount(count: String)
    @objc optional func observeAllLiveUserByStreamID()
    @objc optional func joinStreamRequestsReceived()
    @objc optional func acceptingRequestToJoinStreamForHost()
    @objc optional func hostKickUserFromLiveStream()
    
}

@available(iOS 14.0, *)
class LiveStreamVM: NSObject {
    
    weak var observer: LiveStreamVMObsever?
    weak var bottomSheetObserver: LiveStreamVMObsever?
    var chatHistory = [MessageData]()
    var streamSocket: StreamSocket?
    var streamModel : LiveStreamModel?
    var stream_id   : String?
    var stream_room : String?
    var resourceId  : String?
    var sid         : String?
    var liveUsers   : [UserDetail] = []
    var hostUserId  : String?
    
    
    init(observer: LiveStreamVMObsever? = nil) {
        super.init()
        self.observer = observer
    }
    
    //MARK: :- GOING LIVE V3
    func apiGoingliveV3(params: Parameters) {
        print("API called \(API.goingliveV3)\n\(params)")
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.goingliveV3, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                if let result:[String:Any] = json as? Dictionary {
                    print("response is \(result)")
                    if let status = result["status"] as? Int {
                        if status == 3 {
                        } else if status == 1 {
                            if let data =  result["data"] as? [String:Any] {
                                print("data", data)
                                if let sid =  data["sid"] as? String {
                                    self.sid = sid
                                    print("sid", sid)
                                }
                                if let resourceId   = data["resourceId"] as? String {
                                    self.resourceId = resourceId
                                    print("resourceId", resourceId)
                                }
                            }
                        } else {
                            print("else")
                        }
                    }
                } else {
                }
                self.observer?.observeApiGoingliveV3?()
                break
            case .failure(let error):
                self.observer?.showAlertMessageWith?(title: API.appName, message: error)
                break
            }
        }
    }
    
    //MARK: :- HOST LIVE DETAILS
    func apiHostLiveDetails(joinChannel:Bool) {
        var params: Parameters = ["stream_id": self.stream_id ?? ""]
        if let hostUserId = hostUserId, hostUserId.count > 0 {
            params["user_id"] = hostUserId
        } else {
            params["user_id"] = ApplicationStates.getUserID()
        }
        
        print("API called \(API.hostlivedetails)\n\(params)")
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.hostlivedetails, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                print("\n\n\napi name : \(API.hostlivedetails) \nres: \(json)\n\n")
                if let response = DataDecoder.decodeData(json, type: HostDetailsModel.self) {
                    if self.streamModel == nil {
                        self.streamModel = LiveStreamModel()
                    }
                    self.streamModel?.message      = response.message
                    self.streamModel?.status       = response.status
                    self.streamModel?.userDetail   = response.userDetail
                    self.streamModel?.streamDetail = response.streamDetail?.first
                    self.streamModel?.likecount    = response.likecount
                    self.streamModel?.viewcount    = response.viewcount
                    self.streamModel?.joinuser     = response.joinuserdetails
                    self.getAllLiveUserByStreamID()
                }
                self.observer?.observeApiHostLiveDetails?(joinChannel: joinChannel)
                self.bottomSheetObserver?.observeApiHostLiveDetails?(joinChannel: joinChannel)
                break
            case .failure(let error):
                self.observer?.showAlertMessageWith?(title: API.appName, message: error)
            }
        }
    }
    
    
    //MARK: :- GET ALL STREAM COMMENTS
    func apiAllStreamCommnetsV2() {
        let params:Parameters = ["stream_id": self.stream_id ?? "",
                                 "user_id": ApplicationStates.getUserID()]
        print("\n\n\nAPI called \(API.getAllstreamcommentsv2)\n\(params)\n\n")
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAllstreamcommentsv2, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                print("\n\n\napi name : \(API.getAllstreamcommentsv2) \nres: \(json)\n\n")
                if let messgaes = DataDecoder.decodeData(json, type: ListMessageModel.self)?.data {
                    print("new message send successfully")
                    self.chatHistory = messgaes
                    self.observer?.observeNewMessageRecieved?(indexPath: IndexPath(row: 0, section: 0))
                }
                break
                
            case .failure(let error):
                self.observer?.showAlertMessageWith?(title: API.appName, message: error)
                
            }
        }
    }
    
    //MARK: - GET ALL STREAM COMMENTS
    func apiViewLiveStream(is_view: String) {
        let params:Parameters = ["stream_id"  : self.stream_id ?? "",
                                 "user_id"    : ApplicationStates.getUserID(),
                                 "stream_room": self.stream_room ?? "",
                                 "is_view"    : is_view]
        print("\n\n\nAPI called \(API.viewLiveStream)\n\(params)\n\n")
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.viewLiveStream, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                
                let totalView = (json as? [String:Any])?.string(_for: "totalView") ?? "0"
                print("\n\n\napi name : \(API.viewLiveStream) \nres: \(json)\n\n")
                
                let userData = ApplicationStates.getUserData()
                var joinJson: Parameters = [
                    "photo"  : userData?.string(_for: "photo") ?? "",
                    "name"   : userData?.string(_for: "name") ?? ""
                ]
                
                self.streamSocket?.checkConnectionStatus {
                    DispatchQueue.main.async {
                        if is_view == "1"{
                            joinJson["message"] = "joined"
                        }
                        else{
                            joinJson["message"] = "left"
                        }
                        self.streamSocket?.emitNewType(json: joinJson, roomId: self.stream_room ?? "", messageType: is_view == "1" ? .userJoinedWithName : .userLeaveLiveStram)
                        
                        self.streamSocket?.emitNewType(json:  ["count": totalView], roomId: self.stream_room ?? "", messageType: .leftJoinedUsersCountUpdation)
                        
                    }
                }
                
                break
            case .failure(let error):
                self.observer?.showAlertMessageWith?(title: API.appName, message: error)
            }
        }
    }
    
    //MARK: - END STREAMING V2
    func endStreamingV2(params: Parameters) {
        print("API called \(API.endstreamV2)\n\(params)")
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.endstreamV2, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                if let result:[String:Any] = json as? Dictionary {
                    print("endstreamV2 response \(result)")
                }
                var params: [String:Any] = [:]
                params["user_id"]     = ApplicationStates.getUserID()
                params["stream_id"]   = self.stream_id
                params["stream_room"] = self.stream_room
                
                self.streamSocket?.emitNewType(json: params, roomId: self.stream_room ?? "", messageType: .streamEndedByHost)
                self.observer?.observeApiEndStreamingV2?()
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshLiveUsersListing"), object: nil)
                break
            case .failure(let error):
                self.observer?.showAlertMessageWith?(title: API.endstreamV2, message: error)
            }
        }
    }
    
    //MARK: - USER JOIN LIVE STREAM
    func userJoinLiveStream() {
        let params: Parameters = [
            "stream_id": self.stream_id ?? "",
            "user_id": ApplicationStates.getUserID()
        ]
        print("API called \(API.userstreamjoinrequestv2) \n\(params)")
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.userstreamjoinrequestv2, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                if let result: [String:Any] = json as? Dictionary {
                    print("response userstreamjoinrequestv2 is :  \(result)")
                    if let status = result["status"] as? Int,
                       let error = result["message"] as? String {
                        if status == 0 {
                            self.observer?.showAlertMessageWith?(title: "Divineray", message: error)
                        } else {
                            let params: Parameters = ["user_id": ApplicationStates.getUserID()]
                            self.streamSocket?.emitNewType(json: params, roomId: self.stream_room ?? "", messageType: .joinStreamRequestsReceived)
                            self.observer?.observeApiUserJoinStreamv2?()
                        }
                    }
                } else {
                }
                break
            case .failure(let error):
                print("error \(error)")
                self.observer?.showAlertMessageWith?(title: API.userstreamjoinrequestv2, message: error)
                break
            }
        }
    }
    
    //MARK: - LEAVE STREAM V2
    func leavestreamv2(params: Parameters) {
        print("API called \(API.leavestreamv2)\n\(params)")
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.leavestreamv2, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                if let result:[String:Any] = json as? Dictionary {
                    print("response is \(result)")
                } else {
                }
                self.observer?.observeApiLeavestreamv2Response?()
                self.apiViewLiveStream(is_view: "0")
                break
            case .failure(let error):
                self.observer?.showAlertMessageWith?(title: API.leavestreamv2, message: error)
                break
            }
        }
    }
    
    //MARK: - APPROVE REJECT LIVE STREAM
    func approveRejectStream(isApproved: Bool, user: UserDetail?, tableView: UITableView) {
        let status: String = isApproved ? "1" : "2"
        let params: Parameters = [
            "user_id"    : user?.user_id ?? "",
            "stream_id"  : self.stream_id ?? "",
            "stream_room": self.stream_room ?? "",
            "type"       : status
        ]
        print("API called \(API.approveRejectStream)\n\(params)")
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.approveRejectStream, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                if let result:[String:Any] = json as? Dictionary {
                    print("response is \(result)")
                }
                if isApproved == true{
                    self.streamSocket?.emitNewType(json: ["user_id" : user?.user_id ?? ""], roomId: self.stream_room ?? "", messageType: .acceptingRequestToJoinStreamForHost)
                }
                
                self.apiHostLiveDetails(joinChannel: false)
                
                if isApproved == true {
                    user?.status = status
                }
                else {
                    self.streamModel?.joinuser = self.streamModel?.joinuser?.filter({$0.user_id != user?.user_id})
                }
                
                tableView.reloadData()
            case .failure(let error):
                self.observer?.showAlertMessageWith?(title: API.approveRejectStream, message: error)
                
            }
        }
    }
    
    
    
    
    
    //MARK: KICK USER TO LIVE STREAM
    func kickUserApi(user: UserDetail?, tableView: UITableView) {
        let params: Parameters = [
            "user_id"    : user?.user_id ?? "",
            "stream_id"  : self.stream_id ?? "",
            "stream_room": self.stream_room ?? "",
            "type"       : "2"
        ]
        print("API called \(API.approveRejectStream)\n\(params)")
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.approveRejectStream, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                if let result:[String:Any] = json as? Dictionary {
                    print("response is \(result)")
                }
                self.streamSocket?.emitNewType(json: ["user_id" : user?.user_id ?? ""], roomId: self.stream_room ?? "", messageType: .kickUserJoined)
                self.apiHostLiveDetails(joinChannel: false)
                self.streamModel?.joinuser = self.streamModel?.joinuser?.filter({$0.user_id != user?.user_id})
                tableView.reloadData()
            case .failure(let error):
                self.observer?.showAlertMessageWith?(title: API.approveRejectStream, message: error)
                
            }
        }
    }
    
    //MARK: - LIKE LIVE STREAM
    func likestreamandUnlikestream(sender: UIButton) {
        let params: Parameters = ["stream_id": self.stream_id ?? "",
                                  "user_id"  : ApplicationStates.getUserID()]
        print("API called \(API.likestreamandUnlikestream)\n\(params)")
        sender.addActivityIndigator()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.likestreamandUnlikestream, postData: params) { (result) -> Void in
            sender.removeActivityIndigator()
            switch (result) {
            case .success(let json):
                if let result:[String:Any] = json as? Dictionary {
                    print("response is \(result)")
                }
                self.observer?.observeLikestreamAndUnlikestream?()
                
                let params:Parameters = ["user_id"    : ApplicationStates.getUserID(),
                                         "stream_id"  : self.stream_id ?? ""]
                self.streamSocket?.emitNewType(json: params, roomId: self.stream_room ?? "", messageType: .otherUserLikeStream)
                break
            case .failure(let error):
                self.observer?.showAlertMessageWith?(title: API.likestreamandUnlikestream, message: error)
                break
            }
        }
    }
    
    //MARK: - GET ALL LIVE USERS
    func getAllLiveUserByStreamID() {
        let params: Parameters = ["stream_id"  : self.streamModel?.streamDetail?.stream_id ?? "",
                                  "user_id"    : ApplicationStates.getUserID(),
                                  "stream_room": self.streamModel?.streamDetail?.stream_room ?? ""]
        
        print("API called \(API.getAllLiveUserByStreamID)\n\(params)")
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAllLiveUserByStreamID, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                if let result: [String: Any] = json as? Dictionary {
                    print("response is \(result)")
                }
                if let response = DataDecoder.decodeData(json, type: LiveUsersModel.self) {
                    self.liveUsers = response.data ?? []
                }
                self.bottomSheetObserver?.observeAllLiveUserByStreamID?()
                break
            case .failure(let error):
                self.observer?.showAlertMessageWith?(title: API.getAllLiveUserByStreamID, message: error)
                break
            }
        }
    }
    
    //MARK: - DISABLE LIKE COMMENTING
    func disableLikeComment(isLike:Bool) {
        var params: [String:Any] = [:]
        params["user_id"]     = ApplicationStates.getUserID()
        params["stream_id"]   = self.stream_id
        params["stream_room"] = self.stream_room
        params["type"]        = isLike ? "1" : "2"
        
        print("\n\nAPI called \(API.disableLikeComment)\n\(params)\n\n\n")
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.disableLikeComment, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                if let result:[String:Any] = json as? Dictionary {
                    print("\n\nresponse is \(API.disableLikeComment) \n\(result)\n\n\n")
                }
                if isLike == true {
                    let disable_like = self.streamModel?.streamDetail?.disable_like == "0"
                    self.streamModel?.streamDetail?.disable_like = disable_like ? "1" : "0"
                    
                    let params:Parameters = ["enable"     : self.streamModel?.streamDetail?.disable_like ?? "0",
                                             "user_id"    : ApplicationStates.getUserID(),
                                             "stream_id"  : self.stream_id ?? ""]
                    self.streamSocket?.emitNewType(json: params, roomId: self.stream_room ?? "", messageType: .disableLikeForViewers)
                }
                else {
                    
                    let disable_comment = self.streamModel?.streamDetail?.disable_comment == "0"
                    
                    self.streamModel?.streamDetail?.disable_comment =  disable_comment ? "1" : "0"
                    
                    let params:Parameters = ["enable"     : self.streamModel?.streamDetail?.disable_comment ?? "0",
                                             "user_id"    : ApplicationStates.getUserID(),
                                             "stream_id"  : self.stream_id ?? ""]
                    
                    self.streamSocket?.emitNewType(json: params, roomId: self.stream_room ?? "", messageType: .disableCommentForViewers)
                }
                break
            case .failure(let error):
                self.observer?.showAlertMessageWith?(title: API.disableLikeComment, message: error)
                break
            }
        }
    }
    
    //MARK: - SHOW MESSAGE TO EXIT STREAM
    func showMessageToExitStream(_vc: UIViewController, params: Parameters) {
        let alert  = UIAlertController(title: "", message: "Are you sure, you want to end this live stream?", preferredStyle: .actionSheet)
        let yes    = UIAlertAction(title: "Yes", style: .default) { [weak self] action in
            DispatchQueue.main.async { [weak self] in
                self?.endStreamingV2(params: params)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(cancel)
        _vc.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - SHOW MESSAGE TO LEAVE STREAM
    func showMessageToLeaveStream(_vc: UIViewController, params: Parameters) {
        let alert  = UIAlertController(title: "", message: "Are you sure, you want to leave this live stream?", preferredStyle: .actionSheet)
        let yes    = UIAlertAction(title: "Yes", style: .default) { [weak self] action in
            DispatchQueue.main.async { [weak self] in
                self?.leavestreamv2(params: params)
            }
        }
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(cancel)
        _vc.present(alert, animated: true, completion: nil)
    }
    
}

//MARK: - SOCKET ACTIONS
@available(iOS 14.0, *)
extension LiveStreamVM {
    func connectToSocket() {
        if self.streamSocket == nil {
            self.streamSocket = StreamSocket(delegate: self)
        }
        self.streamSocket?.connect()
    }
    
    func disconnectSocket() {
        self.streamSocket?.connect()
        self.streamSocket = nil
    }
    
    func disableLikeComment() {
    }
    
    
    //MARK: - SEND NEW COMMENT
    func sendNewMessasge(_ message: String, sender: UIButton) {
        let params: [String:Any] = ["stream_id": self.stream_id ?? "",
                                    "user_id": ApplicationStates.getUserID(),
                                    "comment": message]
        sender.addActivityIndigator()
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.Addstreamcommentsv2, postData: params){ (result) -> Void in
            sender.removeActivityIndigator()
            switch (result) {
            case .success(let json):
                let data = (json as! [String:Any])["data"] as! [String: Any]
                print("Message Sent : \(data)")
                if let messgae = DataDecoder.decodeData(json, type: MessageDataModel.self)?.data {
                    print("new message send successfully")
                    self.observer?.observeNewMessageSendSussfully?()
                    self.chatHistory.append(messgae)
                    var indexPath = IndexPath(row: 0, section: 0)
                    if self.chatHistory.count > 0 {
                        indexPath = IndexPath(row: self.chatHistory.count-1, section: 0)
                    }
                    self.observer?.observeNewMessageRecieved?(indexPath: indexPath)
                    //MARK: - SEND COMMENT SOCKET
                    self.streamSocket?.sendNewMessage(json: data, roomId: self.stream_room ?? "")
                }
            case .failure(let error):
                print("error to send message \(error)")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DashBoardDataFetch"), object: ["error":error])
                break
            }
        }
    }
    
    
    
}

//MARK: - SOCKET DelegateS
@available(iOS 14.0, *)
extension LiveStreamVM: StreamSocketDelegate {
    func socketManager(isConnected: Bool) {
        print("socket is connected \(isConnected)")
        self.streamSocket?.conncetedChat(roomId: self.stream_room ?? "")
    }
    
    func socketManager(_ socket: StreamSocket, newMessage data: [String: Any]) {
        //        print("socket is newMessage ")
        guard let type = data.getMessageType() else { return }
        switch type {
            
        case .streamEndedByHost:
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshLiveUsersListing"), object: nil)
            var params: Parameters = Parameters()
            params["user_id"]    = ApplicationStates.getUserID()
            params["stream_id"]  = self.stream_id
            self.leavestreamv2(params: params)
            
        case .rejectLiveStream:
            break
            
        case .kickUserJoined:
            if data.string(_for: "user_id") ?? "" == ApplicationStates.getUserID() {
                self.observer?.hostKickUserFromLiveStream?()
                self.apiHostLiveDetails(joinChannel: false)
            }
            break
            
        case .forJoinedUsers:
            
            self.apiHostLiveDetails(joinChannel: false)
            
        case .otherUserLikeStream:
            
            self.observer?.observeLikestreamAndUnlikestream?()
            
        case .disableLikeForViewers:
            
            let enable = data.string(_for: "enable")
            print("enables disable_like **** \(enable ?? "")")
            self.streamModel?.streamDetail?.disable_like = enable
            self.observer?.observeDisableCommentForViewers?(isLike: true, isEnabled: enable != "0")
            
        case .disableCommentForViewers:
            
            let enable = data.string(_for: "enable")
            print("enables  disable_comment **** \(enable ?? "")")
            self.streamModel?.streamDetail?.disable_comment = enable
            self.observer?.observeDisableCommentForViewers?(isLike: false, isEnabled: enable != "0")
            
        case .userLeaveLiveStram , .userJoinedWithName :
            
            self.addNewMessage(data: data)
            self.apiHostLiveDetails(joinChannel: false)
            self.getAllLiveUserByStreamID()
            
        case .newMessageRecievd :
            
            self.addNewMessage(data: data)
            
        case .acceptRejectKickLeave:
            
            self.apiHostLiveDetails(joinChannel: false)
            
        case .joinStreamRequestsReceived:
            
            self.apiHostLiveDetails(joinChannel: false)
            self.observer?.joinStreamRequestsReceived?()
            
        case .acceptingRequestToJoinStreamForHost:
            if data.string(_for: "user_id") ?? "" == ApplicationStates.getUserID() {
                self.observer?.acceptingRequestToJoinStreamForHost?()
            }
            self.apiHostLiveDetails(joinChannel: false)
        default: break
        }
    }
    
    private func addNewMessage(data: [String: Any]) {
        let message = MessageData(dict: data)
        self.chatHistory.append(message)
        var indexPath = IndexPath(row: 0, section: 0)
        if self.chatHistory.count > 0 {
            indexPath = IndexPath(row: self.chatHistory.count-1, section: 0)
        }
        self.observer?.observeNewMessageRecieved?(indexPath: indexPath)
    }
    
    func socketManager(_ socket: StreamSocket, handleJoinedMessage data: [String: Any]) {
        print("socket is handleJoinedMessage ")
    }
    
    func socketManager(_ socket: StreamSocket, handleUserTyping trueIndex: Int?) {
        print("socket is handleUserTyping ")
    }
    
    func socketManager(_ socket: StreamSocket, handleUserStopTyping trueIndex: Int?) {
        print("socket is handleUserStopTyping")
    }
}

extension UIView {
    
    func addActivityIndigator(isRounded:Bool = false, color: UIColor? = nil, indigatorColor:UIColor? = nil) {
        removeActivityIndigator()
        
        let indigator = UIActivityIndicatorView(frame: self.bounds)
        if let color = color {
            indigator.backgroundColor = color
        } else {
            indigator.backgroundColor = .clear
        }
        if let indigatorColor = indigatorColor {
            indigator.color = indigatorColor
        }
        indigator.restorationIdentifier = "activity"
        indigator.tag = 90909090
        indigator.startAnimating()
        if isRounded {
            indigator.cornerRadius = indigator.frame.size.height/2
        }
        self.addSubview(indigator)
    }
    
    func removeActivityIndigator() {
        if let indigator = self.subviews.first(where: {$0.isKind(of: UIActivityIndicatorView.self)}) as? UIActivityIndicatorView {
            indigator.stopAnimating()
            indigator.removeFromSuperview()
        }
    }
    
}
