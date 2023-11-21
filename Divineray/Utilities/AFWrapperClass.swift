//
//  AFWrapperClass.swift
//  SetUpNewProject
//
//  Created by dr mac on 09/01/23.
//

import Foundation
import UIKit
import Alamofire
import SVProgressHUD
//import NVActivityIndicatorView

class AFWrapperClass{
    
    static let sharedInstance = AFWrapperClass()
    func requestPostWithMultiFormData(_ strURL : String, params : [String : Any]?, headers : HTTPHeaders?, success:@escaping (NSDictionary) -> Void, failure:@escaping (NSError) -> Void){
        print(params,"Param ====>")
        print(strURL,"URL ====>")
        print(headers,"Token====>")
        AF.request(strURL, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let JSON = value as? [String: Any] {
                    success(JSON as NSDictionary)
                }
            case .failure(let error):
                let error : NSError = error as NSError
                failure(error)
            }
        }
    }
    
    func requestPOSTSURL(_ strURL : String, params : [String : Any]?, headers : HTTPHeaders?, success:@escaping (NSDictionary) -> Void, failure:@escaping (NSError) -> Void){
        print(params,"Param ====>")
        print(strURL,"URL ====>")
        print(AppDefaults.token,"token ====>")
        print(headers)

        AF.request(strURL, method: .post, parameters: params, encoding: JSONEncoding.prettyPrinted, headers: headers)
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    if let JSON = value as? [String: Any] {
                        success(JSON as NSDictionary)
                    }
                    
                case .failure(let error):
                    let error : NSError = error as NSError
                    failure(error)
                }
            }
    }
    
    func googleApi(locationCodinate : [Double],type:String,nextPageToken:String?, success:@escaping (NSDictionary?,String?) -> Void){
//        var url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(String(describing: locationCodinate.first ?? 0.0)),\(String(describing: locationCodinate.last ?? 0.0))&keyword=\(type)&radius=1000000&types=restaurant&fields=geometry,name,place_id,type,vicinity&key=AIzaSyDhfc70KyVWFc4F72UkXMKAsh0Qa0uTxmo"
//        url = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
//        print(url)
//        AF.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil)
//            .responseJSON { (response) in
//                switch response.result {
//                case .success(let value):
//                    if let JSON = value as? [String: Any] {
//                        success(JSON as NSDictionary, nil)
//                    }
//
//                case .failure(let error):
//                    let error : NSError = error as NSError
//                    success(nil, error.description)
//                }
//            }
    }
    
//    func googleFindPlaceApi(type:String, success:@escaping (NSDictionary?,String?) -> Void){
//        var url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=\(type)&inputtype=textquery&type=restaurant,cafe,food,bar,bakery,night_club&fields=place_id,formatted_address,name,geometry,type,photo&key=AIzaSyDhfc70KyVWFc4F72UkXMKAsh0Qa0uTxmo"
//        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//        print(url)
//        AF.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil)
//            .responseJSON { (response) in
//                switch response.result {
//                case .success(let value):
//                    if let JSON = value as? [String: Any] {
//                        success(JSON as NSDictionary, nil)
//                    }
//                    
//                case .failure(let error):
//                    let error : NSError = error as NSError
//                    success(nil, error.description)
//                }
//            }
//    }
    
    func requestUrlEncodedPOSTURL(_ strURL : String, params : [String : Any], success:@escaping (NSDictionary) -> Void, failure:@escaping (NSError) -> Void){
        let urlwithPercentEscapes = strURL.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)
        AF.request(urlwithPercentEscapes!, method: .post, parameters: params, encoding: URLEncoding.default, headers: ["Content-Type":"application/x-www-form-urlencoded"])
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    if let JSON = value as? [String: Any] {
                        if response.response?.statusCode == 200{
                            success(JSON as NSDictionary)
                        }else if response.response?.statusCode == 400{
                            let error : NSError = NSError(domain: "invalid user details", code: 400, userInfo: [:])
                            failure(error)
                        }
                    }
                case .failure(let error):
                    let error : NSError = error as NSError
                    failure(error)
                }
            }
    }
    
    func requestGETURL(_ strURL: String, params : [String : Any]?,headers : HTTPHeaders?,  success:@escaping (AnyObject) -> Void, failure:@escaping (NSError) -> Void) {
        print(AppDefaults.token,"token ====>")
        print(strURL,"URL ====>")

        let urlwithPercentEscapes = strURL.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)
        AF.request(urlwithPercentEscapes!, method: .get, parameters: nil, encoding: JSONEncoding.default,headers: ["authtoken":AppDefaults.token ?? ""])
        
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    if let JSON = value as? Any {
                        success(JSON as AnyObject)
                        print(JSON)
                    }
                case .failure(let error):
                    let error : NSError = error as NSError
                    failure(error)
                }
            }
    }
    
    
    func upload(strURL: String, params: [String: Any],completion:@escaping([String:Any]?,String?) -> Void) {
        print(params,"Param ====>")
        print(strURL,"URL ====>")
        print(ApplicationStates.getTokenID(),"token ====>")

        let headers: HTTPHeaders = [
            "Token":ApplicationStates.getTokenID()
        ]
        AF.upload(multipartFormData: { multiPart in
            for (key, value) in params {
                if let temp = value as? String {
                    multiPart.append(temp.data(using: .utf8)!, withName: key)
                }
                if let temp = value as? NSArray {
                    var index  = 1
                    for i in 0..<temp.count{
                        multiPart.append(temp[i] as! Data, withName: "\(key)[\(index)]", fileName: "\(UUID()).png", mimeType: "image/png")
                        index += 1
                    }

                }
                if let image = value as? Data{
                    multiPart.append(image, withName: key, fileName: "\(UUID()).png", mimeType: "image/png")
                }
            }
            print(multiPart)
        } ,to: strURL, usingThreshold: UInt64.init(), method: .post, headers: headers)
        .uploadProgress(queue: .main, closure: { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
            SVProgressHUD.show()
        })
        .responseJSON(completionHandler: { data in
            SVProgressHUD.dismiss()
            switch data.result {
            case .success(let value):
                if let JSON = value as? [String:Any] {
                    completion(JSON,nil)
                }
            case .failure(let error):
                completion(nil,"Please check your internet")
            }
        })
    }
    
    
