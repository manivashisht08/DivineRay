//
//  AudioPlayerViewController.swift
//  Divineray
//
//  Created by Aravind Kumar on 06/09/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SwiftAudio
import AVFoundation
import MediaPlayer

class AudioPlayerViewController: UIViewController {
    
    @IBOutlet weak var scrolllbl: ZScrollLabel!
    var audioInformation : NSDictionary!
    var player : AudioPlayer!
    var audioItem : AudioItem!
    let audioSessionController = AudioSessionController.shared
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    private var isScrubbing: Bool = false
    
    private var lastLoadFailed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startPlayer()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func startPlayer() {
        self.player = AudioPlayer()
        
        self.audioItem = DefaultAudioItem(audioUrl: audioInformation["media"] as! String, artist: audioInformation["description"] as? String, title: audioInformation["title"] as? String, albumTitle: audioInformation["description"] as? String, sourceType: .stream, artwork: UIImage(named: "audioBG"))
        try? audioSessionController.set(category: .playback)
        
        try? self.player.load(item: self.audioItem, playWhenReady: true)
        
        self.player.event.stateChange.addListener(self, handleAudioPlayerStateChange)
        self.player.event.secondElapse.addListener(self, handleAudioPlayerSecondElapsed)
        self.player.event.playbackEnd.addListener(self, handleAudioPlayerEnd)
        self.player.event.seek.addListener(self, handleAudioPlayerDidSeek)
        self.player.event.updateDuration.addListener(self, handleAudioPlayerUpdateDuration)
        self.player.event.didRecreateAVPlayer.addListener(self, handleAVPlayerRecreated)
        self.player.event.fail.addListener(self, handlePlayerFailure)
        self.player.remoteCommands = [
            .play,
            .pause
        ]
        updateMetaData()
        handleAudioPlayerStateChange(data: self.player.playerState)
    }
    @IBAction func togglePlay(_ sender: Any) {
        if !self.audioSessionController.audioSessionIsActive {
            try? self.audioSessionController.activateSession()
        }
        if lastLoadFailed, let item = self.player.currentItem {
            lastLoadFailed = false
            errorLabel.isHidden = true
            try? self.player.load(item: item, playWhenReady: true)
        }
        else {
            self.player.togglePlaying()
        }
    }
    @IBAction func startScrubbing(_ sender: UISlider) {
        isScrubbing = true
    }
    
    @IBAction func scrubbing(_ sender: UISlider) {
        self.player.seek(to: Double(slider.value))
    }
    
    @IBAction func scrubbingValueChanged(_ sender: UISlider) {
        let value = Double(slider.value)
        elapsedTimeLabel.text = value.secondsToString()
        remainingTimeLabel.text = (self.player.duration - value).secondsToString()
    }
    
    func updateTimeValues() {
        self.slider.maximumValue = Float(self.player.duration)
        self.slider.setValue(Float(self.player.currentTime), animated: true)
        self.elapsedTimeLabel.text = self.player.currentTime.secondsToString()
        self.remainingTimeLabel.text = (self.player.duration - self.player.currentTime).secondsToString()
    }
    
    func updateMetaData() {
        if let item = self.player.currentItem {
            titleLabel.text = item.getTitle()
            //            artistLabel.text = item.getArtist()
            artistLabel.text = ""
            artistLabel.isHidden = true
            self.scrolllbl.text = item.getArtist()
            //            self.scrolllbl.isScrolling = true
            self.scrolllbl.textColor = UIColor.init(white:1.0, alpha: 0.7)
            self.scrolllbl.startScrollAnimation()
            if let postImage = audioInformation["thumbImage"] as? String {
                let url = URL(string: postImage)
                self.imageView.kf.setImage(with: url, placeholder:UIImage(named: ""))
            }
            item.getArtwork({ (image) in
                self.imageView.image = image
            })
        }
    }
    
    func setPlayButtonState(forAudioPlayerState state: AudioPlayerState) {
        
        playButton.isSelected =  state == .playing ? true : false
    }
    
    func setErrorMessage(_ message: String) {
        self.loadIndicator.stopAnimating()
        errorLabel.isHidden = false
        errorLabel.text = message
    }
    
    // MARK: - AudioPlayer Event Handlers
    
    func handleAudioPlayerStateChange(data: AudioPlayer.StateChangeEventData) {
        DispatchQueue.main.async {
            self.setPlayButtonState(forAudioPlayerState: data)
            switch data {
            case .loading:
                self.loadIndicator.startAnimating()
                self.updateMetaData()
                self.updateTimeValues()
            case .buffering:
                self.loadIndicator.startAnimating()
            case .ready:
                self.loadIndicator.stopAnimating()
                self.updateMetaData()
                self.updateTimeValues()
            case .playing, .paused, .idle:
                self.loadIndicator.stopAnimating()
                self.updateTimeValues()
            }
        }
    }
    func handleAudioPlayerEnd(data: AudioPlayer.PlaybackEndEventData) {
        if (self.player != nil) {
            self.player.seek(to: 0)
            self.player.play()
        }
    }
    func handleAudioPlayerSecondElapsed(data: AudioPlayer.SecondElapseEventData) {
        if !isScrubbing {
            DispatchQueue.main.async {
                self.updateTimeValues()
            }
        }
    }
    
    func handleAudioPlayerDidSeek(data: AudioPlayer.SeekEventData) {
        isScrubbing = false
    }
    
    func handleAudioPlayerUpdateDuration(data: AudioPlayer.UpdateDurationEventData) {
        DispatchQueue.main.async {
            self.updateTimeValues()
        }
    }
    
    func handleAVPlayerRecreated() {
        try? self.audioSessionController.set(category: .playback)
    }
    
    func handlePlayerFailure(data: AudioPlayer.FailEventData) {
        if let error = data as NSError? {
            if error.code == -1009 {
                lastLoadFailed = true
                DispatchQueue.main.async {
                    self.setErrorMessage("Network disconnected. Please try again...")
                }
            }
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.player.stop()
        self.dismiss(animated: true, completion: nil)
    }
}
