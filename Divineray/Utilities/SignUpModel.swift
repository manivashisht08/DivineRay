//
//  SignUpModel.swift
//  SetUpNewProject
//
//  Created by dr mac on 09/01/23.
//

import Foundation
struct SignupModel :Decodable{
    var firstName:String?
    var lastName:String?
    var gender:String?
    var email:String?
    var password:String?
    var deviceToken:String?
    var deviceType:String?
    var latitude:String?
    var longitude:String?
    var type:String?
    var userID:String?
    var lat:String?
    var log:String?
    var hobbiesID:String?
    var hobbies:String?
    var otherUserID:String?
    var reportedBy:String?
    var reportedId:String?
    var reasonId:String?
    var oldPassword:String?
    var newPassword:String?
    var confirmPassword:String?
    var perPage:String?
    var pageNo:String?
    var search:String?
    var senderID:String?
    var roomID:String?
    var message:String?
    var planName:String?
    var planID:String?
    var purchaseType :String?
    var planPrice:String?
    var planDuration:String?
    var expireDate:String?
    var receiverID:String?
    var dob:String?
    var city:String?
    var ethnicity:String?
    var age:String?
    var location:String?
    var description:String?
    var profileImage:[Data]?
    var postID :String?
    var address:String?
    var videoDescription:String?
    var postVideo:Data?
    var thumbImage:Data?
    var isFromSearch:String?
    var videoDuration:String?
    var id:String?
    var otherReason:String?
    var reportType:String?
    var cardToken:String?
    var cardNumber:String?
    var cvv:String?
    var expiryMonth:String?
    var expiryYear:String?
    var userName:String?
    var amount:String?
    var cardId:String?
    var token:String?
    var isUpdate:String?
    var postUserID:String?
    var user_id:String?
    var title:String?
    var tags:String?
    var postHeight:String?
    var postWidth:String?
    var musicId:String?
    var postImage:Data?
    var isGroupPost:String?
    var groupIds :String?
    var followType:String?
    var lastUserId:String?
    var profileUserId:String?
    var groupName:String?
    var ids :String?
    var groupImage:Data?
    var reportreasons:String?
    var blockTo:String?
        