//    func addReview(strURL: String, params: [String: Any],completion:@escaping([String:Any]?,String?) -> Void) {
//        print(params,"Param ====>")
//        print(strURL,"URL ====>")
//        print(AppDefaults.token,"token ====>")
//
//        let headers: HTTPHeaders = [
//            "Content-type": "application/form-data",
//            "Token":AppDefaults.token ?? ""
//        ]
//        AF.upload(multipartFormData: { multiPart in
//            for (key, value) in params {
//                if let temp = value as? String {
//                    multiPart.append(temp.data(using: .utf8)!, withName: key)
//                }
//                if let temp = value as? [[String:Any]] {
//                    if key == "tag_baddies"{
//                        for i in 0..<temp.count{
//                            let id = temp[i]["user_id"] as! String
//                            multiPart.append( "\(id)".data(using: .utf8)!, withName: "tag_baddies[\(i)]")
//                        }
//                    }
//                }
//                if let uploadImages = value as? NSArray {
//                    if key == "uploads"{
//                        for i in 0..<uploadImages.count{
//                            multiPart.append(uploadImages[i] as! Data, withName: "uploads[\(i + 1)]", fileName: "\(UUID()).png", mimeType: "image/png")
//                        }
//                    }
//                    if key == "deleted_images"{
//                        if uploadImages.count > 0{
//                            for i in 0..<uploadImages.count{
//                                multiPart.append( "\(uploadImages[i])".data(using: .utf8)!, withName: "deleted_images[\(i)]")
//                            }
//                        }
//                        else{
//                            multiPart.append( "".data(using: .utf8)!, withName: "deleted_images[]")
//                        }
//                    }
//                }
//            }
//            print(multiPart)
//        } ,to: strURL, usingThreshold: UInt64.init(), method: .post, headers: headers)
//        .uploadProgress(queue: .main, closure: { progress in
//            print("Upload Progress: \(progress.fractionCompleted)")
//            SVProgressHUD.show()
//        })
//        .responseJSON(completionHandler: { data in
//            SVProgressHUD.dismiss()
//            switch data.result {
//            case .success(let value):
//                if let JSON = value as? [String:Any] {
//                    completion(JSON,nil)
//                }
//            case .failure(let error):
//                completion(nil,error.localizedDescription)
//            }
//        })
//    }
    
    
    func svprogressHudShow(view:UIViewController?) -> Void{
        SVProgressHUD.setBackgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))
        SVProgressHUD.show()
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.native)
        SVProgressHUD.setForegroundColor(.white)
        SVProgressHUD.setRingThickness(4)
    }
    
    func svprogressHudDismiss(view:UIViewController) -> Void{
        SVProgressHUD.dismiss();
    }
    
}

extension UIViewController {
    
    func isValidUsername(testStr:String) -> Bool{
        let emailRegEx = ".*[^A-Za-z].*"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidEmail(testStr:String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
}

