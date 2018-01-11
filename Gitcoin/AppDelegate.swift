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
        
        Crashlytics.sharedInstance().setUserIdentifier(PushNotificationManager.push().getHWID())
        
        NetworkReachability.shared.start()
        
        //setup custom navigation bar
        let navigationBarAppearace = UINavigationBar.appearance()
        let image = #imageLiteral(resourceName: "nav-bar-bg")
        
        navigationBarAppearace.setBackgroundImage(image.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: .default)
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        return false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        NetworkReachability.shared.start()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
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
    
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        let lastViewedBountyId = Defaults[UserDefaultKeyConstants.lastViewedBountyId]
        let userKeywords = Defaults[UserDefaultKeyConstants.userKeywords]
        
        _ = GitcoinAPIService.shared.provider.rx.request(.bounties(lastViewedBountyId: lastViewedBountyId, userKeywords: userKeywords))
            .map(to: [Bounty].self)
            .subscribe { event in
                switch event {
                case .success(let repos):
                    
                    TrackingManager.shared.trackEvent(GitcoinEvent.didBackgroundBountyFetch(hasBounties: repos.count > 0))
                    TrackingManager.shared.trackEvent(GitcoinEvent.didBountyCountChange(count: repos.count))
                    completionHandler(UIBackgroundFetchResult.newData)
                    
                case .error(_):
                    
                    completionHandler(UIBackgroundFetchResult.failed)
                }
        }
    }
    
    fileprivate func setupLogger(){
        let console = ConsoleDestination()
        
        console.minLevel = .verbose
    
        logger.addDestination(console)
    }
}
