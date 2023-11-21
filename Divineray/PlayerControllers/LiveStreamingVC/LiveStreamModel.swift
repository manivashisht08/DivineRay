//
//  LiveStreamModel.swift
//  Divineray
//
//  Created by mac on 28/04/22.
//  Copyright © 2022 Dharmani Apps. All rights reserved.
//

import UIKit
import Foundation


// MARK: - Live Stream Model
class LiveStreamModel: Codable {
    var message: String?
    var status: Int?
    var userDetail: UserDetail?
    var streamDetail: StreamDetail?
    var likecount: String?
    var viewcount: String?
    var joinuser: [UserDetail]?
    var data: StreamDetail?
    var cname: String?
    var token: String?


}

// MARK: - Host Details Model
class HostDetailsModel: Codable {
    var message: String?
    var status: Int?
    var userDetail: UserDetail?
    var streamDetail: [StreamDetail]?
    var likecount: String?
    var viewcount: String?
    var joinuserdetails: [UserDetail]?
}

// MARK: - Stream Detail
class StreamDetail: Codable {
    var stream_id: String?
    var user_id: String?
    var stream_room: String?
    var stream_start_time: String?
    var stream_end_time: String?
    var disable_comment: String?
    var disable_like: String?
    var cname: String?
    var token: String?
    var stream_token:String?
    var channel_name:String?

}

// MARK: - User Detail
class UserDetail: Codable {
    var user_id: String?
    var paypal_verification: String?
    var paypal_id: String?
    var paypal_token: String?
    var name: String?
    var email: String?
    var password: String?
    var photo: String?
    var country: String?
    var state: String?
    var countryCode: String?
    var twitterId: String?
    var facebookId: String?
    var appleId: String?
    var description: String?
    var verified: String?
    var totalFollowing: String?
    var totalFollowers: String?
    var verificateCode: String?
    var created_at: String?
    var disabled: String?
    var allowPush: String?
    var device_type: String?
    var total_coins: String?
    var device_token: String?
    var usertoken: String?
    var securitytoken: String?
    var certificate_status: String?
    var certificate: String?
    
    var status: String?
}

// MARK: - Host Details Model
class LiveUsersModel: Codable {
    var message: String?
    var status: Int?
    var data: [UserDetail]?
}


// MARK: - StreamDetail
//class JoinedUser: Codable {
//
//}

//enum MESSAGE_SENDER_TYPE: String {
//    case performLoginScreenCount = "7"
//    case performJoinUsernameCount = "100"
//    case performLoginScreenCount = ""
//    case performLoginScreenCount = ""
//    case performLoginScreenCount = ""
//    case performLoginScreenCount = ""
//    case performLoginScreenCount = ""
//}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

