//
//  LikeCommentBottomPopupVC.swift
//  Divineray
//
//  Created by Tejas Dattani on 09/01/22.
//  Copyright © 2022 Dharmani Apps. All rights reserved.
//

import UIKit
import Alamofire
import BottomPopup

protocol likeCommentBottomPopupVCDelegate {
    func getLikeAndCommentStatus(isLikingOn: Bool, isCommentingOn: Bool)
}


class LikeCommentBottomPopupVC: BottomPopupViewController {
    
    @IBOutlet weak var IBBtnToggleComment: UIButton!
    @IBOutlet weak var IBBtnToggleLike: UIButton!
    
    var delegate : likeCommentBottomPopupVCDelegate?
    
    var isLikingOn     = false
    var isCommentingOn = false
    var height : CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    
    //------------------------------------------------------------------
    // MARK:- View life cycle methods
    //------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }
    
    //------------------------------------------------------------------
    
    override var popupHeight: CGFloat { return height ?? 190 }
    
//    override func getPopupHeight() -> CGFloat {
//        return height ?? CGFloat(500)
//    }
    
    //------------------------------------------------------------------
    
    @objc func getPopupTopCornerRadius() -> CGFloat {
        return topCornerRadius ?? CGFloat(10)
    }
    
    //------------------------------------------------------------------
    
    @objc func getPopupPresentDuration() -> Double {
        return presentDuration ?? 1.0
    }
    
    //------------------------------------------------------------------
    
    @objc func getPopupDismissDuration() -> Double {
        return dismissDuration ?? 1.0
    }
    
    //------------------------------------------------------------------
    
    @objc func shouldPopupDismissInteractivelty() -> Bool {
        return shouldDismissInteractivelty ?? true
    }
    
    //------------------------------------------------------------------
}

//------------------------------------------------------------------
// MARK:- Action Methods
//------------------------------------------------------------------

extension LikeCommentBottomPopupVC {
    
    //------------------------------------------------------------------
    
    @IBAction func IBBtnDismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //------------------------------------------------------------------
    
}

//------------------------------------------------------------------
// MARK:- Custom Methods
//------------------------------------------------------------------

extension LikeCommentBottomPopupVC {
    
    //------------------------------------------------------------------

    @objc func dismissView() {
        self.dismiss(animated: false, completion: nil)
    }
    
    //------------------------------------------------------------------
    
}

//------------------------------------------------------------------
// MARK:- SetLayout Methods
//------------------------------------------------------------------

extension LikeCommentBottomPopupVC {
    
    //------------------------------------------------------------------
    
    func setLayout()  {
        self.title = ""
        if isLikingOn == true {
            self.IBBtnToggleLike.setTitle("Turn off Liking", for: .normal)
        } else {
            self.IBBtnToggleLike.setTitle("Turn on Liking", for: .normal)
        }
        if isCommentingOn == true {
            self.IBBtnToggleComment.setTitle("Turn off Commenting", for: .normal)
        } else {
            self.IBBtnToggleComment.setTitle("Turn on Commenting", for: .normal)
        }
        self.IBBtnToggleLike.addTarget(self, action: #selector(self.likeAction(_:)), for: .touchUpInside)
        self.IBBtnToggleComment.addTarget(self, action: #selector(self.commentAction(_:)), for: .touchUpInside)
    }
    
    //------------------------------------------------------------------
    
    @objc func likeAction(_ button: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.getLikeAndCommentStatus(isLikingOn: true, isCommentingOn: false)
        }
    }
    
    //------------------------------------------------------------------
    
    @objc func commentAction(_ button: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.getLikeAndCommentStatus(isLikingOn: false, isCommentingOn: true)
        }
    }
    
    //------------------------------------------------------------------
    
    
    //------------------------------------------------------------------
    
    @objc func IBBtnDismissVCTapped() {
        self.navigationController?.popViewController(animated: false)
    }
    
    //------------------------------------------------------------------
    
}
