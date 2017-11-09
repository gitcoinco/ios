//
//  Bounty.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/2/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import Foundation
import Mapper

struct Bounty: Mappable {
    
    let id: Int
    let title: String
    let avatarUrl: String?
    let githubUrl: String?
    
    var idString: String {
        return String(self.id)
    }
    
    init(map: Mapper) throws {
        try id = map.from("pk")
        try title = map.from("title")
        avatarUrl = map.optionalFrom("avatar_url") // Optional property
        githubUrl = map.optionalFrom("github_url") // Optional property
    }
}
