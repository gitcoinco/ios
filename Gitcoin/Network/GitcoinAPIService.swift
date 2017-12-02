//
//  GitcoinAPIService.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/2/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import Moya
import Octokit

class GitcoinAPIService {
    static let shared = GitcoinAPIService()
    
    let provider: MoyaProvider<GitcoinAPIServiceContract>
    
    init() {
        
        var plugins: [PluginType] = []
        
        if let gitcoinApiUsername = SafeConfiguration.gitcoinApiUsername,
            let gitcoinApiPassword = SafeConfiguration.gitcoinApiPassword {
           
            if !gitcoinApiUsername.isEmpty && !gitcoinApiPassword.isEmpty {
                
                logger.debug("gitcoinAPI basic auth creds found.")
                
                plugins.append(CredentialsPlugin { _ -> URLCredential? in
                    return URLCredential(user: gitcoinApiUsername, password: gitcoinApiPassword, persistence: .forSession)
                })
            }
        }
        
        if SafeConfiguration.enableGitcoinAPILogging {
        
            logger.debug("gitcoinAPI logging on.")
            
            plugins.append(NetworkLoggerPlugin())
        }
        
        plugins.append(NetworkActivityPlugin(networkActivityClosure: { (type, target) in
            switch type {
            case .began:
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
            case .ended:
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }))
        
        self.provider = MoyaProvider<GitcoinAPIServiceContract>(plugins: plugins)
    }
    
}

/// GitcoinAPIService defines the endpoints and contract to the gitcoin api
// API endpoint definitions https://github.com/Moya/Moya/blob/master/docs/Examples/Basic.md
enum GitcoinAPIServiceContract {
    // Bounties index
    case bounties(lastViewedBountyId: Int?, userKeywords: [String]?)
    
    // After bounty swipes (left, right) X or ❤ we send event to api
    case fundingSave(bounty: Bounty?, user: User?, direction: String?)
    
    // Skills / Keywords
    case userKeywords(user: User)
}

// MARK: - TargetType Protocol Implementation
extension GitcoinAPIServiceContract: TargetType {
    var baseURL: URL {
        return URL(string: SafeConfiguration.gitcoinApiBaseUrl)!
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
        case let .bounties(lastViewedBountyId, userKeywords):
            var params = ["idx_status": "open", "order_by": "pk"]
            
            if let lastViewedBountyId = lastViewedBountyId {
                params["pk__gt"] = String(lastViewedBountyId)
            }
            
            // Filter data by user keywords/skills
            if let userKeywords = userKeywords, userKeywords.count > 0  {
                 params["raw_data"] = userKeywords.joined(separator: ",")
            }
            
            // When pretend=1 the api won't send emails to connect user to repo owners
            if SafeConfiguration.enableGitcoinAPIPretendMode {
                params["pretend"] = "1"
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
