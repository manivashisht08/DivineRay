//
//  ImagePickFromGallery.swift
//  GoServe
//
//  Created by Dharmani Apps on 23/12/21.
//

import Foundation
import UIKit
import AVFoundation
import ToastViewSwift
import iOSPhotoEditor
protocol ImagePickDelegate: class {
    //    func didSelect(image: UIImage?,videoData:Data?)
    func videoSelect(thumbnail: Data?,videoData:Data?,duration:String?)
//    func imgSelect(image:UIImage?)
}
class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var picker = UIImagePickerController();
    var alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage) -> ())?;
    
    
    override init() {
        super.init()
        
    }
    
    func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage) -> ())) {
        pickImageCallback = callback;
        self.viewController = viewController
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) {
            UIAlertAction in
            self.viewController = viewController
            self.checkPermissions()
        }
        
        let gallaryAction = UIAlertAction(title: "Gallery", style: .default) {
            UIAlertAction in
            self.openGallery()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        picker.delegate = self
        self.picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = .black
        alert.popoverPresentationController?.sourceView = self.viewController!.view
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func checkPermissions() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .authorized:
            openCamera()
        case .denied:
            alertPromptToAllowCameraAccessViaSetting()
        default:
            print("")
            openCamera()
        }
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
        let alert = UIAlertController(title: "Error", message: "Camera access required to...", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Settings", style: .cancel) { (alert) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
        })
        alert.popoverPresentationController?.sourceView = self.viewController!.view
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            //             picker.sourceType = .camera
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.allowsEditing = true
            self.viewController!.present(picker, animated: true, completion: nil)
        } else {
            let alertWarning = UIAlertView(title: "Warning", message: "You don't have camera", delegate:nil, cancelButtonTitle: "OK", otherButtonTitles:"")
            alertWarning.show()
        }
    }
    
    func openGallery(){
        alert.dismiss(animated: true, completion: nil)
        //  picker.sourceType = .photoLibrary
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.allowsEditing = true
        self.viewController!.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage]
                as? UIImage else {
            return
        }
        pickImageCallback?(image)
        picker.dismiss(animated: true, completion: nil)
        //    let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        //        pickImageCallback?(image)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
        
    }
    
}
class ImagePickerManager2: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var picker = UIImagePickerController();
    var alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage) -> ())?;
    
    
    override init(){
        super.init()
        
    }
    
    func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage) -> ())) {
        pickImageCallback = callback;
        self.viewController = viewController;
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default){
            UIAlertAction in
            self.checkPermissions()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: .default){
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            UIAlertAction in
        }
        
        // Add the actions
        picker.delegate = self
        //        self.picker.sourceType = .photoLibrary
        //        picker.allowsEditing = true
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = .black
        alert.popoverPresentationController?.sourceView = self.viewController!.view
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func checkPermissions() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .authorized:
            openCamera()
        case .denied:
            alertPromptToAllowCameraAccessViaSetting()
        default:
            openCamera()
        }
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
        let alert = UIAlertController(title: "Error", message: "Camera access required to...", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Settings", style: .cancel) { (alert) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
        })
        alert.popoverPresentationController?.sourceView = self.viewController!.view
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            // picker.sourceType = .camera
            picker.sourceType = UIImagePickerController.SourceType.camera
            //  picker.allowsEditing = true
            self.viewController!.present(picker, animated: true, completion: nil)
        } else {
            let alertWarning = UIAlertView(title:"Warning", message: "You don't have camera", delegate:nil, cancelButtonTitle:"OK", otherButtonTitles:"")
            alertWarning.show()
        }
    }
    
    func openGallery(){
        alert.dismiss(animated: true, completion: nil)
        //  picker.sourceType = .photoLibrary
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        //  picker.allowsEditing = true
        self.viewController!.present(picker, animated: true, completion: nil)
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage]
                as? UIImage else {
            return
        }
        //        picker.dismiss(animated: true, completion: nil)
        
        //    let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        pickImageCallback?(image)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
        
    }
    
}

