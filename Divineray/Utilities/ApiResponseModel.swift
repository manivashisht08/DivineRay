//
//  ApiResponseModel.swift
//  SetUpNewProject
//
//  Created by dr mac on 09/01/23.
//

import Foundation
struct ApiResponseModel<T: Decodable> : Decodable{
    var data:T?
    var message:String?
    var status:Int?
    var isLock:Int?
//    var newMatch: [ChatListMatch]?
//    var userdata:Userdata?
    var likeCount: String?
    var swipeCount: String?
    var undoCount:String?
//    var postImages:[PostImageData]?
//    var notificationCount:String?
//    var recentSearch:[FriendListData]?
    var TotalTime:String?
    var dataLink:String?
    var isFriend:Int?
    var isLike:Int?
//    var subscriptionHistory: SubscriptionHistory?
}

