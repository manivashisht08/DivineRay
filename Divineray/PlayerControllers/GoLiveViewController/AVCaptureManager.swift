//
//  AVCaptureManager.swift
//  FullScreenCamera
//
//  Created by 박형석 on 2021/12/31.
//  Copyright © 2021 com.joonwon. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Photos

class AVCaptureManager: NSObject {
    
    let captureSession = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput!
    let photoOutput = AVCapturePhotoOutput()
    let sessionQueue = DispatchQueue(label: "session Queue")
    let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
        deviceTypes: [
            .builtInDualCamera,
            .builtInWideAngleCamera,
            .builtInTrueDepthCamera
        ],
        mediaType: .video,
        position: .unspecified)
    
    func intialSettingAndStart() {
        self.sessionQueue.async {
            self.setupSession()
            self.startSession()
        }
    }
    
    // MARK: - Setup session and preview
    func setupSession() {
        // TODO: captureSession 구성하기
        
        // - preset Setting 하기
        captureSession.sessionPreset = .photo
        // - beginConfiguration
        captureSession.beginConfiguration()
        
        // - Add Video Input
        var defaultVideoDevice: AVCaptureDevice?
        guard let camera = videoDeviceDiscoverySession.devices.first else {
            captureSession.commitConfiguration()
            return
        }
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                captureSession.commitConfiguration()
                return
            }
        } catch {
            print(error.localizedDescription)
            captureSession.commitConfiguration()
            return
        }
        // - Add Photo Output
        photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])], completionHandler: nil)
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        } else {
            captureSession.commitConfiguration()
            return
        }
        
        // - commitConfiguration
        captureSession.commitConfiguration()
    }
    
    func startSession() {
        // TODO: session Start
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        // TODO: session Stop
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func switchCamera(_ sender: UIButton) {
        // TODO: 카메라는 1개 이상이어야함
        guard videoDeviceDiscoverySession.devices.count > 1 else { return }
        
        // TODO: 반대 카메라 찾아서 재설정
        // - 반대 카메라 찾고
        // - 새로운 디바이스를 가지고 세션 업데이트
        // - 카메라 토글 버튼 업데이트
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            let isFront = currentPosition == .front
            let preferredPosition: AVCaptureDevice.Position = isFront ? .back : .front
            
            let devices = self.videoDeviceDiscoverySession.devices
            var newVideoDevide: AVCaptureDevice?
            newVideoDevide = devices.first(where: { device in
                return preferredPosition == device.position
            })
            
            if let newVideoDevide = newVideoDevide {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: newVideoDevide)
                    self.captureSession.beginConfiguration()
                    self.captureSession.removeInput(self.videoDeviceInput)
                    if self.captureSession.canAddInput(videoDeviceInput) {
                        self.captureSession.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        // 안되면 기존에 있는거 다시 넣어야...
                        self.captureSession.addInput(self.videoDeviceInput)
                        return
                    }
                    self.captureSession.commitConfiguration()
                    self.updateSwitchCameraIcon(sender, position: preferredPosition)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func updateSwitchCameraIcon(_ sender: UIButton, position: AVCaptureDevice.Position) {
        // TODO: Update ICON
        DispatchQueue.main.async {
            switch position {
            case .front:
                let image = UIImage(named: "img_stream_camera")
                sender.setImage(image, for: .normal)
            case .back:
                let image = UIImage(named: "img_stream_camera")
                sender.setImage(image, for: .normal)
            default:
                break
            }
            
        }
    }
    
    func capturePhoto(_ orientation: AVCaptureVideoOrientation) {
        // TODO: photoOutput의 capturePhoto 메소드
        // 미디어 데이터가 들어와서 나갈 때
        sessionQueue.async {
            // 사진에 대한 orientation을 Preview와 동일하게 맞춰주고
            let connection = self.photoOutput.connection(with: .video)
            connection?.videoOrientation = orientation
            
            // captureSession에 요청해서 이제 사진 찍자고 알려준 것
            let setting = AVCapturePhotoSettings()
            // 사진을 찍는 주기에 관련한 여러 delegate 메소드가 있다.
            // 우리는 후처리, 즉 저장을 사용할거라 아래 photoOutput 메서드 구현
            self.photoOutput.capturePhoto(with: setting, delegate: self)
        }
        // photo output
    }
    
    func savePhotoLibrary(image: UIImage) {
        // TODO: capture한 이미지 포토라이브러리에 저장
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { success, error in
                    print("이미지 저장완료 여부 \(success)")
                }
            } else {
                print("다시 권한을 받아야 합니다.")
            }
        }
    }
}

extension AVCaptureManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // TODO: capturePhoto delegate method 구현
        guard error == nil else { return }
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        self.savePhotoLibrary(image: image)
        
    }
}
