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
import SwiftyPlistManager
import Pushwoosh
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PushNotificationDelegate {

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
        
        //TODO: add GitcoinAPIConfiguration.plist and get working properly
        // need to find a new plist library as this one caches the values underneath and is hard to work with
        // SwiftyPlistManager was meant more for a dynamic persistance layer
        SwiftyPlistManager.shared.start(plistNames: ["SafeConfiguration", "GitcoinAPIConfiguration"], logging: false)
        
        // set custom delegate for push handling, in our case AppDelegate
        PushNotificationManager.push().delegate = self
        
        // set default Pushwoosh delegate for iOS10 foreground push handling
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = PushNotificationManager.push().notificationCenterDelegate
        }
        
        // track application open statistics
        PushNotificationManager.push().sendAppOpen()
        
        // register for push notifications!
        PushNotificationManager.push().registerForPushNotifications()
        
        return false
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationManager.push().handlePushRegistration(deviceToken as Data!)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushNotificationManager.push().handlePushRegistrationFailure(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PushNotificationManager.push().handlePushReceived(userInfo)
        completionHandler(UIBackgroundFetchResult.noData)
    }

    // this event is fired when the push is received in the app
    func onPushReceived(_ pushManager: PushNotificationManager!, withNotification pushNotification: [AnyHashable : Any]!, onStart: Bool) {
        print("Push notification received: \(pushNotification)")
        // shows a push is received. Implement passive reaction to a push, such as UI update or data download.
    }
    
    // this event is fired when user clicks on notification
    func onPushAccepted(_ pushManager: PushNotificationManager!, withNotification pushNotification: [AnyHashable : Any]!, onStart: Bool) {
        print("Push notification accepted: \(pushNotification)")
        // shows a user tapped the notification. Implement user interaction, such as showing push details
    }
    
    fileprivate func setupLogger(){
        let console = ConsoleDestination()
        
        console.minLevel = .verbose
    
        logger.addDestination(console)
    }
}
