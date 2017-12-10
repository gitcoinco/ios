//
//  AppDelegate.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 10/31/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import SwiftyBeaver
import Fabric
import Crashlytics
import Pushwoosh
import UserNotifications
import Mixpanel

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
        
        #if DEBUG
            logger.verbose("Launching app in DEBUG MODE")
            Mixpanel.initialize(token: "9c41aa33ab527580f8d07e31f252b9ad") // <- craig's dev token
        #else
            logger.verbose("Launching app in RELEASE MODE")
            Mixpanel.initialize(token: "ce3c7c698880b9c88f4201ead456a633") // <- gitcoin token
        #endif
        
        Fabric.with([Crashlytics.self])
        
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
        
        NetworkReachability.shared.start()
        
        //setup custom navigation bar
        let navigationBarAppearace = UINavigationBar.appearance()
        let image = #imageLiteral(resourceName: "nav-bar-bg")
        
        navigationBarAppearace.setBackgroundImage(image.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: .default)
        
        return false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        NetworkReachability.shared.start()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        NetworkReachability.shared.stop()
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
        logger.verbose("Push notification received: \(pushNotification)")
        // shows a push is received. Implement passive reaction to a push, such as UI update or data download.
    }
    
    // this event is fired when user clicks on notification
    func onPushAccepted(_ pushManager: PushNotificationManager!, withNotification pushNotification: [AnyHashable : Any]!, onStart: Bool) {
        logger.verbose("Push notification accepted: \(pushNotification)")
        // shows a user tapped the notification. Implement user interaction, such as showing push details
    }
    
    fileprivate func setupLogger(){
        let console = ConsoleDestination()
        
        console.minLevel = .verbose
    
        logger.addDestination(console)
    }
}
