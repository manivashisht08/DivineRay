//
//  TagListViewController.swift
//  Divineray
//
//  Created by Ansh Kumat on 04/07/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD

@available(iOS 14.0, *)
class TagListViewController: UIViewController {
    @objc var tagString = ""
    @objc var musicName = ""
    @objc var musicId = ""
    
    @IBOutlet weak var collectionView: UICollectionView!
    var itemArray : NSMutableArray!
    var pagingDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.itemArray = NSMutableArray.init()
        self.registerNib()
        self.collectionView.isPagingEnabled = true;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        // Do any additional setup after loading the view.
        self.getAllVideosDetailsFromTag()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        if let navigationBar = self.navigationController?.navigationBar {
            if (navigationBar.viewWithTag(11) as? UILabel) != nil {
                self.updatenavigationBar()
            }else {
                self.addCustomNavigation()
            }
        }else {
            self.addCustomNavigation()
        }
    }
    func addCustomNavigation() {
        if let navigationBar = self.navigationController?.navigationBar {
            self.navigationItem.setHidesBackButton(true, animated: true);
            
            let firstFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: navigationBar.frame.height)
            let firstLabel = UILabel(frame: firstFrame)
            if self.tagString.isEmpty {
                firstLabel.text = self.musicName
                
            }else {
                firstLabel.text = self.tagString
            }
            firstLabel.textAlignment = .center
            firstLabel.font = UIFont(name: "Poppins-Medium", size: 17)
            firstLabel.tag = 11
            navigationBar.addSubview(firstLabel)
            let btnFrame = CGRect(x: UIScreen.main.bounds.size.width-54, y: 0, width: 44, height: navigationBar.frame.height)
            let btnSetting = UIButton(type: .custom)
            btnSetting.frame = btnFrame
            btnSetting.setImage(UIImage(named: "st"), for: .normal)
            navigationBar.addSubview(btnSetting)
            btnSetting.tag = 12
            
            let btnBackFrame = CGRect(x: 9, y: 0, width: 44, height: navigationBar.frame.height)
            let btnBack = UIButton(type: .custom)
            btnBack.frame = btnBackFrame
            btnBack.setImage(UIImage(named: "back"), for: .normal)
            navigationBar.addSubview(btnBack)
            btnBack.tag = 13
            btnBack.isHidden = false
            btnSetting.isHidden = true
            
        }
    }
    func registerNib(){
        let nibImgView = UINib(nibName: "imageCollectionViewCell", bundle: nil)
        collectionView.register(nibImgView, forCellWithReuseIdentifier: "imageCollectionViewCell")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.updatenavigationBar()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.updatenavigationBarBack()
        self.navigationController?.navigationBar.isHidden = true
    }
    func updatenavigationBar(){
        if let navigationBar = self.navigationController?.navigationBar {
            // remove left buttons (in case you added some)
            self.navigationItem.leftBarButtonItems = []
            // hide the default back buttons
            self.navigationItem.hidesBackButton = true
            if let lblInfo = navigationBar.viewWithTag(11) as? UILabel {
                if self.tagString.isEmpty {
                    lblInfo.text = self.musicName
                }else {
                    lblInfo.text = self.tagString
                }
            }
            if let btnSetting = navigationBar.viewWithTag(12) as? UIButton {
                btnSetting.isHidden = true
            }
            if let backBtn = navigationBar.viewWithTag(13) as? UIButton {
                backBtn.isHidden = false
                backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
                
            }
        }
    }
    
    func updatenavigationBarBack(){
        if let navigationBar = self.navigationController?.navigationBar {
            if let backBtn = navigationBar.viewWithTag(13) as? UIButton {
                backBtn.removeTarget(self, action: #selector(backAction), for: .touchUpInside)
            }
        }
    }
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
@available(iOS 14.0, *)
extension TagListViewController : UICollectionViewDataSource {
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
            self.getAllVideosDetailsFromTag()
        }
        return cell      //return your cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if  let dict = self.itemArray.object(at: indexPath.row) as? NSDictionary
        {
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
            playerClass.tagString = "";
            self.navigationController?.pushViewController(playerClass, animated: true)
        }
        
    }
    func getAllVideosDetailsFromTag() {
        
        var lastId = "0"
        let countvalue : Int
            = self.itemArray.count
        if countvalue > 0 {
            if  let dict = self.itemArray.lastObject as? NSDictionary {
                if let las =  dict["videoId"] as? String {
                    lastId = las
                }
            }
        }else {
            SVProgressHUD.show()
        }
        var isMusicData = "0";
        if self.tagString.isEmpty {
            isMusicData = "1"
        }
        let params:[String:Any] = [
            "user_id":ApplicationStates.getUserID(),"lastId":lastId,"perPage":"20","tagString":self.tagString,"musicId":self.musicId,"isMusicData":isMusicData
        ]
        SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAllTaggedVideosURL, postData: params) { (result) -> Void in

            switch (result) {
            case .success(let json):
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                if let result:[String:Any] = json as? Dictionary {
                    if let status = result["status"] as? Int {
                        if status == 1 {
                            if let tagVideos = result["data"] as? NSArray {
                                self.updateData(data: tagVideos)
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
    func updateData(data:NSArray) {
        self.itemArray.addObjects(from: data as! [Any])
        if self.itemArray.count < 2 {
            self.itemArray.add("1")
        }
        self.collectionView.reloadData()
    }
}
@available(iOS 14.0, *)
extension TagListViewController : UICollectionViewDelegate{

}
@available(iOS 14.0, *)

extension TagListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let width = self.view.frame.size.width/3-1;
        
        return CGSize(width: width, height: width*4/3)
    }
}
@available(iOS 14.0, *)

extension TagListViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // return NO to not change text
        let maxLength = 100
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    
}
