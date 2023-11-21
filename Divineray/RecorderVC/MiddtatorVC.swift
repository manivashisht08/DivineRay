//
//  MiddtatorVC.swift
//  Divineray
//
//  Created by     on 21/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
@available(iOS 14.0, *)
@objc protocol MiddtatorVCProtocol: AnyObject {
    func getLiveEventsAndLiveUsers(jsonLiveEvents: (AnyObject?), dictLiveEventsFail:[String:String], isSuccessLiveEvents:Bool,  jsonLiveUsers: (AnyObject?), isSuccessLiveUsers:Bool,dictLiveUsersFail:[String:String])
}

@available(iOS 14.0, *)
@objc class MiddtatorVC: NSObject {
    
    @objc var postData:Parameters!
    @objc var imagesData:Data!
    @objc var videoPathUrl:URL!
    @objc let group = DispatchGroup()
    var jsonLiveEvents: (AnyObject?)
    var strLiveEventsFail = ""
    var jsonLiveUsers: (AnyObject?)
    var strLiveUsersFail = ""
    var isSuccessLiveEvents = false
    var isSuccessLiveUsers = false
    @objc weak var middtatorVCDelegate: MiddtatorVCProtocol? = nil
    
    @objc func upload() {
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID()
        ]
        postData.append(anotherDict: params);
        
        SRDataManager.sharedInstance().performMultiFormVideoRequest(requestURL: API.uploadVideoURL, postData: self.postData, imagesData: self.imagesData, videoPathUrl: self.videoPathUrl) { (result) -> Void in
            switch (result) {
            case .success(let json):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VideoUploadStatus"), object: json)
                break
            case .failure( _):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VideoUploadStatus"), object: nil)
                break;
            }
        }
    }
    @objc  func getHomeDashboard() {
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID()
        ]
        postData.append(anotherDict: params);
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAllVideosURL, postData: postData){ (result) -> Void in            
            switch (result) {
            case .success(let json):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DashBoardDataFetch"), object: json)
                break
            case .failure(let error):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DashBoardDataFetch"), object: ["error":error])
                break;
            }
        }
    }
    
    @objc  func getHomeDashboardLiveEvents() {
        self.group.enter()
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID()
        ]
        postData.append(anotherDict: params);
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAllStreamVideo, postData: postData){ (result) -> Void in
            switch (result) {
            case .success(let json):
                print("getHomeDashboardLiveEvents")
                self.jsonLiveEvents = json
                self.isSuccessLiveEvents = true
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DashBoardLiveEventsDataFetch"), object: json)
                DispatchQueue.main.async {
                    self.group.leave()
                }
                
                break
            case .failure(let error):
                self.strLiveEventsFail = error
                self.isSuccessLiveEvents = false
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DashBoardLiveEventsDataFetch"), object: ["error":error])
                DispatchQueue.main.async {
                    self.group.leave()
                }
                break;
            }
        }
    }
    
    @objc  func getLiveUsers() {
        self.group.enter()
        let params: [String:Any] = [
            "user_id": ApplicationStates.getUserID()
        ]
        print("params are *** \(API.getLiveUsers)\n\(params)")
        postData.removeAll()
        postData.append(anotherDict: params);
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getLiveUsers, postData: postData){ (result) -> Void in
            switch (result) {
            case .success(let json):
                print("getLiveUsers")
                self.jsonLiveUsers = json
                self.isSuccessLiveUsers = true
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DashBoardLiveUsersDataFetch"), object: json)
                DispatchQueue.main.async {
                    self.group.leave()
                }
                break
            case .failure(let error):
                self.strLiveUsersFail = error
                self.isSuccessLiveUsers = false
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DashBoardLiveUsersDataFetch"), object: ["error":error])
                DispatchQueue.main.async {
                    self.group.leave()
                }
                break;
            }
        }
    }
    
    @objc func setUpDispatchGroup() {
        self.group.notify(queue: .main) {
            self.middtatorVCDelegate?.getLiveEventsAndLiveUsers(jsonLiveEvents: self.jsonLiveEvents, dictLiveEventsFail: ["error":self.strLiveEventsFail], isSuccessLiveEvents: self.isSuccessLiveEvents, jsonLiveUsers: self.jsonLiveUsers, isSuccessLiveUsers: self.isSuccessLiveUsers, dictLiveUsersFail: ["error":self.strLiveUsersFail])
        }
    }
    
    @objc  func getLikeService() {
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID()
        ]
        postData.append(anotherDict: params);
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.likeViewUpdateURL, postData: postData){ (result) -> Void in
            switch (result) {
            case .success(let json):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LikeDataFetch"), object: json)
                break
            case .failure(let error):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LikeDataFetch"), object: ["error":error])
                break;
            }
        }
    }
    
    @objc  func sentCommentService() {
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID()
        ]
        postData.append(anotherDict: params);
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.addUpdateCommentURL, postData: postData){ (result) -> Void in
            switch (result) {
            case .success(let json):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SentCommentAction"), object: json)
                break
            case .failure(let error):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SentCommentAction"), object: ["error":error])
                break;
            }
        }
    }
    @objc  func listCommentService() {
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID()
        ]
        postData.append(anotherDict: params);
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAllCommentsURL, postData: postData){ (result) -> Void in
            switch (result) {
            case .success(let json):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ListCommentAction"), object: json)
                break
            case .failure(let error):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ListCommentAction"), object: ["error":error])
                break;
            }
        }
    }
    
    @objc  func getAudioListService() {
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID()
        ]
        postData.append(anotherDict: params);
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAllMusicURL, postData: postData){ (result) -> Void in
            switch (result) {
            case .success(let json):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AudioDataFetch"), object: json)
                break
            case .failure(let error):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AudioDataFetch"), object: ["error":error])
                break;
            }
        }
    }
    @objc func downloadVideoFromUrl(){
        if let url = self.postData["url"] as? String {
            AF.request(url).downloadProgress(closure : { (progress) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VideoDownloadPercntage"), object: progress.fractionCompleted)
            }).responseData{ (response) in
                
                switch response.result {
                case .success(let data):
                    
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let videoURL = documentsURL.appendingPathComponent("downloadvideo.mp4")
                    do {
                        try data.write(to: videoURL)
                    } catch {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VideoDownloadStatus"), object: nil)
                    }
                    let dict = NSMutableDictionary.init()
                    
                    dict .setValue(videoURL, forKey: "videoURL")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VideoDownloadStatus"), object: dict)
                    
                case .failure(let error):
                    break
                default:
                    break
                }
                
                
                //sent Download Video Url
                
            }
        }
    }
    @objc  func deleteVideoForUser() {
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID()
        ]
        postData.append(anotherDict: params);
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getRemoveVideoURL, postData: postData){ (result) -> Void in
            switch (result) {
            case .success(let json):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DeleteVideoNotifiction"), object: json)
                break
            case .failure(let error):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DeleteVideoNotifiction"), object: ["error":error])
                break;
            }
        }
    }
    
    @objc  func getProfileInfo() {
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID()
        ]
        postData.append(anotherDict: params);
        print("====================")
        print(postData)
        
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getProfileDetailsURL, postData: postData){ (result) -> Void in
            switch (result) {
            case .success(let json):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ProfileDataGet"), object: json)
                break
            case .failure(let error):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ProfileDataGet"), object: ["error":error])
                break;
            }
        }
    }
}
