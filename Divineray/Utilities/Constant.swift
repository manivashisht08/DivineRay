//
//  Constant.swift
//  SetUpNewProject
//
//  Created by dr mac on 09/01/23.
//

import Foundation
//let baseUrl = "https://dharmani.com/flamingo/webservices/"
//let baseUrl = "http://161.97.132.85/j2/flamingo/webservices/"

// Mark - Live url
//let baseUrl = "https://floomingo.com/webservices/"
//let baseUrl = "http://floomingo.com/webservicesV2/"
//let baseUrl = "http://161.97.132.85/j2/flamingo/webservicesV2/"
let baseUrl = "https://floomingo.org/webservicesV2/"

class Constantt: NSObject {
    
    static let appName = "Floomingo"
    static let Login = baseUrl + "login.php"
    static let SignUp = baseUrl + "signUp.php"
    static let onBoarding = baseUrl + "completeProfile.php"
    static let ForgotPassword = baseUrl + "forgetPassword.php"
    static let Hobbies = baseUrl + "getAllHobbies.php"
    static let Ethnicity = baseUrl + "getAllEthnicity.php"
    static let home = baseUrl + "homeListingV2.php"
    static let getProfile = baseUrl + "getProfile.php"
    static let removeRecentSearch = baseUrl + "removeRecentSearch.php"
    static let  myActivity = baseUrl + "myActivity.php"
    static let sharePost = baseUrl + "sharePost.php"
    static let getFriendList = baseUrl + "friendListing.php"
    static let deletePostID = baseUrl + "deletePostV2.php"
    static let friendUnfriend = baseUrl + "friendUnfriend.php"
    static let notificationListing = baseUrl + "getNotificationListing.php"
    static let acceptRejectRequest = baseUrl + "acceptRejectFriendRequest.php"
    static let likeDislike = baseUrl + "likeDislikePost.php"
    static let userBlockListing = baseUrl + "userBlockListing.php"
    static let chatListing = baseUrl + "getAllChatUsers.php"
    //    static let likeUnlike = baseUrl + "likeDislikeUser.php"
    static let likeUnlike = baseUrl + "likeDislikeUserV2.php"
    static let getMyPostListing = baseUrl + "getMyPostListing.php"
    static let shareHomePost = baseUrl + "sharePost.php"
    static let connectSocialLogin = baseUrl + "connectSocialLogin.php"
    static let updateUserSession = baseUrl + "updateUserSession.php"

    static let boostProfile = baseUrl + "boostMyProfile.php"
    static let addCard = baseUrl + "addCard.php"
    static let cardListing = baseUrl + "cardsListing.php"

    static let undolikeUnlike = baseUrl + "undoLikeDislike.php"
    
    static let addRemoveImg = baseUrl + "addRemoveImage.php"
    static let likeListing = baseUrl + "userLike.php"
    static let reportUser = baseUrl + "getAllReportReasons.php"
    static let AddReport = baseUrl + "addReport.php"
    static let GetReport  = baseUrl + "getAllReportReasons.php"
    static let ProfileDetail = baseUrl + "get_profile_detail.php"
    static let Logout = baseUrl + "logOut.php"
    static let deleteAccount = baseUrl + "deleteUserAccount.php"
    static let term = "https://floomingo.godaddysites.com"
    static let privacy = "https://floomingo.godaddysites.com"
    static let ChangePassword = baseUrl + "changePassword.php"
    static let favourite = baseUrl + "favourite.php"
    static let notInterested = baseUrl + "not_interested.php"
    static let chatMessageDetail = baseUrl + "getAllMessage.php"
    static let sendMessage = baseUrl + "sendMessage.php"
    static let getSubscription = baseUrl + "getSubscription.php"
    static let checkPurchase = baseUrl + "checkPurchaseAlready.php"
    static let updateSubscription = baseUrl + "updateSubscriptionV2.php"
    static let editProfile = baseUrl + "editprofile.php"
    static let deletechat = baseUrl + "delete_chat.php"
    static let userBlock = baseUrl + "userBlock.php"
    static let createRoom = baseUrl + "createRoom.php"
    static let updateChatStatus = baseUrl + "updateMessage.php"
    static let addEditPost = baseUrl + "addEditPost.php"
}
