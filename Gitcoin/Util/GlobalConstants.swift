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

let logger = SwiftyBeaver.self

/// UserDefaultKeyConstants: All UserDefaults persisted key definitions
struct UserDefaultKeyConstants {
    static let githubAccessTokenKey = DefaultsKey<String?>("githubaccesstoken")
    
    static let lastBountyViewed = DefaultsKey<String?>("lastBountyViewed")
}
