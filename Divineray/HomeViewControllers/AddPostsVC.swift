//
//  AddPostsVC.swift
//  Divineray
//
//  Created by dr mac on 06/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit
import GrowingTextView
import iOSPhotoEditor
import ToastViewSwift
import SVProgressHUD


@available(iOS 14.0, *)
class AddPostsVC: UIViewController,PhotoEditorDelegate,UITextViewDelegate {
//    func videoSelect(thumbnail: Data?, videoData: Data?, duration: String?) {
//        if videoData != nil {
//            print(videoData , "VData")
//            self.selectedVideoData = videoData ?? Data()
//            let image = UIImage(data: thumbnail!)
//            self.thumbNail = thumbnail ?? Data()
//            self.uploadImage.image = image
//            self.mediaType = "1"
//            self.videoDuration = duration ?? ""
//            print( self.selectedVideoData, self.mediaType,self.videoDuration , "SData")
//        }
//
//    }
    
    func doneEditing(image: UIImage) {
        uploadImage.image = image
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func canceledEditing() {
        print("Canceled")
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBOutlet weak var selectBtn: UIButton!
    
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var tagText: GrowingTextView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var descriptionText: GrowingTextView!
    var imagePickerController = UIImagePickerController()
    var selectedVideoData = Data()
    var thumbNail = Data()
    var mediaType = String()
    var videoDuration = String()
    var postWidth = String()
    var postHeight = String()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
//        self.uploadImage.image = UIImage(named: "")
        //        NotificationCenter.default.post(name: .init("updateUserImage"), object: nil)
        self.selectBtn.isSelected = false
        descriptionText.delegate = self
        tagText.delegate = self
        self.tabBarController?.tabBar.isHidden = false
        bgView.isHidden = true
        self.backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapgesture))
        bgView.addGestureRecognizer(tapGesture)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func tapgesture(){
        bgView.isHidden = true
       self.tabBarController?.tabBar.isHidden = false
    }
    @IBAction func selectPostToGroupAction(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    @IBAction func uploadImageAction(_ sender: UIButton) {
        self.modalPresentationStyle = .overFullScreen
        self.bgView.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func addPostApi(){
        var userModel = SignupModel()
        userModel.user_id = ApplicationStates.getUserID()
        userModel.title = ""
        userModel.description = self.descriptionText.text
        userModel.tags = self.tagText.text
        userModel.musicId = ""
        if self.mediaType == "1" {
            userModel.postVideo = self.selectedVideoData
            userModel.postImage = self.uploadImage.image?.pngData()
            userModel.type = "1"
            userModel.postWidth = self.postWidth
            userModel.postHeight = self.postHeight
        }else{
            userModel.postImage = self.uploadImage.image?.pngData()
            userModel.type = "2"
        }
        userModel.isGroupPost = "0"
        SVProgressHUD.show()
        UserApiModel().addEditPost(model: userModel) { response, error in
            SVProgressHUD.dismiss()
            if let jsonResponse = response{
                if let parsedData = try? JSONSerialization.data(withJSONObject: jsonResponse,options: .prettyPrinted){
                    let userDict = try? JSONDecoder().decode(ApiResponseModel<AddPostModel>.self, from: parsedData)
                    if userDict?.status == 1{
                        self.showAlertMessage(title: "DivineRay", message: userDict?.message ?? "", okButton: "OK", controller: self) {
                            NotificationCenter.default.post(name: .init("updateUserImage"), object: nil)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        //        if selectedVideoData.count == 0 {
        //            showAlertWith(title: "DivineRay", message: "Please select image/video.")
        //        }else if self.descriptionText.text == "" {
        //            showAlertWith(title: "DivineRay", message: "Please enter description")
        //        }
//        else if self.tagText.text == "" {
//              showAlertWith(title: "DivineRay", message: "Please add tags")
//    }
        if selectBtn.isSelected == true{
            if selectedVideoData.count == 0 {
                showAlertWith(title: "DivineRay", message: "Please select image/video.")
            }else if self.descriptionText.text == "" {
                showAlertWith(title: "DivineRay", message: "Please enter description")
            }
            else if self.tagText.text == "" {
                  showAlertWith(title: "DivineRay", message: "Please add tags")
            }else{
                let vc = SelectGroupVC()
                vc.descript = self.descriptionText.text
                vc.taggs = self.tagText.text
                vc.mediaTyp = self.mediaType
                if self.mediaType == "1" {
                    vc.postVideo = self.selectedVideoData
                    vc.postImg = self.uploadImage.image?.pngData() ?? Data()
                    vc.typp = "1"
                    vc.postWidth = self.postWidth
                    vc.postHeight = self.postHeight
                }else{
                    vc.postImg = self.uploadImage.image?.pngData() ?? Data()
                    vc.typp = "2"
                }
                vc.navigationController?.isNavigationBarHidden = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
                    if selectedVideoData.count == 0 {
                        showAlertWith(title: "DivineRay", message: "Please select image/video.")
                    }else if self.descriptionText.text == "" {
                        showAlertWith(title: "DivineRay", message: "Please enter description")
                    }
                    else if self.tagText.text == "" {
                          showAlertWith(title: "DivineRay", message: "Please add tags")
                    }else{
                        addPostApi()
                        print("same screen")
                        self.btnNext.isUserInteractionEnabled = false
                    }
        }
    }
    @IBAction func uploadVideo(_ sender: UIButton) {
        uploadVideo()
    }
    
    @IBAction func uploadImageBtnAction(_ sender: UIButton) {
        uploadImages()
    }
    @IBAction func cameraAction(_ sender: UIButton) {
        openCamera()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == tagText {
            if let text = tagText.text {
                let components = text.components(separatedBy: " ")
                var formattedText = ""
                for component in components {
                    if component.hasPrefix("#") {
                        formattedText += " \(component)"
                    } else {
                        formattedText += " #\(component)"
                    }
                }
                tagText.text = formattedText.trimmingCharacters(in: .whitespaces)
            }
        }
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
}
@available(iOS 14.0, *)
extension AddPostsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let tempImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            if let video = info[.mediaURL] as? URL {

                let thumbnail = self.thumbnailForVideoAtURL(url: video)
                //                let thumbnailData = thumbnail!.jpegData(compressionQuality: 0.3)!
                let data = NSData(contentsOf: video as URL)! as Data
                print(data,"Videoooooooooo")

                let asset = AVURLAsset(url: video)
                resolutionForLocalVideo(url: video)
                let durationInSeconds = asset.duration.seconds
                var ghg = Int(durationInSeconds)
                self.mediaType = "1"
                print(ghg ,"Seconds")
                if ghg >= 30 && ghg <= 60{
                    var ggh = "00:\(ghg)"
                    print(ggh,"SEco1")
                    self.thumbNail = thumbnail ?? Data()
                    let image = UIImage(data: thumbnail!)
                    self.uploadImage.image = image
                    self.selectedVideoData = data ?? Data()
                    self.dismiss(animated: true, completion: nil)
                    bgView.isHidden = true
                }else if ghg < 30{
                      let toast = Toast.text("You can upload video of minimum 30 seconds.")
                       toast.show()
                    DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
                        picker.dismiss(animated: true, completion: nil)
                    })
                }else if ghg > 60{
                    let toast = Toast.text("You can upload video of maximum 1 minute.")
                     toast.show()
                  DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
                      picker.dismiss(animated: true, completion: nil)
                  })
                }
                let gg = "String(ghg)"
            }
            bgView.isHidden = true
            self.tabBarController?.tabBar.isHidden = false
            return
        }
        bgView.isHidden = true
        self.dismiss(animated: true, completion: nil)
        self.tabBarController?.tabBar.isHidden = true
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))

        photoEditor.photoEditorDelegate = self
        photoEditor.image = tempImage
        self.mediaType = "2"
        photoEditor.modalPresentationStyle = UIModalPresentationStyle.currentContext //or .overFullScreen for transparency
        present(photoEditor, animated: true, completion: nil)
        self.selectedVideoData =  photoEditor.image?.jpegData(compressionQuality: 0.5)! ?? Data()
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

//    func pickerController(_ controller: UIImagePickerController, didSelect image: Data? , videoData: Data?,duration:String?) {
//        controller.dismiss(animated: true) {
//            self.delegate.videoSelect(thumbnail: image, videoData: videoData, duration: duration)
//        }
//    }

    func thumbnailForVideoAtURL(url: URL) -> Data? {

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


    func openCamera() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            imagePickerController.allowsEditing = true
            self.imagePickerController.delegate = self
            self.imagePickerController.mediaTypes = ["public.image","public.movie"]
            self.present(imagePickerController, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "Camera not found", message: "This device has no camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default,handler: nil))
            present(alert, animated: true,completion: nil)
        }
        present(alert, animated: true, completion: nil)
    }

    func uploadImages() {
        self.imagePickerController.allowsEditing = true
        self.imagePickerController.sourceType = .photoLibrary
        self.imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.image"]
        self.present(self.imagePickerController, animated: true, completion: nil)
        present(imagePickerController, animated: true, completion: nil)
    }

    func uploadVideo(){
        self.imagePickerController.delegate = self
        self.imagePickerController.sourceType = .savedPhotosAlbum
        self.imagePickerController.mediaTypes = ["public.movie"]
        self.imagePickerController.allowsEditing = false
        present(imagePickerController, animated: true, completion: nil)
    }

    func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
       let size = track.naturalSize.applying(track.preferredTransform)
        var wdth = abs(track.naturalSize.applying(track.preferredTransform).width)
        self.postWidth = "\(wdth)"
        var hght = abs(track.naturalSize.applying(track.preferredTransform).height)
        self.postHeight = "\(hght)"
        print(self.postWidth,self.postHeight, "WidthHeight")
        print("\(CGSize(width: abs(size.width), height: abs(size.height)))")
       return CGSize(width: abs(size.width), height: abs(size.height))
    }
}


