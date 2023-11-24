//
//  GroupRequestListModel.swift
//  Divineray
//
//  Created by dr mac on 24/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import Foundation
struct GroupRequestListModel: Codable {
    var code, status: Int?
    var message: String?
    var data: [GroupRequestListData]?
}

// MARK: - Datum
struct GroupRequestListData: Codable {
    var groupID, roomID, userID, groupCreatedBy: String?
    var isGroup, isCreatedByAdmin, requestStatus, isAllowNotification: String?
    var iscreatedTime, created, updatedAt, isDisable: String?
    var isDeleted, name: String?
    var image: String?

    enum CodingKeys: String, CodingKey {
        case groupID = "groupId"
        case roomID = "roomId"
        case userID = "user_id"
        case groupCreatedBy, isGroup, isCreatedByAdmin, requestStatus, isAllowNotification
        case iscreatedTime = "IscreatedTime"
        case created, updatedAt, isDisable, isDeleted, name, image
    }
}
