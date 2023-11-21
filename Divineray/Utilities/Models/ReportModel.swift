//
//  ReportModel.swift
//  Divineray
//
//  Created by dr mac on 16/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import Foundation
struct ReportModel: Codable {
    var status: Int?
    var message: String?
    var data: [ReportData]?
}

// MARK: - Datum
struct ReportData: Codable {
    var reasonID, reportreasons: String?

    enum CodingKeys: String, CodingKey {
        case reasonID = "reasonId"
        case reportreasons
    }
}