    private enum CodingKeys : String, CodingKey {
        case firstName = "firstName", lastName = "lastName",email,password,latitude,longitude,deviceToken = "deviceToken",deviceType = "deviceType",type,userID,lat,log,hobbiesID,otherUserID,reportedBy,reportedId,reasonId,oldPassword,confirmPassword,newPassword,perPage,pageNo,search,senderID,planName,planPrice,planDuration,expireDate,roomID,message,receiverID,gender,dob,city,hobbies,ethnicity,profileImage,age,location,description,purchaseType,planID,postID,address,videoDescription,postVideo,thumbImage,isFromSearch,videoDuration,id,otherReason,reportType,cardToken,cardNumber,cvv,expiryMonth,expiryYear,userName,amount,cardId,token,isUpdate,postUserID,user_id,title,tags,postHeight,postWidth,musicId,postImage,isGroupPost,groupIds,followType,lastUserId,profileUserId,groupName,ids,groupImage,reportreasons,blockTo
    }
    func convertDict()-> NSMutableDictionary{
        let dict = NSMutableDictionary()
        dict.setValue(self.ids, forKey: "ids")
        dict.setValue(self.blockTo, forKey: "blockTo")
        dict.setValue(self.groupImage, forKey: "groupImage")
        dict.setValue(self.reportreasons, forKey: "reportreasons")
        dict.setValue(self.postImage, forKey: "postImage")
        dict.setValue(self.groupName, forKey: "groupName")
        dict.setValue(self.profileUserId, forKey: "profileUserId")
        dict.setValue(self.lastUserId, forKey: "lastUserId")
        dict.setValue(self.groupIds, forKey: "groupIds")
        dict.setValue(self.followType, forKey: "followType")
        dict.setValue(self.isGroupPost, forKey: "isGroupPost")
        dict.setValue(self.musicId, forKey: "musicId")
        dict.setValue(self.tags, forKey: "tags")
        dict.setValue(self.postHeight, forKey: "postHeight")
        dict.setValue(self.postWidth, forKey: "postWidth")
        dict.setValue(self.user_id, forKey: "user_id")
        dict.setValue(self.title, forKey: "title")
        dict.setValue(self.isUpdate, forKey: "isUpdate")
        dict.setValue(self.postUserID, forKey: "postUserID")
        dict.setValue(self.token, forKey: "token")
        dict.setValue(self.cardId, forKey: "cardId")
        dict.setValue(self.amount, forKey: "amount")
        dict.setValue(self.expiryYear, forKey: "expiryYear")
        dict.setValue(self.userName, forKey: "userName")
        dict.setValue(self.cvv, forKey: "cvv")
        dict.setValue(self.expiryMonth, forKey: "expiryMonth")
        dict.setValue(self.cardNumber, forKey: "cardNumber")
        dict.setValue(self.cardToken, forKey: "cardToken")
        dict.setValue(self.reportType, forKey: "reportType")
        dict.setValue(self.otherReason, forKey: "otherReason")
        dict.setValue(self.id, forKey: "id")
        dict.setValue(self.isFromSearch, forKey: "isFromSearch")
        dict.setValue(self.videoDuration, forKey: "videoDuration")
        dict.setValue(self.thumbImage, forKey: "thumbImage")
        dict.setValue(self.postVideo, forKey: "postVideo")
        dict.setValue(self.videoDescription, forKey: "videoDescription")
        dict.setValue(self.address, forKey: "address")
        dict.setValue(self.postID, forKey: "postID")
        dict.setValue(self.planID, forKey: "planID")
        dict.setValue(self.purchaseType, forKey: "purchaseType")
        dict.setValue(self.firstName, forKey: "firstName")
        dict.setValue(self.lastName, forKey: "lastName")
        dict.setValue(self.email, forKey: "email")
        dict.setValue(self.password, forKey: "password")
        dict.setValue(self.latitude, forKey: "latitude")
        dict.setValue(self.longitude, forKey: "longitude")
        dict.setValue(self.deviceType, forKey: "deviceType")
        dict.setValue(self.deviceToken, forKey: "deviceToken")
        dict.setValue(self.type, forKey: "type")
        dict.setValue(self.userID, forKey: "userID")
        dict.setValue(self.lat, forKey: "lat")
        dict.setValue(self.log, forKey: "log")
        dict.setValue(self.hobbiesID, forKey: "hobbiesID")
        dict.setValue(self.otherUserID, forKey: "otherUserID")
        dict.setValue(self.reportedBy, forKey: "reportedBy")
        dict.setValue(self.reportedId, forKey: "reportedId")
        dict.setValue(self.reasonId, forKey: "reasonId")
        dict.setValue(self.oldPassword, forKey: "oldPassword")
        dict.setValue(self.newPassword, forKey: "newPassword")
        dict.setValue(self.confirmPassword, forKey: "confirmPassword")
        dict.setValue(self.perPage, forKey: "perPage")
        dict.setValue(self.pageNo, forKey: "pageNo")
        dict.setValue(self.search, forKey: "search")
        dict.setValue(self.senderID, forKey: "senderID")
        dict.setValue(self.planName, forKey: "planName")
        dict.setValue(self.planPrice, forKey: "planPrice")
        dict.setValue(self.planDuration, forKey: "planDuration")
        dict.setValue(self.expireDate, forKey: "expireDate")
        dict.setValue(self.roomID, forKey: "roomID")
        dict.setValue(self.message, forKey: "message")
        dict.setValue(self.receiverID, forKey: "receiverID")
        dict.setValue(self.gender, forKey: "gender")
        dict.setValue(self.dob, forKey: "dob")
        dict.setValue(self.city, forKey: "city")
        dict.setValue(self.hobbies, forKey: "hobbies")
        dict.setValue(self.ethnicity, forKey: "ethnicity")
        dict.setValue(self.profileImage, forKey: "profileImage")
        dict.setValue(self.age, forKey: "age")
        dict.setValue(self.location, forKey: "location")
        dict.setValue(self.description, forKey: "description")
        return dict
    }
}
