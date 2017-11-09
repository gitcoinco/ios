//
//  GitcoinAPIService.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/2/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import Moya
import Octokit

/// GitcoinAPIService defines the endpoints and contract to the gitcoin api
// API endpoint definitions https://github.com/Moya/Moya/blob/master/docs/Examples/Basic.md
enum GitcoinAPIService {
    // Bounties index
    case bounties(lastViewedBountyId: Int?)
    
    // After bounty swipes (left, right) X or ❤ we send event to api
    case fundingSave(bounty: Bounty?, user: User?, direction: String?)
}

// MARK: - TargetType Protocol Implementation
extension GitcoinAPIService: TargetType {
    var baseURL: URL { return URL(string: "https://gitcoin.co/api/v0.1/")! }
    var path: String {
        switch self {
        case .bounties:
            return "bounties"
        case .fundingSave(_, _, _):
            return "funding/save"
        }
    }
    var method: Moya.Method {
        switch self {
        case .bounties:
            return .get
        case .fundingSave:
            return .post
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
        }
    }
    var sampleData: Data {
        switch self {
        case .bounties:
            return "[]".utf8Encoded
        case .fundingSave:
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
