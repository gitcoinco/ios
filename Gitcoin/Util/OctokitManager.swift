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

class OctokitManager: NSObject {
    static let shared = OctokitManager()

    let oAuthConfig: OAuthConfiguration

    let disposeBag = DisposeBag()
    
    var user = Variable<User?>(nil)
    
    var tokenConfiguration: TokenConfiguration? {
        get {
            let tokenKeyValue = Defaults[UserDefaultKeyConstants.githubAccessTokenKey]
            
            if let tokenKeyValue = tokenKeyValue {
                return TokenConfiguration(tokenKeyValue)
            }
            
            return nil
        }
        set(newTokenConfig) {
            
            if let newTokenConfig = newTokenConfig {
                Defaults[UserDefaultKeyConstants.githubAccessTokenKey] = newTokenConfig.accessToken
                loadMe()
            }else{
                Defaults.remove(UserDefaultKeyConstants.githubAccessTokenKey)
                unloadMe()
            }
        }
    }
    
    var isSignedIn : Bool {
        return tokenConfiguration != nil
    }
    
    override init() {
        //TODO: move these configs more secure, and perhaps pass them in to init
        self.oAuthConfig = OAuthConfiguration(token: "e032164d070bfacd1dbe", secret: "0dc9460fabc08acd2ec2e12d3b2a83d909b34d06", scopes: ["repo", "read:org"])
        
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
                    
                    //TODO: move this UI stuff to a view controller 
//                    DispatchQueue.main.async {
//                        SCLAlertView().showSuccess("Success", subTitle: "Hi \(user.name!), you are signed in!", closeButtonTitle: "OK")
//                    }
                    
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
