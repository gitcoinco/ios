//
//  AppDelegate.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 10/31/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import SCLAlertView
import SwiftyUserDefaults
import SwiftyBeaver
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Callback entry point during GitHub SSO
        // See OctokitManager for the observation of this default value
        OctokitManager.shared.oAuthConfig.handleOpenURL(url: url, completion: { (token) in
            OctokitManager.shared.tokenConfiguration = token
        })
        
        return false
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setupLogger()
        
        Fabric.with([Crashlytics.self])
        
        return false
    }
    
    fileprivate func setupLogger(){
        let console = ConsoleDestination()
        
        console.minLevel = .verbose
    
        logger.addDestination(console)
    }
}
