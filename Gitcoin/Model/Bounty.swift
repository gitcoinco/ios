//
//  Bounty.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/2/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import Foundation
import Mapper
import AFDateHelper

struct Bounty: Mappable {
    let id: Int
    let title: String
    let avatarUrl: String?
    let githubUrl: String?
    
    let valueTrue: Float?
    let tokenName: String?
    
    var tokenDisplayValue: String {
        if let valueTrue = valueTrue, let tokenName = tokenName {
            return "\(valueTrue) \(tokenName)"
        }
        
        return "-"
    }
    
    let valueInUsdt: Float?
    
    var usdtDisplayValue: String {
        if let valueInUsdt = valueInUsdt {
            return "\(valueInUsdt) USD"
        }
        
        return "-"
    }
    
    let bountyType: String?
    let projectLength: String?
    let organizationName: String?
    let ownerGithubUsername: String
    
    var ownerGithubUrl: URL {
        return URL(string: "https://github.com/\(self.ownerGithubUsername)")!
    }
    
    let experienceLevel: String?
    
    let createdOn: Date?
    
    var createdAgo: String {
        if let createdOn = createdOn {
            return createdOn.toStringWithRelativeTime()
        }else{
            return "A while ago"
        }
    }
    
    let expiresOn: Date?
    
    var expiresIn: String {
        if let expiresOn = expiresOn {
            return expiresOn.toStringWithRelativeTime()
        }else{
            return "In a while"
        }
    }
    
    var idString: String {
        return String(self.id)
    }
    
    init(map: Mapper) throws {
        try id = map.from("pk")
        try title = map.from("title")
        
        avatarUrl = map.optionalFrom("avatar_url")
        githubUrl = map.optionalFrom("github_url")
        valueTrue = map.optionalFrom("value_true")
        tokenName = map.optionalFrom("token_name")
        valueInUsdt = map.optionalFrom("value_in_usdt")
        bountyType = map.optionalFrom("bounty_type")
        projectLength = map.optionalFrom("project_length")
        organizationName = map.optionalFrom("org_name")
        
        try ownerGithubUsername = map.from("bounty_owner_github_username")
        
        experienceLevel = map.optionalFrom("experience_level")
        
        if let dateString: String = map.optionalFrom("web3_created") {
            createdOn = Date(fromString: dateString, format: .isoDateTimeSec)
        }else{
            createdOn = Date()
        }
        
        if let dateString: String = map.optionalFrom("expires_date") {
            expiresOn =  Date(fromString: dateString, format: .isoDateTimeSec)
        }else{
            expiresOn = Date()
        }
    }
}
