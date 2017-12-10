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
    case didEditKeywords(user: User?, action: String, keyword: String)
    case didViewInfo
    case didCloseInfo
    
    case didTapJoinSlack
    case didTapRefreshBounties
    
    case didError(title: String, error: Error)
}

class TrackingManager {
    static let shared = TrackingManager()
    
    func trackEvent(_ event: GitcoinEvent) {
        DispatchQueue.global(qos: .background).async {
            switch event {
            case .didLoadAuthenticatedUser(let user):
                
                Answers.logLogin(withMethod: "github", success: 1, customAttributes: user.dictionaryWithAllValues())
                
                Mixpanel.mainInstance().track(event: "didLoadAuthenticatedUser", properties: user.dictionaryWithAllValues() as? Properties)
            case .didSignIn(let user):
                
                Answers.logCustomEvent(withName: "didSignIn", customAttributes: user.dictionaryWithAllValues())
                Mixpanel.mainInstance().track(event: "didSignIn", properties: user.dictionaryWithAllValues() as? Properties)
                
                PWInAppManager.shared().postEvent("didSignIn")
                
            case .didSignOut:
                
                Answers.logCustomEvent(withName: "didCloseInfo")
                Mixpanel.mainInstance().track(event: "didCloseInfo")
                PWInAppManager.shared().postEvent("didCloseInfo")
                
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
            case .didViewProfile:
                
                Answers.logCustomEvent(withName: "didViewProfile")
                Mixpanel.mainInstance().track(event: "didViewProfile")
                PWInAppManager.shared().postEvent("didViewProfile")
            case .didCloseProfile:
                
                Answers.logCustomEvent(withName: "didCloseProfile")
                Mixpanel.mainInstance().track(event: "didCloseProfile")
                PWInAppManager.shared().postEvent("didCloseProfile")
            case .didEditKeywords(let user, let action, let keyword):
                
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
}
