//
//  OctoKitManager.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/5/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import Foundation
import Octokit
import RxSwift
import SwiftyUserDefaults
import Pushwoosh
import RequestKit

class OctokitManager: NSObject {
    static let shared = OctokitManager()

    static let keychainTokenKey = "githubaccesstoken"

    enum UserAction {
        case signedIn(User)
        case signedOut
    }

    /// userActionSubject will behave as a hot observable and emit actions
    /// subscribe to it to know what actions a user has taken
    let userActionSubject = PublishSubject<UserAction>()

    let oAuthConfig: OAuthConfiguration

    /// user will behave as a hot observable and emit the user object
    /// when ever it changes
    var user = Variable<User?>(nil)
    var comments = Variable<[Issue]?>(nil)

    fileprivate let disposeBag = DisposeBag()

    var tokenConfiguration: TokenConfiguration? {
        get {
            let tokenKeyValue =  KeychainSwift().get(OctokitManager.keychainTokenKey)

            if let tokenKeyValue = tokenKeyValue {
                return TokenConfiguration(tokenKeyValue)
            }

            return nil
        }
        set(newTokenConfig) {

            let keychain = KeychainSwift()

            if let newTokenConfig = newTokenConfig, let accessToken = newTokenConfig.accessToken {

                keychain.set(accessToken, forKey: OctokitManager.keychainTokenKey)

                loadMe(emitSignInAction: true)
            } else {
                keychain.delete(OctokitManager.keychainTokenKey)

                userActionSubject.onNext(.signedOut)
                unloadMe()
            }
        }
    }

    var isSignedIn: Bool {
        return tokenConfiguration != nil
    }

    var isSignedOut: Bool {
        return !isSignedIn
    }

    override init() {
        guard let gitHubOAuthToken = Config.gitHubOAuthToken else {
            fatalError("\n The SafeConfiguration.plist file can't be found. Please generate it with the following keys: gitHubOAuthToken, gitHubOAuthSecret")
        }

        guard let gitHubOAuthSecret = Config.gitHubOAuthSecret else {
            fatalError("\n The SafeConfiguration.plist file can't be found. Please generate it with the following keys: gitHubOAuthToken, gitHubOAuthSecret")
        }

        self.oAuthConfig = OAuthConfiguration(token: gitHubOAuthToken, secret: gitHubOAuthSecret, scopes: ["read:user", "read:org", "user:email", "public_repo", "write:discussion", "read:discussion"])

        super.init()

        if isSignedIn {
            loadMe()
        } else {
            TrackingManager.shared.trackState(.isSignedOut)
        }
    }

    fileprivate func loadMe(emitSignInAction: Bool = false) {
        if let tokenConfig = tokenConfiguration {
            _ = Octokit(tokenConfig).me { response in
                switch response {
                case .success(let user):
                    self.user.value = user

                    // so the useer email is grabbed on a different endpoint
                    _ = Octokit(tokenConfig).loadEmail { response in
                        switch response {
                        case .success(let email):

                            let user = self.user.value
                            user?.email = email
                            self.user.value = user

                        case .failure(let error):
                            logger.error(error)
                        }
                    }

                    TrackingManager.shared.trackState(.isSignedIn)

                    if emitSignInAction {
                        self.userActionSubject.onNext(.signedIn(user))
                        TrackingManager.shared.trackEvent(.didSignIn(user: user))
                    }

                    TrackingManager.shared.trackEvent(.didLoadAuthenticatedUser(user:user))
                case .failure(let error):
                    logger.error(error)
                }
            }
        } else {
            logger.warning("No tokenConfiguration found to get me()")
        }
    }

    func issueComments(issueId: Int?, repoName: String?, orgName: String?) {

        if let tokenConfig = tokenConfiguration, let issueId = issueId, let repoName = repoName, let orgName = orgName {

            let (owner, repo, number) = (orgName, repoName, issueId)

            _ = Octokit(tokenConfig).comments(owner: owner, repository: repo, number: number) { response in
                switch response {
                case .success(let comments):

                    self.comments.value = comments

                case .failure(let error):

                    logger.error(error)
                }
            }
        }
    }

    func addComment(issueId: Int?, repoName: String?, orgName: String?, comment: String?) {

        if let tokenConfig = tokenConfiguration, let issueId = issueId, let repoName = repoName, let orgName = orgName {

            let (owner, repo, number) = (orgName, repoName, issueId)

            _ = Octokit(tokenConfig).addComment(owner: owner, repository: repo, number: number, comment: comment) { response in
                switch response {
                case .success(let response):
                  print(response)

                case .failure(let error):
                    logger.error(error)
                }
            }
        }
    }

