//
//  GroupAcceptRequestVC.swift
//  Divineray
//
//  Created by dr mac on 03/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import UIKit

class GroupAcceptRequestVC: UIViewController {

    @IBOutlet weak var groupRequestTable: UITableView!
    @IBOutlet weak var nameLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
    }
    func setTableView(){
        self.groupRequestTable.delegate = self
        self.groupRequestTable.dataSource = self
        self.groupRequestTable.register(UINib(nibName: "GroupRequestTVCell", bundle: nil), forCellReuseIdentifier: "GroupRequestTVCell")
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    

}
extension GroupAcceptRequestVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupRequestTVCell", for: indexPath) as! GroupRequestTVCell
        cell.btnAccept.tag = indexPath.row
        cell.btnAccept.addTarget(self, action: #selector(acceptRequest(sender:)), for: .touchUpInside)
        cell.btnReject.tag = indexPath.row
        cell.btnReject.addTarget(self, action: #selector(rejecttRequest(sender:)), for: .touchUpInside)

        return cell
    }
    @objc func acceptRequest(sender:UIButton){
        
    }
    @objc func rejecttRequest(sender:UIButton){
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
