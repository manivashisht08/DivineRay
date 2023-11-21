//
//  UserApiModel.swift
//  SetUpNewProject
//
//  Created by dr mac on 09/01/23.
//

import Foundation
import Alamofire
import SVProgressHUD

class UserApiModel {
    static let instance  = UserApiModel()
    func userLogin(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.Login, params: (model.convertDict() as? [String:Any]), headers: nil, success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil,error.debugDescription)
        })
    }
    
    func userSignUp(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.SignUp, params: (model.convertDict() as! [String:Any]), headers: nil, success: { (response) in
//            print("parameters===>>>",model.covertDict())
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
   
//    func editProfile(model:UserModel,completion: @escaping (NSDictionary?,String?) -> Void){
//
//        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.editProfile, params: (model.convertDict() as! [String:Any]), headers: ["authtoken":AppDefaults.token ?? ""], success: { (response) in
//            print(response)
//            print(AppDefaults.token ?? "","*********&")
//            completion(response,nil)
//        }, failure: { (error) in
//            print(error.debugDescription)
//            completion(nil, error.debugDescription)
//        })
//    }
    
    func userCompleteBoarding(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.upload(strURL: Constantt.onBoarding, params: (model.convertDict() as! [String:Any])) { (response, error) in
            print("parameters ===== >>> ", model)
                        if let dict = response{
                            print("dict ===== >>> ", dict)
                            completion(response as NSDictionary?,nil)
                        }
                        else{
                            completion(nil,error)
                        }
        }
    }
    
//    func userAddRemoveImage(model:UploadImgModel,completion: @escaping (NSDictionary?,String?) -> Void){
//
//        AFWrapperClass.sharedInstance.upload(strURL: Constantt.addRemoveImg, params: (model.convertDict() as! [String:Any])) { (response, error) in
//            print("parameters ===== >>> ", model)
//                        if let dict = response{
//                            print("dict ===== >>> ", dict)
//                            completion(response as NSDictionary?,nil)
//                        }
//                        else{
//                            completion(nil,error)
//                        }
//        }
//    }
    func userForgotPassword(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.ForgotPassword, params: (model.convertDict() as! [String:Any]), headers: nil, success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    
    func createRoom(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.createRoom, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    func boostProfile(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){

        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.boostProfile, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    func shareHomePost(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){

        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.shareHomePost, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func allReportReason(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){

        AFWrapperClass.sharedInstance.requestPOSTSURL(API.allReportReason, params: (model.convertDict() as! [String:Any]), headers: ["Token":ApplicationStates.getTokenID()], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    func ReportReasonSubmit(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){

        AFWrapperClass.sharedInstance.requestPOSTSURL(API.getAddReportAbuseURL, params: (model.convertDict() as! [String:Any]), headers: ["Token":ApplicationStates.getTokenID()], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    func blockUser(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){

        AFWrapperClass.sharedInstance.requestPOSTSURL(API.blockUserURL, params: (model.convertDict() as! [String:Any]), headers: ["Token":ApplicationStates.getTokenID()], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func getMyPostListing(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){

        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.getMyPostListing, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func addCard(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){

        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.addCard, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func deletePostId(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){

        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.deletePostID, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? "","Content-Type":"application/json"], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func friendUnfriend(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){

        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.friendUnfriend, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func chatActivity(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){

        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.myActivity, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func sharePost(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){

        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.sharePost, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    func updateUserSession(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){

        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.updateUserSession, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func notificationListing(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){

        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.notificationListing, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    func cardListing(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){

        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.cardListing, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func acceptRejectRequest(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){

        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.acceptRejectRequest, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func likeDislikePost(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){

        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.likeDislike, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func sendMessage(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.sendMessage, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func getSubscription(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.getSubscription, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func updateSubscription(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.updateSubscription, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func checkPurchase(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.checkPurchase, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    
    func getAllChatMessage(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.chatMessageDetail, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func getFollowUser(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(API.GetFollowUsersURL, params: (model.convertDict() as! [String:Any]), headers: ["Token":ApplicationStates.getTokenID()], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func userBlockListing(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.userBlockListing, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func reportUser(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.reportUser, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func userAddReport(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.AddReport, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func userEthinicity(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.Ethnicity, params:  (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? "","Content-Type":"application/json"],  success: { (response) in
            print(response)
            print(AppDefaults.token ?? "" ,"tokkn")
            completion((response as! NSDictionary),nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func chatListing(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.chatListing, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""],  success: { (response) in
            print(response)
            completion((response as! NSDictionary),nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    func likeListing(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.likeListing, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""],  success: { (response) in
            print(response)
            completion((response as! NSDictionary),nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    func CreateGroupChat(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        AFWrapperClass.sharedInstance.upload(strURL: API.createGroupChatURL, params: (model.convertDict() as! [String:Any])) { (response, error) in
            print("parameters ===== >>> ", model)
            if let dict = response{
                print("dict ===== >>> ", dict)
                completion(response as NSDictionary?,nil)
            }
            else{
                completion(nil,error)
            }
        }
    }
    func userHobbies(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.Hobbies, params:  (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""],  success: { (response) in
            print(response)
            completion((response as! NSDictionary),nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func home(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.home, params:  (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""],  success: { (response) in
            print(response)
            completion((response as! NSDictionary),nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    func getProfile(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.getProfile, params:  (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""],  success: { (response) in
            
            print(response)
            completion((response as! NSDictionary),nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    func removeRecentSearch(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.removeRecentSearch, params:  (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""],  success: { (response) in
            
            print(response)
            completion((response as! NSDictionary),nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    func groupListing(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(API.allGroupListURL, params:  (model.convertDict() as! [String:Any]), headers: ["Token":ApplicationStates.getTokenID()],  success: { (response) in
            
            print(response)
            completion((response as! NSDictionary),nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }

    
    func likeUnlike(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.likeUnlike, params:  (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""],  success: { (response) in
            print(response)
            completion((response as! NSDictionary),nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    func UndolikeUnlike(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.undolikeUnlike, params:  (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""],  success: { (response) in
            print(response)
            completion((response as! NSDictionary),nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    
    
//    func userProfile(model:UserModel,completion: @escaping (NSDictionary?,String?) -> Void){
//
//        AFWrapperClass.sharedInstance.requestGETURL(Constantt.ProfileDetail, params: nil, headers: ["Token":AppDefaults.token ?? ""],  success: { (response) in
//            print(response)
//
//            completion((response as! NSDictionary),nil)
//        }, failure: { (error) in
//            print(error.debugDescription)
//            completion(nil, error.debugDescription)
//        })
//    }
//    func favourite(model:UserModel,completion: @escaping (NSDictionary?,String?) -> Void){
//
//        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.favourite, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
//            print(response)
//            completion(response,nil)
//        }, failure: { (error) in
//            print(error.debugDescription)
//            completion(nil, error.debugDescription)
//        })
//    }
    
    func addEditPost(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.upload(strURL: API.addUploadPostURL, params: (model.convertDict() as! [String:Any])) { (response, error) in
            print("parameters ===== >>> ", model)
                        if let dict = response{
                            print("dict ===== >>> ", dict)
                            completion(response as NSDictionary?,nil)
                        }
                        else{
                            completion(nil,error)
                        }
        }

    }
    
//    func deleteChat(model:UserModel,completion: @escaping (NSDictionary?,String?) -> Void){
//
//        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.deletechat, params: model.convertDict() as? [String:Any], headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
//            print(response)
//            completion(response,nil)
//        }, failure: { (error) in
//            print(error.debugDescription)
//            completion(nil, error.debugDescription)
//        })
//    }
//
//
//    func reportUser(model:UserModel,completion: @escaping (NSDictionary?,String?) -> Void){
//
//        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.reportUser, params: model.convertDict() as? [String:Any], headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
//            print(response)
//            completion(response,nil)
//        }, failure: { (error) in
//            print(error.debugDescription)
//            completion(nil, error.debugDescription)
//        })
//    }
    
//    func blockUser(model:UserModel,completion: @escaping (NSDictionary?,String?) -> Void){
//
//        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.blockUser, params: model.convertDict() as? [String:Any], headers: ["authtoken":AppDefaults.token ?? ""], success: { (response) in
//            print(response)
//            completion(response,nil)
//        }, failure: { (error) in
//            print(error.debugDescription)
//            completion(nil, error.debugDescription)
//        })
//    }
    
//    func createRoom(model:UserModel,completion: @escaping (NSDictionary?,String?) -> Void){
//        
//        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.createRoom, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
//            print(response)
//            completion(response,nil)
//        }, failure: { (error) in
//            print(error.debugDescription)
//            completion(nil, error.debugDescription)
//        })
//    }
    
 
//    func chatDetailMsg(model:UserModel,completion: @escaping (NSDictionary?,String?) -> Void){
//
//        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.chatMessageDetail, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
//            print(response)
//            completion(response,nil)
//        }, failure: { (error) in
//            print(error.debugDescription)
//            completion(nil, error.debugDescription)
//        })
//    }
    
    func updateChatStatus(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.updateChatStatus, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
//    func sendMessage(model:UserModel,completion: @escaping (NSDictionary?,String?) -> Void){
//
//        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.sendMessage, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
//            print(response)
//            completion(response,nil)
//        }, failure: { (error) in
//            print(error.debugDescription)
//            completion(nil, error.debugDescription)
//        })
//    }
    
//    func notInterested(model:UserModel,completion: @escaping (NSDictionary?,String?) -> Void){
//
//        AFWrapperClass.sharedInstance.requestPostWithMultiFormData(Constantt.notInterested, params: (model.convertDict() as? [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
//            print(response)
//            completion(response,nil)
//        }, failure: { (error) in
//            print(error.debugDescription)
//            completion(nil, error.debugDescription)
//        })
//    }

    
    
//    func home(model:UserModel,completion: @escaping (NSDictionary?,String?) -> Void){
//
//        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.home, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: { (response) in
//            print(AppDefaults.token ?? "","#$%#@$%#$@#@$#$#$#$@")
//            print(response)
//            completion(response,nil)
//        }, failure: { (error) in
//            print(error.debugDescription)
//            completion(nil, error.debugDescription)
//        })
//    }
//    func userProfile(model: [String:Any],completion: @escaping ([String:Any]?,String?) -> Void){
//        AFWrapperClass.sharedInstance.upload(strURL: Constant.EditProfile, params: model, completion: { (response,error) in
//            if let dict = response{
//                print("\(dict)")
//                completion(response,nil)
//            }
//            else{
//                completion(nil,error)
//            }
//        })
//    }
    func ChangePassword(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.ChangePassword, params: (model.convertDict() as! [String:Any]), headers:  ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
    func editProfile(model:SignupModel,completion: @escaping (NSDictionary?,String?) -> Void){
        
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.editProfile, params: (model.convertDict() as! [String:Any]), headers:  ["Token":AppDefaults.token ?? ""], success: { (response) in
            print(response)
            completion(response,nil)
        }, failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
        })
    }
//    func userProfileDetail(completion: @escaping (NSDictionary?,String?) -> Void){
////    func userProfileDetail(model: LoginModel, completion: @escaping(NSDictionary?,String?) -> Void){
//        AFWrapperClass.sharedInstance.requestPOSTSURL(Constant.ViewProfile, params: nil, success: { (response) in
//            print(response)
//            completion(response,nil)
//        }, failure: { (error) in
//            print(error.debugDescription)
//            completion(nil, error.debugDescription)
//        })
//    }
    func Logout(model:SignupModel, completion: @escaping (NSDictionary?,String?) -> Void){
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.Logout, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? "","Content-Type":"application/json"], success: {(response) in
            print(response)
            completion(response, nil)
        }  , failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
            
        })
    }
    
    func deleteAccount(model:SignupModel, completion: @escaping (NSDictionary?,String?) -> Void){
        AFWrapperClass.sharedInstance.requestPOSTSURL(Constantt.deleteAccount, params: (model.convertDict() as! [String:Any]), headers: ["Token":AppDefaults.token ?? ""], success: {(response) in
            print(response)
            completion(response, nil)
        }  , failure: { (error) in
            print(error.debugDescription)
            completion(nil, error.debugDescription)
            
        })
    }
}
