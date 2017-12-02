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
    
    case didError(title: String, error: Error)
}

class TrackingManager {
    static let shared = TrackingManager()
    
    func trackEvent(_ event: GitcoinEvent) {
        switch event {
        case .didLoadAuthenticatedUser(let user):
            
            Answers.logLogin(withMethod: "github", success: 1, customAttributes: user.dictionaryWithAllValues())
            
            Mixpanel.mainInstance().track(event: "didLoadAuthenticatedUser", properties: user.dictionaryWithAllValues() as? Properties)
            
        case .didSignIn(let user):
            
            Answers.logCustomEvent(withName: "didSignIn", customAttributes: user.dictionaryWithAllValues())
            Mixpanel.mainInstance().track(event: "didSignIn", properties: user.dictionaryWithAllValues() as? Properties)
            
        case .didSignOut:
            
            Answers.logCustomEvent(withName: "didCloseInfo")
            Mixpanel.mainInstance().track(event: "didCloseInfo")
            
        case .didViewBounty(let bounty):
            
            Answers.logCustomEvent(withName: "didViewBounty", customAttributes: bounty.dictionaryForTracking())
            Mixpanel.mainInstance().track(event: "didViewBounty", properties: bounty.dictionaryForTracking() as? Properties)
            
        case .didTapBounty(let bounty):
            
            Answers.logCustomEvent(withName: "didTapBounty", customAttributes: bounty.dictionaryForTracking())
            Mixpanel.mainInstance().track(event: "didTapBounty", properties: bounty.dictionaryForTracking() as? Properties)
            
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
        case .didViewProfile:
            
            Answers.logCustomEvent(withName: "didViewProfile")
            Mixpanel.mainInstance().track(event: "didViewProfile")
        case .didCloseProfile:
            
            Answers.logCustomEvent(withName: "didCloseProfile")
            Mixpanel.mainInstance().track(event: "didCloseProfile")
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
            
        case .didViewInfo:
            
            Answers.logCustomEvent(withName: "didViewInfo")
            Answers.logCustomEvent(withName: "didViewInfo")
            
        case .didCloseInfo:
            
            Answers.logCustomEvent(withName: "didCloseInfo")
            Answers.logCustomEvent(withName: "didCloseInfo")
            
        case .didViewEndOfBounties:
            
            Answers.logCustomEvent(withName: "didViewEndOfBounties")
            Answers.logCustomEvent(withName: "didViewEndOfBounties")
            
        case .didError(let title, let error):
            
            Answers.logCustomEvent(withName: title, customAttributes: ["error": error.localizedDescription])
            Mixpanel.mainInstance().track(event: title, properties: ["error": error.localizedDescription])
            
        }
    }
}
