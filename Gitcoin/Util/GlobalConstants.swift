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
    static let githubAccessTokenKey = DefaultsKey<String?>("githubaccesstoken")
    
    static let lastViewedBountyId = DefaultsKey<Int?>("lastViewedBountyId")
    
    static let userKeywords = DefaultsKey<[String]>("userKeywords")
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
