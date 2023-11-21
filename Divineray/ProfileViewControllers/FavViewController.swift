//
//  FavViewController.swift
//  Divineray
//
//  Created by     on 12/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD

class FavViewController: UIViewController {
    var pagingDone = false
    var userProfileUserId = ""
    
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var btView: NSLayoutConstraint!
    @IBOutlet weak var topConst: NSLayoutConstraint!
    
    var itemArray : NSMutableArray!
    @IBOutlet weak var collectionView: UICollectionView!
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
        if self.topConst != nil {
            self.topConst.constant = 2.0
        }
    }
    func removeData() {
           self.itemArray.removeAllObjects()
       }
    func updateData(data:NSArray) {
        if self.itemArray ==  nil {
            self.itemArray = NSMutableArray.init()
        }
        self.itemArray.removeAllObjects()
        for ids in data {
            if !self.itemArray.contains(ids) {
                self.itemArray.add(ids)
            }
        }
        if self.itemArray.count < 2 {
                   self.itemArray.add("1")
               }
        self.collectionView.reloadData()
        if self.itemArray.count == 0 || data.count == 0 {
            self.nodataLbl.isHidden = false;
        }else {
            self.nodataLbl.isHidden = true;
        }
    }
    func updateDataInclass(data:NSArray) {
        if self.itemArray ==  nil {
            self.itemArray = NSMutableArray.init()
        }
        for ids in data {
            if !self.itemArray.contains(ids) {
                self.itemArray.add(ids)
            }
        }

        if self.itemArray.count < 2 {
                   self.itemArray.add("1")
               }
        self.collectionView.reloadData()
        if self.itemArray.count == 0 || data.count == 0 {
            self.nodataLbl.isHidden = false;
        }else {
            self.nodataLbl.isHidden = true;
        }
    }
    
}
@available(iOS 14.0, *)
extension FavViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.itemArray.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : imageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier:"imageCollectionViewCell", for: indexPath as IndexPath) as! imageCollectionViewCell
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.clipsToBounds = true
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
            self.getFAvVideosDetails()
        }
        return cell      //return your cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if  let dict = self.itemArray.object(at: indexPath.row) as? NSDictionary
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
        self.navigationController?.pushViewController(playerClass, animated: true)
        }
        
    }
    func getFAvVideosDetails() {
        
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
        
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAllFavVideosURL, postData: params) { (result) -> Void in
            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            if let data =  result["data"] as? [String : Any] {
                                if let FavVideos = result["FavVideos"] as? NSArray {
                                    self.updateDataInclass(data: FavVideos)
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

extension FavViewController : UICollectionViewDelegate
{
    
}
@available(iOS 14.0, *)

extension FavViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let width = self.view.frame.size.width/3-1;
        
        return CGSize(width: width, height: width*4/3)
    }
}
