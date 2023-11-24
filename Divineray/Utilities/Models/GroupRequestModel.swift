//
//  GroupRequestModel.swift
//  Divineray
//
//  Created by dr mac on 23/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import Foundation
struct GroupRequestModel: Codable {
    var code, status: Int?
    var message: String?
    var data: String?
}
