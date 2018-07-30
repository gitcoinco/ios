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
        
        if let gitcoinApiUsername = Config.gitcoinApiUsername,
            let gitcoinApiPassword = Config.gitcoinApiPassword {
           
            if !gitcoinApiUsername.isEmpty && !gitcoinApiPassword.isEmpty {
                
                logger.debug("gitcoinAPI basic auth creds found.")
                
                plugins.append(CredentialsPlugin { _ -> URLCredential? in
                    return URLCredential(user: gitcoinApiUsername, password: gitcoinApiPassword, persistence: .forSession)
                })
            }
        }
        
        if Config.enableGitcoinAPILogging {
        
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
    
    // remove a bounty to the claimed list
    case removeClaimed(bounty: Bounty?)
    
    // list of claimed bouties for user
    case claimedList(username: String?)
    
    // After bounty swipes (left, right) X or ❤ we send event to api
    case fundingSave(bounty: Bounty?, user: User?, direction: String?)
    
    // Skills / Keywords
    case userKeywords(user: User)
    
    // get bounties list
    case bountyList(ids: String?)
    
}

// MARK: - TargetType Protocol Implementation
extension GitcoinAPIServiceContract: TargetType {
    var baseURL: URL {
        return URL(string: Config.gitcoinApiBaseUrl)!
    }
    
    var path: String {
        switch self {
        case .bounties:
            return "api/v0.1/bounties"
        case .removeClaimed(let bounty):
            return "actions/bounty/\(bounty?.idString ?? "")/interest/remove/"
        case .claimedList(_):
            return "actions/api/v0.1/bounties"
        case .fundingSave(_, _, _):
            return "api/v0.1/funding/save"
        case .userKeywords(let user):
            return "api/v0.1/profile/\(user.login ?? "")/keywords"
        case .bountyList(_):
            return "api/v0.1/bounties"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .bounties:
            return .get
        case .removeClaimed:
            return .post
        case .claimedList:
            return .get
        case .fundingSave:
            return .post
        case .userKeywords:
            return .get
        case .bountyList:
            return .get
        }
    }
    var task: Task {
        switch self {
        case let .fundingSave(bounty, user, direction):
            let params = ["token": OctokitManager.shared.tokenConfiguration?.accessToken ?? "","bounty_id": bounty?.idString ?? "", "email_address": user?.email ?? "", "direction":  direction ?? "", "github_username": user?.login ?? ""]
            
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .removeClaimed(_):
            
            let params = ["token": OctokitManager.shared.tokenConfiguration?.accessToken ?? ""]
            
            return .requestParameters(parameters: params, encoding:  URLEncoding.queryString)
            
        case let .claimedList(username):
            
            let params = ["started": username ?? ""]

            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
            
        case let .bounties(lastViewedBountyId, userKeywords):
            var params = ["idx_status": "open", "network": "mainnet", "order_by": "pk"]
            
            if let lastViewedBountyId = lastViewedBountyId {
                params["pk__gt"] = String(lastViewedBountyId)
            }
            
            // Filter data by user keywords/skills
            if let userKeywords = userKeywords, userKeywords.count > 0  {
                 params["raw_data"] = userKeywords.joined(separator: ",")
            }
            
            // When pretend=1 the api won't send emails to connect user to repo owners
            if Config.enableGitcoinAPIPretendMode {
                params["pretend"] = "1"
            }

            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
            
        case let .bountyList(ids):
            
            let params = ["standard_bounties_id__in": ids ?? "", "network": "mainnet"]
            
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
        case .removeClaimed:
            return "[]".utf8Encoded
        case .claimedList:
            return "[]".utf8Encoded
        case .fundingSave:
            return "[]".utf8Encoded
        case .userKeywords:
            return "[]".utf8Encoded
        case .bountyList:
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
