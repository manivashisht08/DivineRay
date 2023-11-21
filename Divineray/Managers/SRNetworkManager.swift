//
//  SRNetworkManager.swift
//  Divineray
//
//  Created by     on 08/06/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit
import Connectivity

class SRNetworkManager: NSObject {
    
    fileprivate let connectivity: Connectivity = Connectivity()
    
    private static let _sharedInstance = SRNetworkManager()
    public class func sharedInstance() -> SRNetworkManager {
        return _sharedInstance
    }
    private override init () {
        super.init()
        self.startNetworkMonitor();
    }
}

extension SRNetworkManager {
    
    func startNetworkMonitor() {
        let connectivityChanged: (Connectivity) -> Void = { [weak self] connectivity in
            self?.updateConnectionStatus(connectivity.status)
        }
        
        connectivity.whenConnected = connectivityChanged
        connectivity.whenDisconnected = connectivityChanged
        connectivity.startNotifier()
    }
    
    func stopNetworkMonitor() {
        connectivity.stopNotifier()
    }
    
    func updateConnectionStatus(_ status: Connectivity.Status) {
        switch status {
        case .connected:
            break
        case .connectedViaWiFi:
            break
        case .connectedViaWiFiWithoutInternet:
            break
        case .determining:
            break
        case .notConnected:
            break
        case .connectedViaCellular:
            break
        case .connectedViaCellularWithoutInternet:
            break

        case .connectedViaEthernet:
            break
        case .connectedViaEthernetWithoutInternet:
            break
        }
    }
    
    /*
     Utlity method for getting the network status
     */
    public func isNetworkReachible () -> Bool {
        return true;// self.connectivity.isConnected;
        
    }
}

extension SRNetworkManager {

    enum NetworkError:Error {
        case domainError
        case decodingError
        case badDominError
        case parsingError
    }
 
}
