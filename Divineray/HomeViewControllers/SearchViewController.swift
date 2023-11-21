//
//  SearchViewController.swift
//  Divineray
//
//  Created by     on 11/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import SVProgressHUD
@available(iOS 14.0, *)
@available(iOS 14.0, *)
class SearchViewController: UIViewController {
    var refreshControl = UIRefreshControl()
    var referstart = false;

    
    @IBOutlet weak var seachtxtxField: UITextField!
    @IBOutlet weak var noDataFound: UILabel!
    var serviceisInCall = false
    @IBOutlet weak var cnclBtn: UIButton!
    @IBOutlet weak var trailView: NSLayoutConstraint!
    private let kSeachTableViewCell = "SLDiscoverTableViewCell"
    @IBOutlet weak var tbView: UITableView!
    @IBOutlet var footerView: UIView!
    var itemArray : NSMutableArray!
    var pagingDone = false

    override func viewDidLoad() {
        
        super.viewDidLoad()
        //self.RSAAlgo()
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.black
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)])

        
        self.seachtxtxField.returnKeyType = .search
        self.seachtxtxField.delegate = self
        self.cnclBtn.isHidden = true
        self.setUIAndData()
        self.itemArray = NSMutableArray.init()
        self.tbView.delegate = self
        self.tbView.dataSource = self
        self.noDataFound.isHidden = true
        self.tbView.addSubview(refreshControl)

        
        // Do any additional setup after loading the view.
    }
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        referstart = true;
        self.seachtxtxField.text = ""
        self.seachtxtxField.resignFirstResponder()
        self.getAllVideosDetailsFromTag()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.itemArray.removeAllObjects()
        self.tbView.reloadData()
        self.getAllVideosDetailsFromTag()
    }
    func setUIAndData() {
        let nibNameCell = UINib (nibName: "SLDiscoverTableViewCell", bundle: nil)
        self.tbView.register(nibNameCell, forCellReuseIdentifier: kSeachTableViewCell)
    }
    func getAllVideosDetailsFromTag() {
        if self.serviceisInCall {
            return;
        }
        self.serviceisInCall  =  true;
        let countvalue : Int
                = self.itemArray.count
        if countvalue == 0 {
           self.pagingDone = false
        }
        if(!self.pagingDone) {
        var lastId = "0"
            if countvalue > 0 &&  !self.referstart {
            if  let dict = self.itemArray.lastObject as? NSDictionary {
                if let las =  dict["tagId"] as? String {
                    lastId = las
                }
            }
        }else {
            if !self.referstart {
            SVProgressHUD.show()
            }
        }
       //user_id, search, lastId, perPage
           let params:[String:Any] = [
            "user_id":ApplicationStates.getUserID(),"lastId":lastId,"perPage":"50",
            "search":self.seachtxtxField.text ?? ""
           ]
           SRDataManager.sharedInstance().performNetworkPostServiceRequest(requestURL: API.getAllTagsListingAndSearchURL, postData: params) { (result) -> Void in
               switch (result) {
               case .success(let json):
                self.serviceisInCall = false;
                   DispatchQueue.main.async {
                       SVProgressHUD.dismiss()
                   }
                   if let result:[String:Any] = json as? Dictionary {                    
                       if let status = result["status"] as? Int {
                           if status == 1 {
                            self.noDataFound.isHidden = true
                                   if let tagVideos = result["data"] as? NSArray {
                                       self.updateData(data: tagVideos)
                                   }
                            if let message =  result["message"] as? String {
                                if lastId == "0" && self.itemArray.count == 0 {
                                self.noDataFound.text = message
                                        self.noDataFound.isHidden = false
                                }
                            }
                           }else {
                            self.pagingDone = true
                            if let message =  result["message"] as? String {
                                if lastId == "0" && self.itemArray.count == 0 {
                                self.noDataFound.text = message
                                        self.noDataFound.isHidden = false
                                }
                            }

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
    func updateData(data:NSArray) {
        if self.referstart {
            self.itemArray.removeAllObjects()
        }
          self.itemArray.addObjects(from: data as! [Any])
          self.tbView.reloadData()
        self.referstart = false
        self.refreshControl.endRefreshing()
      }

    @IBAction func cancelTxtField(_ sender: Any) {
        self.seachtxtxField.text = "";
        self.seachtxtxField.resignFirstResponder()
        self.itemArray.removeAllObjects()
        self.serviceisInCall = false
        self.getAllVideosDetailsFromTag()
    }
}
@available(iOS 14.0, *)
extension SearchViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 10
      
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      
            let hv = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
            hv.backgroundColor = UIColor.clear
            return hv
      
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 210
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            guard let cell : SLDiscoverTableViewCell = tableView.dequeueReusableCell(withIdentifier: kSeachTableViewCell, for: indexPath) as? SLDiscoverTableViewCell else {
                fatalError("Unable to Dequeue Reusable Table View Cell")
            }
       if let dict = self.itemArray.object(at: indexPath.row) as? NSDictionary
       {
        cell.updateData(dict as? [AnyHashable : Any])
        cell.delegate = self
        }
        cell.viewActionBtn.removeTarget(self, action: #selector(viewActionAction(btn:)), for: .touchUpInside)
        cell.viewActionBtn.addTarget(self, action: #selector(viewActionAction(btn:)), for: .touchUpInside)
        cell.viewActionBtn.tag = indexPath.row
        if indexPath.row > self.itemArray.count - 5 {
            self.getAllVideosDetailsFromTag()
        }
            return cell
        }
    @objc func viewActionAction(btn:UIButton) {
      if let dict = self.itemArray.object(at: btn.tag) as? NSDictionary
              {
                if let tagTitle = dict.value(forKey: "tagTitle") as? String {
                    let tagObject = TagListViewController(nibName: "TagListViewController", bundle: nil)
                    tagObject.tagString = tagTitle;
                    self.navigationController?.pushViewController(tagObject, animated: true)
                }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
@available(iOS 14.0, *)
extension SearchViewController : UITextFieldDelegate {
   func textFieldDidBeginEditing(_ textField: UITextField) {
    self.trailView.constant = 80;
    self.cnclBtn.isHidden = false

    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.trailView.constant = 20;
        self.cnclBtn.isHidden = true

    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // return NO to not change text
        let maxLength = 150
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
            }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.serviceisInCall = false;
        self.itemArray.removeAllObjects()
        self.tbView.reloadData()
        self.getAllVideosDetailsFromTag()
        return true
    }
    
}
@available(iOS 14.0, *)
extension SearchViewController : SLDiscoverTableViewCellDelegate {
    func itemPickerModelDidClicked(_ infoArray: [Any]!, withClick index: Int) {
    let playerClass = PlaylistViewController.init(nibName: "PlaylistViewController", bundle: Bundle.main)
        playerClass.isFromUser = true;
                let mutArra:NSMutableArray =  NSMutableArray.init(array: infoArray)
        playerClass.oldDataArray = mutArra
        playerClass.clickedItemIndex = index
        playerClass.tagString = "";
        self.navigationController?.pushViewController(playerClass, animated: true)
        }
    
    func itemPickerModelDidViewMoreClicked(_ model: [AnyHashable : Any]!) {
        if let dict = model as NSDictionary?
              {
                if let tagTitle = dict.value(forKey: "tagTitle") as? String {
                    let tagObject = TagListViewController(nibName: "TagListViewController", bundle: nil)
                    tagObject.tagString = tagTitle;
                    self.navigationController?.pushViewController(tagObject, animated: true)
                }
        }
    }
    
    
}
@available(iOS 14.0, *)
extension SearchViewController {
//    func RSAAlgo() {
//        let path = Bundle.main.path(forResource: "public", ofType: "txt") // file path for file "data.txt"
//
//         let string =  try?String(contentsOfFile: path!, encoding: String.Encoding.utf8)
//
//        let publicKey = (try? PublicKey(pemNamed: string))!
//
//        let clear = try? ClearMessage(string: "Clear Text", using: .utf8)
//        let encrypted = try? clear?.encrypted(with: publicKey, padding: .PKCS1)
//
//        // Then you can use:
//        let data = encrypted?.data
//        let base64String = encrypted?.base64String
//        print(base64String)
//    }
}
