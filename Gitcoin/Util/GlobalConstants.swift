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
