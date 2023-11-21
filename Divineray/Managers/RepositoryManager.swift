//
//  RepositoryManager.swift
//  Divineray
//
//  Created by     on 08/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit

class RepositoryManager {
    static let shared = RepositoryManager()
    var userMobile = ""
    var userId = ""
    var Id = ""
    
    init() {
        self.syncroniseData()
    }
    
    func syncroniseData() {
        guard let userData = ApplicationStates.getUserData() else {
            return
        }
        self.userMobile = userData["mobileNo"] as? String ?? ""
        self.userId = userData["userId"] as? String ?? ""
        self.Id = userData["id"] as? String ?? ""
    }
}
