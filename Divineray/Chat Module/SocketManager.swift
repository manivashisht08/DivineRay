//
//  SocketManager.swift
//  Socket demo
//
//  Created by IMac on 11/18/19.
//  Copyright © 2019 abc. All rights reserved.
//

import Foundation
import SocketIO



class SocketManger {
    
    static let shared = SocketManger()
    let manager = SocketManager(socketURL: URL(string: "http://161.97.132.85:3020/")!, config: [.log(true), .compress])
    var socket: SocketIOClient!
    
    init() {
        self.socket = self.manager.defaultSocket
    }
    
    func connect() {
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func onConnect(handler: @escaping () -> Void) {
        socket.on(clientEvent: .connect) { (_, _) in
            handler()
        }
    }
    
    func handleNewMessage(handler: @escaping (_ message: [String: Any]) -> Void) {
        self.socket.on("newMessage") { (data, ack) in
            let msg = data[1] as! [String: Any]
            handler(msg)
        }
    }
    
    func handleJoinedMessage(handler: @escaping (_ message: [String: Any]) -> Void) {
        socket.on("ChatStatus") { (data, ack) in
            let msg = data[1] as! [String: Any]
            handler(msg)
        }
    }
    
    func handleUserTyping(handler: @escaping (_ trueIndex: Int) -> Void) {
        socket.on("type") { (data, ack) in
            let trueIndex = data[1] as? Int
            handler(trueIndex!)
        }
    }
    
    func handleUserStopTyping(handler: @escaping () -> Void) {
        socket.on("userStopTyping") { (_, _) in
            handler()
        }
    }
    
}
