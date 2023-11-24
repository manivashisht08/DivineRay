//
//  GroupListModel.swift
//  Divineray
//
//  Created by dr mac on 15/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import Foundation
struct GroupListModel: Codable {
    var status: Int?
    var message: String?
    var data: [GroupListData]?
}

// MARK: - Datum
struct GroupListData: Codable {
    var id, userID, chatUserID, roomID: String?
    var groupName,isGroup,groupCreatedBy,requestStatus: String?
    var groupImage: String?
    var roomCreated,username,isDisable,userCount: String?
    var isSelected :Bool?
    var isJoined:Int?
    
    mutating func updateSelected(isSelected:Bool){
        self.isSelected = isSelected
    }
    enum CodingKeys: String, CodingKey {
        case id,isSelected,isJoined,username
        case userID = "user_id"
        case chatUserID = "chatUserId"
        case roomID = "roomId"
        case groupName, isGroup, groupCreatedBy, requestStatus, groupImage, roomCreated, isDisable, userCount
    }
}
