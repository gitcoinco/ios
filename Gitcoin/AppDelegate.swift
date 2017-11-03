//
//  AppDelegate.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 10/31/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import Octokit
import SCLAlertView

let oAuthConfig = OAuthConfiguration(token: "e032164d070bfacd1dbe", secret: "0dc9460fabc08acd2ec2e12d3b2a83d909b34d06", scopes: ["repo", "read:org"])

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // After an oauth session has been authorized on github, the callback url will
        // enter here
        
        //TODO: persist the token! and move all this to a manager
        oAuthConfig.handleOpenURL(url: url, completion: { (token) in
            _ = Octokit(token).me() { response in
                switch response {
                case .success(let user):
                    print("User login: \(String(describing: user.email))")
                    
                    DispatchQueue.main.async {
                        SCLAlertView().showSuccess("Success", subTitle: "Your email is \(user.email!)", closeButtonTitle: "OK")
                    }
                    
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        })
        
        return false
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        
    }
    
//
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//        return false
//    }
//
//    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
//        return true
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

