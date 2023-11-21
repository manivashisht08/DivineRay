//
//  AllViewController.swift
//  Divineray
//
//  Created by     on 12/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
@available(iOS 14.0, *)
class AllViewController: UIViewController {
    var isUserSef = true
    @IBOutlet weak var nodatalbl: UILabel!
    var pagingDone = false
    var userProfileUserId = ""
    @IBOutlet weak var btView: NSLayoutConstraint!
    @IBOutlet weak var topConst: NSLayoutConstraint!
    var firstTime = 0
    @IBOutlet weak var collectionView: UICollectionView!
    var itemArray : NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.itemArray = NSMutableArray.init()
        self.registerNib()
        self.collectionView.isPagingEnabled = true;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        // Do any additional setup after loading the view.
        self.btView.constant = 0.0
        
    }
    func registerNib(){
        let nibImgView = UINib(nibName: "imageCollectionViewCell", bundle: nil)
        collectionView.register(nibImgView, forCellWithReuseIdentifier: "imageCollectionViewCell")
    }
    func updateConstValue() {
        self.topConst.constant = 2        
    }
    func removeData() {
        self.itemArray.removeAllObjects()
    }
    func updateData(data:NSArray) {
        
        self.itemArray.addObjects(from: data as! [Any])
        self.collectionView.reloadData()
        if self.itemArray.count == 0 {
            self.nodatalbl.isHidden = false;
        }else {
            self.nodatalbl.isHidden = true;
            if self.itemArray.count < 2 {
                self.itemArray.add("1")
            }
        }
    }
}
@available(iOS 14.0, *)
extension AllViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.itemArray.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : imageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier:"imageCollectionViewCell", for: indexPath as IndexPath) as! imageCollectionViewCell
        
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.backgroundColor = UIColor.lightGray
        if  let dict = self.itemArray.object(at: indexPath.row) as? NSDictionary
        {
            if let postImage = dict["postImage"] as? String {
                let url = URL(string: postImage)
                cell.imageView.kf.setImage(with: url, placeholder:UIImage(named: ""))
                
            }
            cell.imageView.backgroundColor = UIColor.gray
        }else {
            cell.imageView.backgroundColor = UIColor.white
        }
        
        let countvalue : Int
            = self.itemArray.count - 5
        
        if !self.pagingDone && countvalue == indexPath.row {
            self.getAllVideosDetails()
        }
        return cell      //return your cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if  self.itemArray.object(at: indexPath.row) is NSDictionary
        {
            var userId = ApplicationStates.getUserID()
            if !self.userProfileUserId.isEmpty {
                userId = self.userProfileUserId
            }
            let playerClass = PlaylistViewController.init(nibName: "PlaylistViewController", bundle: Bundle.main)
            playerClass.isFromUser = true;
            let mutArra:NSMutableArray =  NSMutableArray.init(array: self.itemArray)
            if let lastObj = self.itemArray.lastObject as? String
            {
                if lastObj == "1" {
                    mutArra.removeLastObject()
                }
            }
            playerClass.oldDataArray = mutArra
            playerClass.clickedItemIndex = indexPath.row
            playerClass.userId = userId;
            
            if userId ==  ApplicationStates.getUserID(){
                playerClass.delegate = self
                playerClass.myProfile = true
            }
            self.navigationController?.pushViewController(playerClass, animated: true)
        }
        
    }
    func getAllVideosDetails() {
        
        var lastId = "0"
        let countvalue : Int
            = self.itemArray.count
        if countvalue > 0 {
            if  let dict = self.itemArray.lastObject as? NSDictionary {
                if let las =  dict["videoId"] as? String {
                    lastId = las
                }
            }
        }
        var userId = ApplicationStates.getUserID()
        
        if !self.userProfileUserId.isEmpty {
            userId = self.userProfileUserId
        }
        let params:[String:Any] = [
            "user_id":ApplicationStates.getUserID(),"lastId":lastId,"perPage":"20","profileUserId":userId
        ]
        
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAllUserVideosURL, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            if let data =  result["data"] as? [String : Any] {
                                if let UserVideos = result["UserVideos"] as? NSArray {
                                    self.updateData(data: UserVideos)
                                }
                            }
                        }else {
                            self.pagingDone = true
                        }
                    }
                } else {
                }
                break
            case .failure(let error):
                self.showAlertWith(title:API.appName, message:error)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                break;
            }
        }
    }
}
@available(iOS 14.0, *)

extension AllViewController : UICollectionViewDelegate{
    
}
@available(iOS 14.0, *)
extension AllViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let width = self.view.frame.size.width/3-1;
        
        return CGSize(width: width, height: width*4/3)
    }
}
@available(iOS 14.0, *)
extension AllViewController : PlaylistViewControllerDeleteVideo {
    func deleteVideoClick(_ index: Int) {
        if self.itemArray.count > index {
            self.itemArray.removeObject(at: index)
            self.collectionView.reloadData()
        }
    }
    
}
