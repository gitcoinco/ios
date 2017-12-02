//
//  GlobalConstants.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/7/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import SwiftyBeaver
import Moya

let logger = SwiftyBeaver.self

/// UserDefaultKeyConstants: All UserDefaults persisted key definitions
struct UserDefaultKeyConstants {
    static let lastViewedBountyId = DefaultsKey<Int?>("lastViewedBountyId")
    
    static let userKeywords = DefaultsKey<[String]>("userKeywords")
}

struct SafeConfiguration {
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
        
        return "https://gitcoin.co/api/v0.1/"
    }
    
    static var gitcoinApiUsername: String? {
        if let val = dictionaryValues?["gitcoinApiUsername"] as? String {
            return val
        }
        
        return nil
    }
    
    static var gitcoinApiPassword: String? {
        if let val = dictionaryValues?["gitcoinApiPassword"] as? String {
            return val
        }
        
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

extension UIColor {
    struct gitCoin {
        static let celestialWhite = UIColor(red: 23.0/255.0, green: 244.0/255.0, blue: 238.0/255.0, alpha: 1.0)
        static let starDustYellow = UIColor(red: 255.0/255.0, green: 206.0/255.0, blue: 8.0/255.0, alpha: 1.0)
        static let cosmicTeal = UIColor(red: 37.0/255.0, green: 232.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        static let darkCosmicTeal = UIColor(red: 15.0/255.0, green: 206.0/255.0, blue: 124.0/255.0, alpha: 1.0)
        static let milkyWayBlue = UIColor(red: 21.0/255.0, green: 0.0/255.0, blue: 62.0/255.0, alpha: 1.0)
        static let polarisBlue = UIColor(red: 62.0/255.0, green: 0.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        static let vinusPurple = UIColor(red: 142.0/255.0, green: 42.0/255.0, blue: 190.0/255.0, alpha: 1.0)
        static let regulusRed = UIColor(red: 249.0/255.0, green: 42.0/255.0, blue: 108.0/255.0, alpha: 1.0)
    }
}
