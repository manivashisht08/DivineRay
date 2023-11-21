//
//  MessageData.swift
//  Divineray
//
//  Created by mac on 25/04/22.
//  Copyright © 2022 Dharmani Apps. All rights reserved.
//


import Foundation


// MARK: - Message Data Model
class MessageDataModel: Codable {
    var status: Int?
    var message: String?
    var data: MessageData?
}

// MARK: - List Message Model
class ListMessageModel: Codable {
    var status: Int?
    var message: String?
    var data: [MessageData]?
}

// MARK: - Message Data
class MessageData: Codable {
    var id: String?
    var user_id: String?
    var stream_id: String?
    var stream_room: String?
    var comment: String?
    var type: String?
    var comment_time: String?
    var name: String?
    var photo: String?
    
    init() {
    }
    init(dict: [String: Any]) {
        self.photo = dict.string(_for: "photo")
        self.stream_id = dict.string(_for: "stream_id")
        self.name = dict.string(_for: "name")
        self.type = dict.string(_for: "type")
        self.comment_time = dict.string(_for: "comment_time")
        self.comment = dict.string(_for: "comment")
        self.user_id = dict.string(_for: "user_id")
        self.stream_room = dict.string(_for: "stream_room")
        self.id = dict.string(_for: "id")
        
        if let type = dict.getMessageType() {
            switch type {
            case .userLeaveLiveStram:
                self.comment = "\(self.name ?? "") left live stream"
                self.name = nil
            case .userJoinedWithName:
                self.comment = "\(self.name ?? "") joined live stream"
                self.name = nil
            default: break
            }
        }
    }
}


class DataDecoder: NSObject {
    
    class func decodeData<T>(_ object: AnyObject?, type: T.Type) -> T? where T : Decodable {
        guard let json = object as? [String: Any] else { return nil }
        guard let data = json.data else {
            return nil
        }
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(type.self, from: data)
            print("decodedData:-\(decodedData) **** \(data.count)")
            return decodedData
        } catch {
            print("error***** \(error)")
            return nil
        }
    }
    
}

extension Dictionary {
    var data: Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: [])
        } catch {
            return nil
        }
    }
    
}





