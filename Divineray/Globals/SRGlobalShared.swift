//
//  GlobalShared.swift
//  Divineray
//
//  Created by     on 08/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit

var kGradintStartColor =  UIColor.hexColorStr("#071930", alpha: 1)
var kGradintEndColor  =  UIColor.hexColorStr("#223c53", alpha: 1)


enum NetworkEnvironment {
    case qa
    case production
    case staging
    case testing
}

let environment: NetworkEnvironment = .testing
  
var environmentBaseURL : String {
    switch environment {
    case .production: return "https://divineray.io/webservice/"
    case .qa: return "https://forkastapp.com/divine_ray_v3/webservice/"
    case .staging: return "https://forkastapp.com/divine_ray_v2/webservice/"
    case .testing: return "https://divineray.io/webservice_divine/"
    }
}

struct API {
    
    private init() {
        
    }
    
    static var appName: String {
        return "Divine Ray"
    }
    // Api
    
    static var signInURL: String {
        return environmentBaseURL + "Login.php"
    }
    static var facebookLoginURL: String {
        return environmentBaseURL + "FacebookLogin.php"
    }
    static var appleLoginURL: String {
        return environmentBaseURL + "AppleLogin.php"
    }
    static var twitterLogin: String {
        return environmentBaseURL + "TwitterLogin.php"
    }
    static var signupURL: String {
        return environmentBaseURL + "SignUp.php"
    }
    
    static var recoverpasswordURL: String {
        return environmentBaseURL + "ForgetPassword.php"
    }
    static var GetFollowUsersURL: String {
        return environmentBaseURL + "GetFollowUsers.php"
    }
    static var logoutURL: String {
        return environmentBaseURL + "Logout.php"
    }
    static var allReportReason: String {
        return environmentBaseURL + "GetAllReportReasons.php"
    }
    static var editUserProfileURL: String {
        return environmentBaseURL + "EditUserProfile.php"
    }
    static var addUploadPostURL:String{
        return environmentBaseURL + "uploadVideoV2.php"
    }
    
    static var allGroupListURL:String{
        return environmentBaseURL + "GetAllGroupLists.php"
    }
    
    static var createGroupChatURL:String{
        return environmentBaseURL + "createGroupChat.php"
    }
    
    static var updateNotificationURL: String {
        return environmentBaseURL + "UpdateNotification.php"
    }
    static var uploadVideoURL: String {
        return environmentBaseURL + "uploadVideo.php"
    }
    static var getAllVideosURL: String {
        return environmentBaseURL + "GetAllVideos.php"
    }
    static var likeViewUpdateURL: String {
        return environmentBaseURL + "LikeViewVideo.php"
    }
    static var addUpdateCommentURL: String {
        return environmentBaseURL + "AddUpdateComment.php"
    }
    static var getAllCommentsURL: String {
        return environmentBaseURL + "GetAllComments.php"
    }
    static var getProfileDetailsURL: String {
        return environmentBaseURL + "GetProfileDetails.php"
    }
    static var getAllUserVideosURL: String {
        return environmentBaseURL + "GetAllUserVideos.php"
    }
    static var getAllFavVideosURL: String {
        return environmentBaseURL + "GetAllFavVideos.php"
    }
    static var followUnfollowUserURL: String {
        return environmentBaseURL + "FollowUnfollowUser.php"
    }
    static var getFollowUsersURL: String {
        return environmentBaseURL + "GetFollowUsers.php"
    }
    static var getAllTaggedVideosURL: String {
        return environmentBaseURL + "GetAllTaggedVideos.php"
    }
    static var getAllMusicURL: String {
        return environmentBaseURL + "GetAllMusic.php"
    }
    static var getAllTagsListingAndSearchURL : String {
        return environmentBaseURL + "GetAllTagsListingAndSearch.php"
    }
    static var getRemoveVideoURL: String {
        return environmentBaseURL + "RemoveVideo.php"
    }
    static var getAllReportReasonURL: String {
        return environmentBaseURL + "GetAllReportReasons.php"
    }
    static var getAddReportAbuseURL: String {
        return environmentBaseURL + "AddReportAbuse.php"
    }
    static var joinGroupRequestURL: String {
        return environmentBaseURL + "joinGroupRequest.php"
    }
    
