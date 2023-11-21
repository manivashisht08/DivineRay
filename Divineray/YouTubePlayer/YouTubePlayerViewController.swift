//
//  YouTubePlayerViewController.swift
//  Divineray
//
//  Created by Aravind Kumar on 04/11/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import YouTubePlayer

class YouTubePlayerViewController: UIViewController {
    var youtybeUrl  = ""
    var videoPlayerIn : YouTubePlayerView!
    @IBOutlet weak var videoPlayer: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        videoPlayer.isHidden = false
        // Do any additional setup after loading the view.
        self.videoPlayerIn = YouTubePlayerView(frame: self.videoPlayer.frame)
        // Load video from YouTube URL
        let myVideoURL = NSURL(string: youtybeUrl)
        self.videoPlayerIn.loadVideoURL(myVideoURL! as URL)
        self.videoPlayer.addSubview(self.videoPlayerIn)
        
    }

    @IBAction func backAction(_ sender: Any) {
        if self.videoPlayerIn != nil{
            self.videoPlayerIn.stop()
        }
        self.navigationController?.popViewController(animated: true)
    }
}
