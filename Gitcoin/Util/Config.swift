//
//  Config.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 12/3/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit

struct Config {
    private static var dictionaryValues: [String: Any]? {
        get {
            if let fileUrl = Bundle.main.url(forResource: "SafeConfiguration", withExtension: "plist"),
                let data = try? Data(contentsOf: fileUrl) {
                if let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
                    return result
                }
            }
            
            return nil
        }
    }
    
    static var gitHubOAuthToken: String? {
        get {
            if let gitHubOAuthToken = dictionaryValues?["gitHubOAuthToken"] as? String {
                return gitHubOAuthToken
            }
            
            return nil
        }
    }
    
    static var gitHubOAuthSecret: String? {
        get {
            if let val = dictionaryValues?["gitHubOAuthSecret"] as? String {
                return val
            }
            
            return nil
        }
    }
    
    static var gitcoinApiBaseUrl: String {
        #if DEBUG
            if let val = dictionaryValues?["gitcoinApiBaseUrl"] as? String {
                return val
            }
        #endif
        
        return "https://gitcoin.co/"
        //return "https://stage.gitcoin.co/"
       // return "https://gitcoin.co/api/v0.1/"
        //return "https://origin.gitcoin.co/"
    }
    
    static var gitcoinApiUsername: String? {
        if let val = dictionaryValues?["gitcoinApiUsername"] as? String {
            return val
        }
        
        //return "gitcoin"
        return nil
    }
    
    static var gitcoinApiPassword: String? {
        if let val = dictionaryValues?["gitcoinApiPassword"] as? String {
            return val
        }
        
        //return "pushopensourceforward"
        return nil
    }
    
    static var enableGitcoinAPILogging: Bool {
        if let val = dictionaryValues?["enableGitcoinAPILogging"] as? Bool {
            return val
        }
        
        return false
    }
    
    /// MVP: pretend mode prevents the api from sending "New Match Alert" emails
    ///  when a user swipes right on a bounty
    
    static var enableGitcoinAPIPretendMode: Bool {

        // force to false if in RELEASE mode
        #if DEBUG
            if let val = dictionaryValues?["enableGitcoinAPIPretendMode"] as? Bool {
                return val
            }
            
            return true
        #else
            return false
        #endif
    }
}