    static var GroupRequestListingURL: String {
        return environmentBaseURL + "GroupRequestListing.php"
    }
    static var acceptRejectGroupRequestURL: String {
        return environmentBaseURL + "acceptRejectGroupRequest.php"
    }
    static var blockUserURL: String {
        return environmentBaseURL + "blockUser.php"
    }
    static var getChatListURL: String {
        return environmentBaseURL + "GetAllChatListsV2.php"
    }
    static var getChatMessageDetailURL: String {
        return environmentBaseURL + "GetAllChatMessagesV2.php"
    }
    static var addChatMessageDetailURL: String {
        return environmentBaseURL + "AddUpdateMessage.php"
    }
    static var searchChatListURL: String {
        return environmentBaseURL + "GetAllUsersSearch.php"
    }
    static var generateRoomIDURL: String {
        return environmentBaseURL + "CheckRoomConnection.php"
    }
    static var getAllCoinsURL: String {
        return environmentBaseURL + "GetAllProductCoins.php"
    }
    static var purchaseCoins: String {
        return environmentBaseURL + "PurchaseCoinsV2.php"
    }
    static var getAllUsersProductListing: String {
        return environmentBaseURL + "GetAllUsersProductListing.php"
    }
    static var getAllUsersMediaListing: String {
        return environmentBaseURL + "GetAllUsersMediaListing.php"
    }
    static var getAllGiftListing: String {
        return environmentBaseURL + "GetAllGiftListing.php"
    }
    static var shareGiftURL: String {
        return environmentBaseURL + "ShareGift.php"
    }
    
    static var addRequestAppointment: String {
        return environmentBaseURL + "AddRequestAppointment.php"
    }
    static var getAllNotificationsDetails: String {
        return environmentBaseURL + "GetAllNotificationsDetails.php"
    }
    static var UpdateMessageSeenURL: String {
        return environmentBaseURL + "UpdateMessageSeen.php"
    }
    
    static var purchaseMedia: String {
        return environmentBaseURL + "PurchaseMedia.php"
    }
    static var getAllAppointmentListing: String {
        return environmentBaseURL + "GetAllAppointmentListingV3.php"
    }
    static var ShareUserProfile: String {
        return environmentBaseURL + "ShareUserProfile.php"
    }
    static var getFullProfileDetailsURL: String {
        return environmentBaseURL + "getFullProfileDetailsURL.php"
    }
    static var getForceUpdateDetails: String {
        return environmentBaseURL + "GetVersion.php"
    }
    
    static var getAllStreamVideo: String {
        return environmentBaseURL + "getAllStreamVideo.php"
    }
    
    static var getLiveUsers: String {
        return environmentBaseURL + "getLiveUsers.php"
    }
    
    static var goingliveV2: String {
        return environmentBaseURL + "GoingliveV2.php"
    }
    
    static var goingliveV3: String {
        return environmentBaseURL + "GoingliveV3.php"
    }
    
    static var hostlivedetails: String {
        return environmentBaseURL + "Hostlivedetails.php"
    }
    
    static var getAllstreamcommentsv2: String {
        return environmentBaseURL + "GetAllstreamcommentsv2.php"
    }
    
    static var viewLiveStream: String {
        return environmentBaseURL + "viewLiveStream.php"
    }
    
    //New API's
    static var endstreamV2: String {
        return environmentBaseURL + "EndstreamV2.php"
    }
    
    static var approveRejectStream: String {
        return environmentBaseURL + "approveRejectStream.php"
    }
    
    static var leavestreamv2: String {
        return environmentBaseURL + "Leavestreamv2.php"
    }
    
    static var userstreamjoinrequestv2: String {
        return environmentBaseURL + "userstreamjoinrequestv2.php"
    }
    static var Addstreamcommentsv2: String {
        return environmentBaseURL + "Addstreamcommentsv2.php"
    }
    static var disableLikeComment: String {
        return environmentBaseURL + "disableLikeComment.php"
    }
    static var likestreamandUnlikestream: String {
        return environmentBaseURL + "LikestreamandUnlikestream.php"
    }
    static var getAllLiveUserByStreamID: String {
        return environmentBaseURL + "getAllLiveUserByStreamID.php"
    }
    static var createLiveStreamToken: String {
        return environmentBaseURL + "createLiveStreamToken.php"
    }
    
    static var RmUser: String {
        return environmentBaseURL + "RmUser.php"
    }
    
    static var blockUser: String {
        return environmentBaseURL + "blockUser.php"
    }
    
    static var GetAllReportReasons: String {
        return environmentBaseURL + "GetAllReportReasons.php"
    }
    
    static var AddReportAbuse: String {
        return environmentBaseURL + "AddReportAbuse.php"
    }
    
}