class ImagePickerManagerr: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
    
    
    
    var picker = UIImagePickerController();
    var alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage) -> ())?;
    var delegate: ImagePickDelegate?
    public init(presentationController: UIViewController, delegate: ImagePickDelegate) {
        self.picker = UIImagePickerController()
        super.init()
        self.viewController = presentationController
        self.delegate = delegate
        self.picker.delegate = self
        self.picker.allowsEditing = true
        //        self.pickerController.mediaTypes = ["public.image","public.movie"]
    }
    //    override init() {
    //        super.init()
    //        
    //    }
    
    func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage) -> ())) {
        pickImageCallback = callback;
//        self.viewController = viewController;
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) {
            UIAlertAction in
            self.checkPermissions()
        }
        
        let gallaryAction = UIAlertAction(title: "Gallery", style: .default) {
            UIAlertAction in
            self.openGallery()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        picker.delegate = self
        self.picker.sourceType = .savedPhotosAlbum
        picker.allowsEditing = true
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = .black
        alert.popoverPresentationController?.sourceView = self.viewController!.view
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func checkPermissions() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .authorized:
            openCamera()
        case .denied:
            alertPromptToAllowCameraAccessViaSetting()
        default:
            print("openCamera")
                        openCamera()
        }
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
        let alert = UIAlertController(title: "Error", message: "Camera access required to...", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Settings", style: .cancel) { (alert) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
        })
        alert.popoverPresentationController?.sourceView = self.viewController!.view
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            // picker.sourceType = .camera
            //            picker.cameraDevice = .
            picker.sourceType = .camera
            picker.allowsEditing = true
            picker.mediaTypes = ["public.image","public.movie"]

            self.viewController!.present(picker, animated: true, completion: nil)
        } else {
            let alertWarning = UIAlertView(title: "Warning", message: "You don't have camera", delegate:nil, cancelButtonTitle: "OK", otherButtonTitles:"")
            alertWarning.show()
        }
    }
    
    func openGallery(){
        alert.dismiss(animated: true, completion: nil)
        picker.mediaTypes = ["public.image","public.movie"]
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.viewController!.present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            if let video = info[.mediaURL] as? URL {
                
                let thumbnail = self.thumbnailForVideoAtURL(url: video)
                //                let thumbnailData = thumbnail!.jpegData(compressionQuality: 0.3)!
                let data = NSData(contentsOf: video as URL)! as Data
                print(data,"Videoooooooooo")
                
                let asset = AVURLAsset(url: video)
                resolutionForLocalVideo(url: video)
                let durationInSeconds = asset.duration.seconds
                var ghg = Int(durationInSeconds)
                print(ghg ,"Seconds")
                if ghg >= 30 && ghg <= 60{
                    var ggh = "00:\(ghg)"
                    print(ggh,"SEco1")
                    self.pickerController(picker, didSelect: thumbnail, videoData: data, duration: ggh)
                    picker.dismiss(animated: true, completion: nil)

//                }else if ghg > 59 && ghg <= 120 {
//                    var ss =  ghg - 60
//                    var ggh = "01:\(ss)"
//                    print(ggh,"SEco3")
//                    self.pickerController(picker, didSelect: thumbnail, videoData: data, duration: ggh)
//                    picker.dismiss(animated: true, completion: nil)
//
//                }
//                else if ghg < 10{
//                    let ggh = "00:0\(ghg)"
//                    print(ggh,"SEco2")
//                    self.pickerController(picker, didSelect: thumbnail, videoData: data, duration: ggh)
//                    picker.dismiss(animated: true, completion: nil)

                }else if ghg > 60 && ghg < 30{
                    let toast = Toast.text("You can upload video of 1 minutes duration.")
                    toast.show()
                    DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
                        picker.dismiss(animated: true, completion: nil)
                    })

                }
                let gg = "String(ghg)"
//                let ggh = "00:\(ghg)"
                
                
            }
            return
        }
//        self.pickerController(picker, didSelect: image)
        self.pickImageCallback?(image)
        picker.dismiss(animated: true, completion: nil)
//        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
//
//        photoEditor.photoEditorDelegate = self
//        photoEditor.image = image
//        photoEditor.modalPresentationStyle = UIModalPresentationStyle.currentContext //or .overFullScreen for transparency
//        self.present(photoEditor, animated: true, completion: nil)
//        self.selectedVideoData =  photoEditor.image?.jpegData(compressionQuality: 0.5)! ?? Data()
        print(image,"ERWEEWR")
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
//    func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?){
//        self.delegate?.imgSelect(image: image)
//    }
    func pickerController(_ controller: UIImagePickerController, didSelect image: Data? , videoData: Data?,duration:String?) {
        controller.dismiss(animated: true) {
            //            self.delegate?.didSelect(image: image,videoData: videoData)
            self.delegate?.videoSelect(thumbnail: image, videoData: videoData, duration: duration)
        }
    }
    
    
    
    private func thumbnailForVideoAtURL(url: URL) -> Data? {
        
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at:time, actualTime: nil)
            return UIImage(cgImage: imageRef).jpegData(compressionQuality: 1)
        } catch {
            return nil
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
        
    }
    func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
       let size = track.naturalSize.applying(track.preferredTransform)
        print("\(CGSize(width: abs(size.width), height: abs(size.height)))")
       return CGSize(width: abs(size.width), height: abs(size.height))
    }

    
    
}
