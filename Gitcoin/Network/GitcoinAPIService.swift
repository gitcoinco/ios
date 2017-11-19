//
//  GitcoinAPIService.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/2/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import Moya
import Octokit
import SwiftyPlistManager

class GitcoinAPIService {
    static let shared = GitcoinAPIService()
    
    let provider: MoyaProvider<GitcoinAPIServiceContract>
    
    init() {
        
        var plugins: [PluginType] = []
        
        if let gitcoinApiUsername = SwiftyPlistManager.shared.fetchValue(for: "gitcoinApiUsername", fromPlistWithName: "GitcoinAPIConfiguration") as? String,
            let gitcoinApiPassword = SwiftyPlistManager.shared.fetchValue(for: "gitcoinApiPassword", fromPlistWithName: "GitcoinAPIConfiguration") as? String {
           
            if !gitcoinApiUsername.isEmpty && !gitcoinApiPassword.isEmpty {
                
                logger.debug("gitcoinAPI basic auth creds found.")
                
                plugins.append(CredentialsPlugin { _ -> URLCredential? in
                    return URLCredential(user: gitcoinApiUsername, password: gitcoinApiPassword, persistence: .forSession)
                })
            }
        }
        
        if let gitcoinApiLogging = SwiftyPlistManager.shared.fetchValue(for: "gitcoinApiUsername", fromPlistWithName: "GitcoinAPIConfiguration") as? Bool,
            gitcoinApiLogging {
            
            logger.debug("gitcoinAPI logging on.")
            
            plugins.append(NetworkLoggerPlugin())
        }
        
        self.provider = MoyaProvider<GitcoinAPIServiceContract>(plugins: plugins)
    }
    
}

/// GitcoinAPIService defines the endpoints and contract to the gitcoin api
// API endpoint definitions https://github.com/Moya/Moya/blob/master/docs/Examples/Basic.md
enum GitcoinAPIServiceContract {
    // Bounties index
    case bounties(lastViewedBountyId: Int?)
    
    // After bounty swipes (left, right) X or ❤ we send event to api
    case fundingSave(bounty: Bounty?, user: User?, direction: String?)
    
    // Skills / Keywords
    case userKeywords(user: User)
}

// MARK: - TargetType Protocol Implementation
extension GitcoinAPIServiceContract: TargetType {
    var baseURL: URL {
        let gitcoinApiBaseUrl = SwiftyPlistManager.shared.fetchValue(for: "gitcoinApiBaseUrl", fromPlistWithName: "GitcoinAPIConfiguration") as? String ?? "https://gitcoin.co/api/v0.1/"
        
        return URL(string: gitcoinApiBaseUrl)!
    }
    var path: String {
        switch self {
        case .bounties:
            return "bounties"
        case .fundingSave(_, _, _):
            return "funding/save"
        case .userKeywords(let user):
            return "profile/\(user.login ?? "")/keywords"
        }
    }
    var method: Moya.Method {
        switch self {
        case .bounties:
            return .get
        case .fundingSave:
            return .post
        case .userKeywords:
            return .get
        }
    }
    var task: Task {
        switch self {
        case let .fundingSave(bounty, user, direction):
            let params = ["bounty_id": bounty?.idString ?? "", "email_address": user?.email ?? "", "direction":  direction ?? "", "github_username": user?.login ?? ""]
            
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .bounties(lastViewedBountyId):
            var params = ["idx_status": "open", "order_by": "pk"]
            
            if let lastViewedBountyId = lastViewedBountyId {
                params["pk__gt"] = String(lastViewedBountyId)
            }

            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }
    
    //TODO: build sample data
    var sampleData: Data {
        switch self {
        case .bounties:
            return "[]".utf8Encoded
        case .fundingSave:
            return "[]".utf8Encoded
        case .userKeywords:
            return "[]".utf8Encoded
        }
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
