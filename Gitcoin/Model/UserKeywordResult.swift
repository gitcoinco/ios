//
//  UserKeywordResult.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/9/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import Foundation
import Mapper

struct UserKeywordResult: Mappable {

    let status: Int?
    let keywords: [String]?

    init(map: Mapper) throws {
        status = map.optionalFrom("status") // Optional property
        keywords = map.optionalFrom("keywords") // Optional property
    }
}
