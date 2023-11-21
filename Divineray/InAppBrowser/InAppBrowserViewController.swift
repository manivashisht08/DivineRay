//
//  InAppBrowserViewController.swift
//  Divineray
//
//  Created by     on 16/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import WebKit

class InAppBrowserViewController: UIViewController {
    var optionFrom = 1;
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var link = URL(string:"https://divineray.io/PrivacyAndPolicy.html")!
        
        if optionFrom == 1 {
            link = URL(string:"https://divineray.io/PrivacyAndPolicy.html")!
        }
        else if optionFrom == 2 {
            link = URL(string:"https://divineray.io/TermsOfService.html")!
        }
        else if optionFrom == 3 {
            link = URL(string:"https://divineray.io")!
        }
        else if optionFrom == 4 {
            link = URL(string:"https://divineray.io")!
        }
        let request = URLRequest(url: link)
        
        webView.load(request)
        // Do any additional setup after loading the view.
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
                if self.optionFrom == 1 {
                    lblInfo.text = "Privacy Policy"
                }
                if self.optionFrom == 2 {
                                   lblInfo.text = "Terms of Use"

                               }
                if self.optionFrom == 3 {
                    lblInfo.text = "Contact Us"

                }
                if self.optionFrom == 4 {
                                   lblInfo.text = "About Us"

                               }
            }
            if let btnSetting = navigationBar.viewWithTag(12) as? UIButton {
                btnSetting.isHidden = true
            }
            
            if let backBtn = navigationBar.viewWithTag(13) as? UIButton {
                backBtn.isHidden = false
                backBtn.addTarget(self, action: #selector(backActionEdit), for: .touchUpInside)

            }
        }
    }
    func updatenavigationBarBack(){
           if let navigationBar = self.navigationController?.navigationBar {
               if let backBtn = navigationBar.viewWithTag(13) as? UIButton {
                   backBtn.removeTarget(self, action: #selector(backActionEdit), for: .touchUpInside)
               }
           }
       }
    @objc func backActionEdit() {
        self.navigationController?.popViewController(animated: true)
    }


}
