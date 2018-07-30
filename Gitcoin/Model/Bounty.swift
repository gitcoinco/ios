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
    let standardBountiesId: Int
    
    let valueTrue: String?
    let tokenName: String?
    
    let status: String?
    let keywords: String?
    let bountyOwnerEmail: String?
    
    
    var keywordArray: [String]? {
        return keywords?.components(separatedBy: ",")
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            .filter({ $0.count > 0 })
    }
    
    let valueInUsdt: String?

    var usdtDisplayValue: String {
        if let valueInUsdt = valueInUsdt {
            return "\(valueInUsdt) USD"
        }
        
        return "- USD"
    }
    
    var tokenValueString: String? {
        var value = ""
        var token = ""
        
        if let v = valueTrue {
            value = String(describing: v)
        }
        
        if let t = tokenName {
            token = t
        }
        
        return "\(value) \(token)"
    }

    let bountyType: String?
    let projectLength: String?
    let organizationName: String?
    let ownerGithubUsername: String?
    
    var ownerGithubUrl: URL {
        return URL(string: "https://github.com/\(self.ownerGithubUsername)")!
    }
    
    let experienceLevel: String?
    
    let createdOn: Date?
    
    var createdAgo: String {
        if let createdOn = createdOn {
            return createdOn.toStringWithRelativeTime().capitalized
        }else{
            return "A while ago"
        }
    }
    
    let expiresOn: Date?
    
    var expiresIn: String {
        if let expiresOn = expiresOn {
            return expiresOn.toStringWithRelativeTime().capitalized
        }else{
            return "In a while"
        }
    }
    
    var idString: String {
        return String(self.id)
    }
    
    let descriptionText: String?
    
    let githubIssueNumber: Int?
    
    let githubOrgName: String?
    
    let githubRepoName: String?
    
    init(map: Mapper) throws {
        try id = map.from("pk")
        try title = map.from("title")
        try standardBountiesId = map.from("standard_bounties_id")
        avatarUrl = map.optionalFrom("avatar_url")
        githubUrl = map.optionalFrom("github_url")
        valueTrue = map.optionalFrom("value_true")
        tokenName = map.optionalFrom("token_name")
        valueInUsdt = map.optionalFrom("value_in_usdt")
        bountyType = map.optionalFrom("bounty_type")
        projectLength = map.optionalFrom("project_length")
        organizationName = map.optionalFrom("org_name")
        status = map.optionalFrom("status")
        bountyOwnerEmail = map.optionalFrom("bounty_owner_email")
        
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
        
        keywords = map.optionalFrom("keywords")
        descriptionText = map.optionalFrom("issue_description_text")
        githubIssueNumber = map.optionalFrom("github_issue_number")
        githubOrgName = map.optionalFrom("github_org_name")
        githubRepoName = map.optionalFrom("github_repo_name")

    }
    
    func dictionaryForTracking() -> [String:Any]{
        return ["id": self.idString, "title": self.title]
    }
}
