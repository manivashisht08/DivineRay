//
//  AddPosttVC.swift
//  Divineray
//
//  Created by dr mac on 02/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit
import GrowingTextView
import iOSPhotoEditor

class AddPosttVC: UIViewController,PhotoEditorDelegate {
    func doneEditing(image: UIImage) {
        uploadImage.image = image
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func canceledEditing() {
        print("Canceled")
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var uploadImage: UIImageView!
    
    @IBOutlet weak var descriptionTextView: GrowingTextView!
    var imagePickerController = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        bgView.isHidden = true
        self.backGroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapgesture))
        bgView.addGestureRecognizer(tapGesture)
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
    
    @IBAction func nextAction(_ sender: UIButton) {
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
}
extension AddPosttVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let tempImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
//        uploadImage.image  = tempImage
        bgView.isHidden = true
        self.dismiss(animated: true, completion: nil)
        self.tabBarController?.tabBar.isHidden = true
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
    
        photoEditor.photoEditorDelegate = self
        photoEditor.image = tempImage
        photoEditor.modalPresentationStyle = UIModalPresentationStyle.currentContext //or .overFullScreen for transparency
        present(photoEditor, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
}

