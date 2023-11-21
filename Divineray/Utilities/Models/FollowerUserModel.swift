//
//  FollowerUserModel.swift
//  Divineray
//
//  Created by dr mac on 16/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import Foundation
struct FollowerUserModel: Codable {
    var status: Int?
    var message: String?
    var data: [FollowerUserData]?
}

// MARK: - Datum
struct FollowerUserData: Codable {
    var userID, paypalVerification, paypalID, paypalToken: String?
    var name, email, password: String?
    var photo: String?
    var country, state, countryCode, twitterID: String?
    var facebookID, appleID, description, verified: String?
    var totalFollowing, totalFollowers, verificateCode, createdAt: String?
    var disabled, allowPush, deviceType, totalCoins: String?
    var deviceToken, usertoken, securitytoken, certificateStatus: String?
    var certificate: String?
    var redeemDate: String?
    var redeemStatus, followID, id, follow: String?
    var isSelected :Bool?
    
    mutating func updateSelected(isSelected:Bool){
        self.isSelected = isSelected
    }
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case paypalVerification = "paypal_verification"
        case paypalID = "paypal_id"
        case paypalToken = "paypal_token"
        case name, email, password, photo, country, state, countryCode
        case twitterID = "twitterId"
        case facebookID = "facebookId"
        case appleID = "appleId"
        case description, verified, totalFollowing, totalFollowers, verificateCode
        case createdAt = "created_at"
        case disabled, allowPush
        case deviceType = "device_type"
        case totalCoins = "total_coins"
        case deviceToken = "device_token"
        case usertoken, securitytoken
        case certificateStatus = "certificate_status"
        case certificate
        case redeemDate = "redeem_date"
        case redeemStatus = "redeem_status"
        case followID = "follow_id"
        case id, follow
    }
}