    func deleteComment(commentId: Int?, repoName: String?, orgName: String?) {

        if let tokenConfig = tokenConfiguration, let commentId = commentId, let repoName = repoName, let orgName = orgName {

            let (owner, repo, number) = (orgName, repoName, commentId)

            _ = Octokit(tokenConfig).deleteComment(owner: owner, repository: repo, number: number) { response in
                switch response {
                case .success(let response):
                    print(response)

                case .failure(let error):
                    logger.error(error)
                }
            }
        }
    }

    func unloadMe() {
        self.user.value = nil
    }

    func signOut() {
        TrackingManager.shared.trackEvent(.didSignOut)
        self.tokenConfiguration = nil
        TrackingManager.shared.trackState(.isSignedOut)
    }
}

extension User {
    func dictionaryWithAllValues() -> [String: Any] {
        return self.dictionaryWithValues(forKeys: ["id", "email", "login", "name", "location", "company"])
    }
}

extension Octokit {

    public func loadEmail(_ session: RequestKitURLSession = URLSession.shared, completion: @escaping (_ response: Response<String>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GitHubRouter.userEmail(configuration)

        return router.load(session, dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter), expectedResultType: [Email].self) { (emails, error) in

            if let error = error {
                print("error = \(error)")
                completion(Response.failure(error))
            } else {

                if let emails = emails {

                    if let email = emails.first?.email {
                        completion(Response.success(email))
                    } else {
                        completion(Response.success(""))
                    }
                } else {
                    completion(Response.success(""))
                }
            }

        }
    }

    public func comments(_ session: RequestKitURLSession = URLSession.shared, owner: String, repository: String, number: Int, completion: @escaping (_ response: Response<[Issue]>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GitHubRouter.readComments(configuration, owner, repository, number)

        return router.load(session, dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter), expectedResultType: [Issue].self, completion: { (comments, error) in
            if let error = error {
                completion(Response.failure(error))
            } else {
                if let comments = comments {

                    completion(Response.success(comments))
                }
            }
        })
    }

    public func addComment(_ session: RequestKitURLSession = URLSession.shared, owner: String, repository: String, number: Int, comment: String? = nil, completion: @escaping (_ response: Response<Issue>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GitHubRouter.addComment(configuration, owner, repository, number, comment)

        return router.postJSON(session, expectedResultType: Issue.self) { comment, error in

            if let error = error {
                completion(Response.failure(error))

            } else {
                if let comment = comment {

                    completion(Response.success(comment))
                }
            }
        }
    }

    public func deleteComment(_ session: RequestKitURLSession = URLSession.shared, owner: String, repository: String, number: Int, comment: String? = nil, completion: @escaping (_ response: Response<String>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GitHubRouter.deleteComment(configuration, owner, repository, number)

        return router.load(completion: { (error) in
            if let error = error {
                completion(Response.failure(error))

            } else {

                completion(Response.success("successfully deleted comment"))

            }
        })

    }
}

enum GitHubRouter: JSONPostRouter {

    case userEmail(Configuration)
    case readComments(Configuration, String, String, Int)
    case addComment(Configuration, String, String, Int, String?)
    case deleteComment(Configuration, String, String, Int)

    var method: HTTPMethod {
        switch self {
        case .addComment:
            return .POST
        case .deleteComment:
            return .DELETE
        default:
            return .GET
        }
    }

    var encoding: HTTPEncoding {
        switch self {
        case .addComment:
            return .json
        default:
            return .url
        }
    }

    var configuration: Configuration {
        switch self {
        case .readComments(let config, _, _, _): return config
        case .addComment(let config, _, _, _, _): return config
        case .deleteComment(let config, _, _, _): return config
        case .userEmail(let config): return config
        }
    }

    var params: [String: Any] {
        switch self {
        case .readComments:
            return [:]
        case .userEmail:
            return [:]
        case .deleteComment:
            return [:]
        case .addComment(_, _, _, _, let body):

            var params: [String: String] = [:]
            if let body = body {
                params["body"] = body
            }

            return params
        }
    }

    var path: String {
        switch self {
        case .userEmail:
            return "/user/emails"
        case .readComments(_, let owner, let repository, let number):
            return "repos/\(owner)/\(repository)/issues/\(number)/comments"
        case .deleteComment(_, let owner, let repository, let number):
            return "repos/\(owner)/\(repository)/issues/comments/\(number)"
        case .addComment(_, let owner, let repository, let number, _):
            return "repos/\(owner)/\(repository)/issues/\(number)/comments"
        }
    }
}

@objc class Email: NSObject, Codable {

    @objc var email: String?
    var primary: Bool?
    var verified: Bool?
    @objc var visibility: String?

    enum CodingKeys: String, CodingKey {
        case email
        case primary
        case verified
        case visibility
    }
}
