//
//  TrackingManager.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 12/2/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import Octokit
import Crashlytics
import Mixpanel
import Pushwoosh

enum GitcoinEvent {
    case didLoadAuthenticatedUser(user: User)
    case didSignIn(user: User)
    case didSignOut
    case didViewBounty(bounty: Bounty)
    case didTapBounty(bounty: Bounty)
    case didSwipeBounty(bounty: Bounty, direction: String, user: User?)
    case didViewEndOfBounties
    
    case didViewProfile
    case didCloseProfile
    case didEditKeywords(user: User?, action: String, keyword: String, keywords: [Any]?)
    case didViewInfo
    case didCloseInfo
    case didTapJoinSlack
    
    case didTapRefreshBounties
    case didBountyCountChange(count: Int)
    case didBackgroundBountyFetch(hasBounties: Bool)
    
    case didPlayWhatIsGitCoinVideo
    
    case didError(title: String, error: Error)
}

enum GitcoinState {
    case isSignedIn
    case isSignedOut
}

class TrackingManager {
    static let shared = TrackingManager()
    
    func trackEvent(_ event: GitcoinEvent) {
        DispatchQueue.global(qos: .background).async {
            switch event {
            case .didLoadAuthenticatedUser(let user):
                
                Answers.logLogin(withMethod: "github", success: 1, customAttributes: user.dictionaryWithAllValues())
                
                Mixpanel.mainInstance().track(event: "didLoadAuthenticatedUser", properties: user.dictionaryWithAllValues() as? Properties)
                
                PWInAppManager.shared().setUserId(user.email)
                
                PushNotificationManager.push().setTags(user.dictionaryWithAllValues())
                
            case .didSignIn(let user):
                
                Answers.logCustomEvent(withName: "didSignIn", customAttributes: user.dictionaryWithAllValues())
                Mixpanel.mainInstance().track(event: "didSignIn", properties: user.dictionaryWithAllValues() as? Properties)
                
                PWInAppManager.shared().postEvent("didSignIn")
                
            case .didSignOut:
                
                Answers.logCustomEvent(withName: "didCloseInfo")
                Mixpanel.mainInstance().track(event: "didCloseInfo")
                PWInAppManager.shared().postEvent("didCloseInfo")
                
                PWInAppManager.shared().setUserId(nil)
                
            case .didViewBounty(let bounty):
                
                Answers.logCustomEvent(withName: "didViewBounty", customAttributes: bounty.dictionaryForTracking())
                Mixpanel.mainInstance().track(event: "didViewBounty", properties: bounty.dictionaryForTracking() as? Properties)
                
                PWInAppManager.shared().postEvent("didViewBounty", withAttributes: bounty.dictionaryForTracking())
                
            case .didTapBounty(let bounty):
                
                Answers.logCustomEvent(withName: "didTapBounty", customAttributes: bounty.dictionaryForTracking())
                Mixpanel.mainInstance().track(event: "didTapBounty", properties: bounty.dictionaryForTracking() as? Properties)
                PWInAppManager.shared().postEvent("didTapBounty", withAttributes: bounty.dictionaryForTracking())
                
            case .didSwipeBounty(let bounty, let direction, let user):
                
                var customAttributes = ["direction": direction]
                
                for bountyField in bounty.dictionaryForTracking() {
                    
                    if let bountyFieldValue = bountyField.value as? String {
                        customAttributes["bounty-\(bountyField.key)"] = bountyFieldValue
                    }
                }
                
                if let userDictionary = user?.dictionaryWithAllValues() {
                    for userField in  userDictionary {
                        
                        if let userFieldValue = userField.value as? String {
                            customAttributes["user-\(userField.key)"] = userFieldValue
                        }
                    }
                }
                
                Answers.logCustomEvent(withName: "didSwipeBounty", customAttributes: customAttributes)
                Mixpanel.mainInstance().track(event: "didSwipeBounty", properties: customAttributes)
                PWInAppManager.shared().postEvent("didSwipeBounty", withAttributes: customAttributes)
                
            case .didBountyCountChange(let count):
                
                PushNotificationManager.push().setTags(["bountyCount": count]) { _ in
                    logger.verbose("did setTag: bountyCount=\(count) to PushWoosh")
                }
                
            case .didViewProfile:
                
                Answers.logCustomEvent(withName: "didViewProfile")
                Mixpanel.mainInstance().track(event: "didViewProfile")
                PWInAppManager.shared().postEvent("didViewProfile")
                
            case .didCloseProfile:
                
                Answers.logCustomEvent(withName: "didCloseProfile")
                Mixpanel.mainInstance().track(event: "didCloseProfile")
                PWInAppManager.shared().postEvent("didCloseProfile")
                
            case .didPlayWhatIsGitCoinVideo:
                
                Answers.logCustomEvent(withName: "didPlayWhatIsGitCoinVideo")
                Mixpanel.mainInstance().track(event: "didPlayWhatIsGitCoinVideo")
                PWInAppManager.shared().postEvent("didPlayWhatIsGitCoinVideo")
                
            case .didEditKeywords(let user, let action, let keyword, let keywords):
                
                var customAttributes = ["action": action, "keyword": keyword]
            
                if let userDictionary = user?.dictionaryWithAllValues() {
                    for userField in  userDictionary {
                        
                        if let userFieldValue = userField.value as? String {
                            customAttributes["user-\(userField.key)"] = userFieldValue
                        }
                    }
                }
                
                Answers.logCustomEvent(withName: "didEditKeywords", customAttributes: customAttributes)
                Mixpanel.mainInstance().track(event: "didEditKeywords", properties: customAttributes)
                PWInAppManager.shared().postEvent("didEditKeywords", withAttributes: customAttributes)
                
                if let keywords = keywords {
                    PushNotificationManager.push().setTags(["keywords": keywords]) { _ in
                        logger.verbose("did setTag: Keywords=\(keywords) to PushWoosh")
                    }
                }
                
            case .didViewInfo:
                
                Answers.logCustomEvent(withName: "didViewInfo")
                Mixpanel.mainInstance().track(event: "didViewInfo")
                PWInAppManager.shared().postEvent("didViewInfo")
                
            case .didCloseInfo:
                
                Answers.logCustomEvent(withName: "didCloseInfo")
                Mixpanel.mainInstance().track(event: "didCloseInfo")
                PWInAppManager.shared().postEvent("didCloseInfo")
                
            case .didViewEndOfBounties:
                
                Answers.logCustomEvent(withName: "didViewEndOfBounties")
                Mixpanel.mainInstance().track(event: "didViewEndOfBounties")
                PWInAppManager.shared().postEvent("didViewEndOfBounties")
                
                PushNotificationManager.push().setTags(["lastSeenEndOfBountiesDate": Date().timeIntervalSince1970]) { _ in
                    logger.verbose("did setTag: Last See End of Bounties=\(Date()) to PushWoosh")
                }
                
            case .didBackgroundBountyFetch(let hasBounties):
                
                Answers.logCustomEvent(withName: "didBackgroundBountyFetch", customAttributes: ["hasBounties": hasBounties])
                
                Mixpanel.mainInstance().track(event: "didBackgroundBountyFetch", properties: ["hasBounties": hasBounties])
                
                PWInAppManager.shared().postEvent("didBackgroundBountyFetch", withAttributes: ["hasBounties": hasBounties]) { _ in
                    logger.verbose("did postEvent: didBackgroundBountyFetch hasBounties=\(hasBounties) to PushWoosh")
                }
                
                if hasBounties {
                    PWInAppManager.shared().postEvent("didFindBountiesInBackground") { _ in
                        logger.verbose("did postEvent: didFindBountiesInBackground to PushWoosh")
                    }
                }
            case .didTapJoinSlack:
                
                Answers.logCustomEvent(withName: "didTapJoinSlack")
                Mixpanel.mainInstance().track(event: "didTapJoinSlack")
                PWInAppManager.shared().postEvent("didTapJoinSlack")
                
            case .didTapRefreshBounties:
                
                Answers.logCustomEvent(withName: "didTapRefreshBounties")
                Mixpanel.mainInstance().track(event: "didTapRefreshBounties")
                PWInAppManager.shared().postEvent("didTapRefreshBounties")
                
            case .didError(let title, let error):
                
                Answers.logCustomEvent(withName: title, customAttributes: ["error": error.localizedDescription])
                Mixpanel.mainInstance().track(event: title, properties: ["error": error.localizedDescription])
                PWInAppManager.shared().postEvent(title, withAttributes: ["error": error.localizedDescription])
                
            }
        }
    }
    
    func trackState(_ state: GitcoinState) {
        DispatchQueue.global(qos: .background).async {
            switch state {
            case .isSignedIn:
                PushNotificationManager.push().setTags(["isSignedOut": false])
            case .isSignedOut:
                PushNotificationManager.push().setTags(["isSignedOut": true])
            }
        }
    }
}
