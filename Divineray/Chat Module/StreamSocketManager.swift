//
//  StreamSocketManager.swift
//  Divineray
//
//  Created by mac on 22/03/22.
//  Copyright © 2022 Dharmani Apps. All rights reserved.
//

import Foundation
import SocketIO


enum SOCKET_MESSAGE_TYPE: Int {
    
//    type - 3 -> send data key from Add Stream Commnet API Response
//    addStreamCommnetv2.php -> reponse["data"]
    case newMessageRecievd = 1
    
//    type - 3 -> Reject live stream
//    Case: When anther user is joined on live streaming and user sends a request to join live streaming and broacaster rejects the request then type 3 will be used in socket.
    case rejectLiveStream = 3 // reject
    
//    type - 4 -> Kick user joined
//    Case: After accepting the request sent by another user, braodcaster has a
//    option a option to kick that user out for that type 4 will be used.
    case kickUserJoined   = 4
    
//    type - 5 -> Stream ended by host
//    Case: When braodcaster/host ends the stream, then type 5 will be used.
    case streamEndedByHost = 5
    
//    type - 6 -> Some user left with api
//    Case: When any user from audience lefts the stream, then type 6 will be used.
    case someUserLeftWithApi   = 6
    
//    type - 7 -> user joined/left the chat for count updation
//    Case: For increasing/decreasing the count after user left or joined , type 7
//    will be used.
    case leftJoinedUsersCountUpdation = 7
    
//    type - 8 -> user joined with name text in chat listing
//    Case: When user joins streaming, that user's will show on listing of joined
//    users.
    case userJoinedWithName   = 8
    
//    type - 9 -> When Join stream requests received,show red dot on new list Case: When user sends request to join streaming, red dot shows with
//    broadcaster's details on right side, for that type 9 will be used
    case joinStreamRequestsReceived = 9
    
//    type - 10 -> When other user liking the stream, it willl show heart animation
//     Case: When any user from audience and braodcast clicks on heart icon.
//    User clicked on icon : red color icon will show
//    Other users: grey color icon will show
    case otherUserLikeStream   = 10

//    type - 11 -> Accepting the request to join stream for host
//    Case: When users send a request to join then at broadcast side, request will show.
    case acceptingRequestToJoinStreamForHost = 11
    
//    type - 13 -> When user have been rejected to join stream/ or kick
//    Case: When users send a request to join then at broadcast side, for rejected
//    and for kicked out users, layout will change.
    case userRejectedToJoinStreamKick   = 13
    
//    type - 14 -> Disable like for viewers
//    Case: After clicked on option's icon, a bottomsheet opens, there if clicked
//    on Disable Like for Viewers then typw 14 will be used.
    case disableLikeForViewers = 14
    
//    type 15 -> Disable comment for viewers
//    Case: After clicked on option's icon, a bottomsheet opens, there if clicked
//    on Disable Comments for Viewers then type 15 will be used.
    case disableCommentForViewers   = 15

//    type 16 -> For joined users
//    Case: After users have joined in live streaming then data will be changed
//    acc. to response of Hostlivedetails.php API.
    case forJoinedUsers   = 16
    
//  type 101 -> for joined user to leave the live stream
    case userLeaveLiveStram  = 100
    
//    type 101 -> for accept, reject and kick cases and for levaing sream by audienece and by host.
    case acceptRejectKickLeave  = 101
    
}


extension Dictionary {
    
    func string(_for key:String) -> String? {
        return (self as? [String:Any])?[key] as? String
    }
    
    func getMessageType() -> SOCKET_MESSAGE_TYPE? {
        let value = Int(self.string(_for: "type") ?? "") ?? 0
        return SOCKET_MESSAGE_TYPE(rawValue: value)
    }
    
}


protocol StreamSocketDelegate: NSObjectProtocol {
    func socketManager(isConnected: Bool)
    func socketManager(_ socket: StreamSocket, newMessage data: [String: Any])
    func socketManager(_ socket: StreamSocket, handleJoinedMessage data: [String: Any])
    func socketManager(_ socket: StreamSocket, handleUserTyping trueIndex: Int?)
    func socketManager(_ socket: StreamSocket, handleUserStopTyping trueIndex: Int?)
}

class StreamSocket {
    
    var manager : SocketManager!
    var socket  : SocketIOClient!
    weak var delegate : StreamSocketDelegate?
    
    
    init(delegate: StreamSocketDelegate?) {
        manager = SocketManager(socketURL: URL(string: "http://161.97.132.85:3020/")!, config: [.log(false), .compress])
        socket = manager.defaultSocket
        self.delegate = delegate
        //        connect()
    }
    
    func connect() {
        if socket != nil {
            socket.connect()
            setSocket()
        }
    }
    
    func disconnect() {
        socket.disconnect()
        socket = nil
    }
    
    func setSocket() {
        socket.on("connect") { (_, _) in
            print(" ************ onConnect ************")
            self.delegate?.socketManager(isConnected: true)
        }
        socket.on("newMessage") { (data, ack) in
            let msg = data[1] as! [String: Any]
            print("\n\n ************ newMessage ************ \n\(msg)\n\n")
            self.delegate?.socketManager(self, newMessage: msg)
        }
        socket.on("ChatStatus") { (data, ack) in
            let msg = data[1] as! [String: Any]
            print("\n\n ************ ChatStatus ************ \n\(msg)\n\n")
            self.delegate?.socketManager(self, handleJoinedMessage: msg)
        }
        socket.on("type") { (data, ack) in
            let trueIndex = data[1] as? Int
            print("\n\n ************ type ************ \n\(trueIndex)\n\n")
            self.delegate?.socketManager(self, handleUserTyping: trueIndex)
        }
        socket.on("userStopTyping") { (_, _) in
            print("\n\n ************ userStopTyping ************ \n\n")
            self.delegate?.socketManager(self, handleUserStopTyping: 0)
        }
    }
    
    func sendNewMessage(json: Parameters, roomId: String) {
        guard socket != nil else { return }
        print("send message is *** \(json) *** \(roomId) **  \(socket.status)")
        checkConnectionStatus { [weak self] in
            DispatchQueue.main.async {
                self?.socket.emit("newMessage", roomId, json)
            }
        }
    }
    
    func conncetedChat(roomId: String) {
        guard socket != nil else { return }
        print("ConncetedChat is ***  *** \(roomId) **  \(socket.status)")
        self.checkConnectionStatus { [weak self] in
            DispatchQueue.main.async {
                self?.socket.emit("ConncetedChat", roomId)
            }
        }
    }
    
    func checkConnectionStatus(complition:(()->())? = nil) {
        switch self.socket.status {
        case .connected:
            complition?()
        default:
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.checkConnectionStatus(complition: complition)
            }
        }
    }
    
    func emitNewType(json: Parameters, roomId: String, messageType: SOCKET_MESSAGE_TYPE) {
        guard self.socket != nil else { return }
        var dict     = json
        dict["type"] = "\(messageType.rawValue)"
        print("send message is *** \(dict) *** \(roomId) **  \(socket.status)")
        checkConnectionStatus { [weak self] in
            DispatchQueue.main.async {
                self?.socket.emit("newMessage", roomId, dict)
            }
        }
    }
}
