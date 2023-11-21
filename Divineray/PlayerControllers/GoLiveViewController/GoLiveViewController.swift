//
//  GoLiveViewController.swift
//  Divineray
//
//  Created by Tejas Dattani on 09/01/22.
//  Copyright © 2022 Dharmani Apps. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import AgoraRtcKit
import SVProgressHUD
@available(iOS 14.0, *)
class GoLiveViewController: UIViewController {
    
    @IBOutlet var IBBtnGoLive:UIButton!
    @IBOutlet var IBBtnCamera:UIButton!
    @IBOutlet var IBBtnClose:UIButton!
    @IBOutlet weak var previewView: AGEVideoContainer!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    var agoraKit: AgoraRtcEngineKit = {
        let engine = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: nil)
        
        return engine
    }()
    
    private var videoSessions = [VideoSession]() {
        didSet {
            self.updateBroadcastersView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.agoraKit.enableAudio()
        self.agoraKit.startPreview()
        self.agoraKit.setClientRole(.broadcaster)
        self.addLocalSession()
        self.view.bringSubviewToFront(self.IBBtnCamera)
    }
    
    func addLocalSession() {
        let localSession = VideoSession.localSession()
        localSession.canvas.renderMode = .hidden
        localSession.canvas.mirrorMode = .auto
        self.videoSessions.append(localSession)
        self.agoraKit.setupLocalVideo(localSession.canvas)
    }
    
    @IBAction func IBBtnCloseTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func IBBtnSwitchCamera(_ sender: Any) {
        self.agoraKit.switchCamera()
        self.view.bringSubviewToFront(self.IBBtnCamera)
    }
    
    func updateBroadcastersView() {
        
        let itemWidth  = CGFloat(1.0) / CGFloat(1)
        let itemHeight = CGFloat(1.0) / CGFloat(1)
        let itemSize   = CGSize(width: itemWidth, height: itemHeight)
        print("layout frame is 0 **** \(itemSize)  ****  \(self.videoSessions.count)")
        
        let layout  = AGEVideoLayout(level: 0).itemSize(.scale(itemSize))
        
        self.previewView
            .listCount { [unowned self] (_) -> Int in
                return self.videoSessions.count
            }.listItem { [unowned self] (index) -> UIView in
                return self.videoSessions[index.item].hostingView
            }
        self.previewView.setLayouts([layout], animated: true)
        self.microphonePermission()
    }
    
    
    func microphonePermission(){
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            print("Permission granted")
        case .denied:
            print("Permission denied")
        case .undetermined:
            print("Request permission here")
            AVAudioSession.sharedInstance().requestRecordPermission({ granted in
                // Handle granted
            })
        @unknown default:
            print("Unknown case")
        }
    }
    
    @IBAction func IBBtnGoLiveTapped(_ sender: Any) {
        SVProgressHUD.show()
        
        let params:[String:Any] = [
            "user_id": ApplicationStates.getUserID(),
        ]
        
        print("API called \(API.goingliveV3)\n\(params)")
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.goingliveV2, postData: params) { (result) -> Void in
            SVProgressHUD.dismiss()
            switch (result) {
            case .success(let json):
                
                
                print("json is \(String(describing: json))")
                guard let data = try? JSONSerialization.data(withJSONObject: json as Any) else { return }
                print("data is \(data.count)")
                guard let decoded = try? JSONDecoder().decode(LiveStreamModel.self, from: data) else { return }
                
                let liveStreamingVC : LiveStreamingViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LiveStreamingViewController") as! LiveStreamingViewController
                liveStreamingVC.setViewData(decoded)
                liveStreamingVC.agoraKit = self.agoraKit
                self.navigationController?.pushViewController(liveStreamingVC, animated: true)
                break
                
                
            case .failure(let error):
                print("response is **** \(error)")
                self.showAlertWith(title:API.appName, message:error)
                break;
            }
        }
    }
}

