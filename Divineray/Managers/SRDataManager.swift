//
//  DataManager.swift
//  Divineray
//
//  Created by     on 08/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import Alamofire
import Foundation


public typealias Parameters = [String: Any]
typealias JSONCompletionHandler = (NetworkResponse) -> Void
typealias JSONDictionary = [String:Any]
typealias CompletionHandler = (_ items:[[String:Any]]) -> Void

enum NetworkResponse {
    case success(AnyObject?)
    case failure(String)
}
@available(iOS 14.0, *)
class SRDataManager: NSObject {
    
    private static let _sharedInstance = SRDataManager()
    public class func sharedInstance() -> SRDataManager {
        return _sharedInstance
    }
    private override init () {
        super.init()
    }
}

@available(iOS 14.0, *)
@available(iOS 14.0, *)
@available(iOS 14.0, *)
@available(iOS 14.0, *)
@available(iOS 14.0, *)
extension SRDataManager {
    
    public func performMultiFormVideoRequest(requestURL: String, postData: Parameters, imagesData:Data, videoPathUrl:URL,completionHandler: @escaping JSONCompletionHandler) {
        let headers:HTTPHeaders = ["Token": ApplicationStates.getTokenID()]
        
        AF.upload(multipartFormData: { multipartFormData in
            if !imagesData.isEmpty {
                multipartFormData.append(imagesData, withName: "postImage", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
            }
            multipartFormData.append(videoPathUrl, withName: "postVideo", fileName: "\(Date().timeIntervalSince1970).mp4", mimeType: "mp4")
            for (key, value) in postData{
                multipartFormData.append(Data((value as! String).utf8) , withName: key)
            }
        }, to: requestURL,headers: headers).uploadProgress { progress in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "VideoUploadPercntage"), object: progress.fractionCompleted)
            
        }.responseData {response in
            switch(response.result){
            case let .success(value):
                let result =  try? JSONSerialization.jsonObject(with: value, options: []) as? [String: Any]
                
                print(result,"result")
                if result != nil {
                    if let status = result!["status"] as? Int {
                        if status == 3 {
                            let appDelegate =  UIApplication.shared.delegate as! AppDelegate
                            appDelegate.logoutSessionSucess()
                            completionHandler(NetworkResponse.failure(("Session expired, Please login again")))
                            return
                        }
                    }
                }
                
                completionHandler(NetworkResponse.success(value as AnyObject))
            case .failure(let error):
                completionHandler(NetworkResponse.failure(error.localizedDescription))
            }
        }
    }
    
    public func performMultiFormRequest(requestURL: String, postData:Parameters, imagesData:Data, completionHandler: @escaping JSONCompletionHandler) {
        let headers:HTTPHeaders = ["Token": ApplicationStates.getTokenID()]
        
        AF.upload(multipartFormData: { multipartFormData in
            if !imagesData.isEmpty {
                multipartFormData.append(imagesData, withName: "postImage", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
            }
            
            if let theJSONData = try? JSONSerialization.data(
                withJSONObject: postData,
                options: []) {
                multipartFormData.append(theJSONData , withName: "data")
            }
        },to: requestURL,headers: headers).responseData {response in
            switch(response.result){
            case let .success(value):
                let result =  try? JSONSerialization.jsonObject(with: value, options: []) as? [String: Any]
                print(result,"result")
                
                if result != nil {
                    if let status = result!["status"] as? Int {
                        if status == 3 {
                            let appDelegate =  UIApplication.shared.delegate as! AppDelegate
                            appDelegate.logoutSessionSucess()
                            completionHandler(NetworkResponse.failure(("Session expired, Please login again")))
                            return
                        }
                    }
                }
                
                
                completionHandler(NetworkResponse.success(value as AnyObject))
            case .failure(let error):
                completionHandler(NetworkResponse.failure(error.localizedDescription))
            }
        }
        
    }
    
    
    public func performNetworkPostServiceRequest(requestURL: String, postData:Parameters,  completionHandler: @escaping JSONCompletionHandler) {
        let headers:HTTPHeaders = ["Token": ApplicationStates.getTokenID()]
        print("API name is: \(requestURL)")
        print("Params are : \(postData)")
        print("headers ******** \(headers)")
      
        AF.request(requestURL, method: .post, parameters: postData, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200..<300).responseJSON(completionHandler: { response in
            switch(response.result){
            case let .success(value):
                if let result:[String:Any] = value as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 3 {
                            let appDelegate =  UIApplication.shared.delegate as! AppDelegate
                            appDelegate.logoutSessionSucess()
                            completionHandler(NetworkResponse.failure(("Session expired, Please login again")))
                            return
                        }
                    }
                }
                completionHandler(NetworkResponse.success(value as AnyObject))
            case .failure(let error):
                completionHandler(NetworkResponse.failure(error.localizedDescription))
            }
        })
    }
    
    
    public func createLiveStreamToken(requestURL: String,  completionHandler: @escaping JSONCompletionHandler) {
        let headers:HTTPHeaders = ["Token": ApplicationStates.getTokenID()]
        print("API name is: \(requestURL)")
        print("headers ******** \(headers)")
        AF.request(requestURL, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200..<300).responseJSON(completionHandler: { response in
            switch(response.result){
            case let .success(value):
                if let result:[String:Any] = value as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 3 {
                            let appDelegate =  UIApplication.shared.delegate as! AppDelegate
                            appDelegate.logoutSessionSucess()
                            completionHandler(NetworkResponse.failure(("Session expired, Please login again")))
                            return
                        }
                    }
                }
                completionHandler(NetworkResponse.success(value as AnyObject))
            case .failure(let error):
                completionHandler(NetworkResponse.failure(error.localizedDescription))
            }
        })
    }
    
    
    public func performNetworkGETServiceRequest(requestURL: String, getData:Parameters,  completionHandler: @escaping JSONCompletionHandler) {
        
        AF.request(requestURL, method: .get, parameters: getData, encoding: JSONEncoding.default, headers: ["Token":ApplicationStates.getTokenID()]).validate(statusCode: 200..<300).responseJSON(completionHandler: { response in
            
            
            
            switch(response.result){
                
            case let .success(value):
                if let result:[String:Any] = value as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 3 {
                            let appDelegate =  UIApplication.shared.delegate as! AppDelegate
                            appDelegate.logoutSessionSucess()
                            completionHandler(NetworkResponse.failure(("Session expired, Please login again")))
                            return
                        }
                    }
                }
                
                completionHandler(NetworkResponse.success(value as AnyObject))
            case .failure(let error):
                completionHandler(NetworkResponse.failure(error.localizedDescription))
            }
        })
    }
    
}


