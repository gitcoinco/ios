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
import Pushwoosh

class OctokitManager: NSObject {
    static let shared = OctokitManager()
    
    static let keychainTokenKey = "githubaccesstoken"
    
    enum UserAction {
        case signedIn(User)
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
            let tokenKeyValue =  KeychainSwift().get(OctokitManager.keychainTokenKey)
            
            if let tokenKeyValue = tokenKeyValue {
                return TokenConfiguration(tokenKeyValue)
            }
            
            return nil
        }
        set(newTokenConfig) {
            
            let keychain = KeychainSwift()
            
            if let newTokenConfig = newTokenConfig, let accessToken = newTokenConfig.accessToken {
                
                keychain.set(accessToken, forKey: OctokitManager.keychainTokenKey)
                
                loadMe(emitSignInAction: true)
            }else{
                keychain.delete(OctokitManager.keychainTokenKey)
                
                userActionSubject.onNext(.signedOut)
                unloadMe()
            }
        }
    }
    
    var isSignedIn : Bool {
        return tokenConfiguration != nil
    }
    
    var isSignedOut : Bool {
        return !isSignedIn
    }
    
    override init() {
        guard let gitHubOAuthToken = Config.gitHubOAuthToken else {
            fatalError("\n The SafeConfiguration.plist file can't be found. Please generate it with the following keys: gitHubOAuthToken, gitHubOAuthSecret")
        }
        
        guard let gitHubOAuthSecret = Config.gitHubOAuthSecret else {
            fatalError("\n The SafeConfiguration.plist file can't be found. Please generate it with the following keys: gitHubOAuthToken, gitHubOAuthSecret")
        }
        
        self.oAuthConfig = OAuthConfiguration(token: gitHubOAuthToken, secret: gitHubOAuthSecret, scopes: ["read:user", "read:org", "user:email"])
        
        super.init()
        
        if isSignedIn {
            loadMe()
        }else{
            TrackingManager.shared.trackState(.isSignedOut)
        }
    }
    
    fileprivate func loadMe(emitSignInAction: Bool = false){
        if let tokenConfig = tokenConfiguration {
            _ = Octokit(tokenConfig).me() { response in
                switch response {
                case .success(let user):
                    self.user.value = user
                    
                    TrackingManager.shared.trackState(.isSignedIn)
                    
                    if emitSignInAction {
                        self.userActionSubject.onNext(.signedIn(user))
                        TrackingManager.shared.trackEvent(.didSignIn(user: user))
                    }
                    
                    TrackingManager.shared.trackEvent(.didLoadAuthenticatedUser(user:user))
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
        TrackingManager.shared.trackEvent(.didSignOut)
        self.tokenConfiguration = nil
        TrackingManager.shared.trackState(.isSignedOut)
    }
}

extension User {
    func dictionaryWithAllValues() -> [String : Any] {
        return self.dictionaryWithValues(forKeys: ["id", "email", "login", "name", "location", "company"])
    }
}
