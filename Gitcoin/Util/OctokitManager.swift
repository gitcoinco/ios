//
//  OctoKitManager.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/5/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import Foundation
import Octokit
import RxSwift
import SwiftyUserDefaults
import SCLAlertView
import SwiftyPlistManager

class OctokitManager: NSObject {
    static let shared = OctokitManager()
    
    enum UserAction {
        case signedIn
        case signedOut
    }
    
    /// userActionSubject will behave as a hot observable and emit actions
    /// subscribe to it to know what actions a user has taken
    let userActionSubject = PublishSubject<UserAction>()

    let oAuthConfig: OAuthConfiguration
    
    /// user will behave as a hot observable and emit the user object
    /// when ever it changes
    var user = Variable<User?>(nil)

    fileprivate let disposeBag = DisposeBag()
    
    var tokenConfiguration: TokenConfiguration? {
        get {
            let tokenKeyValue = Defaults[UserDefaultKeyConstants.githubAccessTokenKey]
            
            if let tokenKeyValue = tokenKeyValue {
                return TokenConfiguration(tokenKeyValue)
            }
            
            return nil
        }
        set(newTokenConfig) {
            
            //TODO: store these tokens somewhere safer
            // https://github.com/soffes/SAMKeychain?
            // https://github.com/kishikawakatsumi/UICKeyChainStore?
            if let newTokenConfig = newTokenConfig {
                Defaults[UserDefaultKeyConstants.githubAccessTokenKey] = newTokenConfig.accessToken
                
                userActionSubject.onNext(.signedIn)
                loadMe()
            }else{
                Defaults.remove(UserDefaultKeyConstants.githubAccessTokenKey)
                
                userActionSubject.onNext(.signedOut)
                unloadMe()
            }
        }
    }
    
    var isSignedIn : Bool {
        return tokenConfiguration != nil
    }
    
    override init() {
        guard let gitHubOAuthToken = SwiftyPlistManager.shared.fetchValue(for: "gitHubOAuthToken", fromPlistWithName: "SafeConfiguration") as? String else {
            fatalError("\n The SafeConfiguration.plist file can't be found. Please generate it with the following keys: gitHubOAuthToken, gitHubOAuthSecret")
        }
        
        guard let gitHubOAuthSecret = SwiftyPlistManager.shared.fetchValue(for: "gitHubOAuthSecret", fromPlistWithName: "SafeConfiguration") as? String else {
            fatalError("\n The SafeConfiguration.plist file can't be found. Please generate it with the following keys: gitHubOAuthToken, gitHubOAuthSecret")
        }
        
        self.oAuthConfig = OAuthConfiguration(token: gitHubOAuthToken, secret: gitHubOAuthSecret, scopes: ["repo", "read:org"])
        
        super.init()
        
        if isSignedIn {
            loadMe()
        }
    }
    
    func loadMe(){
        if let tokenConfig = tokenConfiguration {
            _ = Octokit(tokenConfig).me() { response in
                switch response {
                case .success(let user):
                    self.user.value = user
                case .failure(let error):
                    logger.error(error)
                }
            }
        }else{
            logger.warning("No tokenConfiguration found to get me()")
        }
    }
    
    func unloadMe(){
        self.user.value = nil
    }
    
    func signOut(){
        self.tokenConfiguration = nil
    }
}
