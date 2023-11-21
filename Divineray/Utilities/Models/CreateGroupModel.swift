//
//  CreateGroupModel.swift
//  Divineray
//
//  Created by dr mac on 16/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import Foundation
struct CreateGroupModel: Codable {
    var code, status: Int?
    var message: String?
    var data: CreateGroupData?
}

// MARK: - DataClass
struct CreateGroupData: Codable {
    var id, userID, chatUserID, roomID: String?
    var groupName, isGroup, groupCreatedBy, requestStatus: String?
    var groupImage, roomCreated, isDisable: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case chatUserID = "chatUserId"
        case roomID = "roomId"
        case groupName, isGroup, groupCreatedBy, requestStatus, groupImage, roomCreated, isDisable
    }
}
