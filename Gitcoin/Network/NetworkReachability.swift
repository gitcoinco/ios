//
//  NetworkReachability.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 12/2/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import RxSwift

/// Listen for changes in the network
class NetworkReachability {
    
    static let shared = NetworkReachability()
    
    private let reachability = Reachability()!
    
    var isConnected = Variable<Bool>(true)
    
    init() {
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                logger.verbose("Reachable via WiFi")
            } else {
                logger.verbose("Reachable via Cellular")
            }
            
            self.isConnected.value = true
        }
        reachability.whenUnreachable = { _ in
            logger.verbose("Not reachable")
            
            self.isConnected.value = false
        }
    }
    
    func start(){
        do {
            try reachability.startNotifier()
        } catch {
            logger.error("Unable to start notifier")
        }
    }
    
    func stop(){
        reachability.stopNotifier()
    }
}
