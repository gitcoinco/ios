//
//  GitcoinAPIService.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/2/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import Moya

// API endpoint definitions https://github.com/Moya/Moya/blob/master/docs/Examples/Basic.md
enum GitcoinAPIService {
    case bounties
}

// MARK: - TargetType Protocol Implementation
extension GitcoinAPIService: TargetType {
    var baseURL: URL { return URL(string: "https://gitcoin.co/api/v0.1/")! }
    var path: String {
        switch self {
        case .bounties:
            return "bounties"
        }
    }
    var method: Moya.Method {
        switch self {
        case .bounties:
            return .get
        }
    }
    var task: Task {
        return .requestPlain
    }
    var sampleData: Data {
        switch self {
        case .bounties:
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
