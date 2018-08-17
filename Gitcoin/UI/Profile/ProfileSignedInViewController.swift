//
//  ProfileSignedInViewController.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 12/10/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import AlamofireImage
import SwiftyUserDefaults
import Octokit

class ProfileSignedInViewController: UIViewController {

    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var tagFieldViewContainer: UIView!

    let tagsField = GitCoinWSTagField()

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTagField()
        observeUI()
        observeUser()
        observeUserActions()
    }

    func observeUI() {

        let signedOutButtonSubscription = signOutButton.rx.tap.bind {
            OctokitManager.shared.signOut()

            return
        }

        disposeBag.insert(signedOutButtonSubscription)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))

        tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    /// Observe User Object: This subscription listens for changes in the user instance
    /// So this will be called anytime time OctokitManager.shared.user
    /// is changed.  There by updating the ui base on the state of that
    /// user object
    func observeUser() {

        let subscription = OctokitManager.shared.user.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in

                // User logged in
                if let user = user {

                    if let name = user.name {
                        self?.nameLabel.text = name
                    }

                    if let avatarUrl = user.avatarURL {

                        Alamofire.request(avatarUrl).responseImage { response in

                            if let image = response.result.value {
                                let circularImage = image.af_imageRoundedIntoCircle()

                                self?.avatarImage.image = circularImage
                            }
                        }
                    }
                }
            })

        disposeBag.insert(subscription)
    }

    /// Subscribe to user actions
    func observeUserActions() {

        let subscription = OctokitManager.shared
            .userActionSubject
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { userAction in

                // Reset the last view bounty when logging out
                switch userAction {
                case .signedIn(let user):
                    self.populateTagsFromApiKeywords(with: user)
                case .signedOut:
                    break
                }
            })

        disposeBag.insert(subscription)
    }

    fileprivate func setupTagField() {
        tagsField.delimiter = ""

        // Events
        tagsField.onDidAddTag = { _, tag in
            let keyword = tag.text.lowercased()

            if !Defaults[UserDefaultKeyConstants.userKeywords].contains(keyword) {
                Defaults[UserDefaultKeyConstants.userKeywords].append(keyword)

                logger.verbose("Persisted tag \(keyword) to defaults")

                TrackingManager.shared.trackEvent(.didEditKeywords(user: OctokitManager.shared.user.value, action: "added", keyword: keyword, keywords: Defaults[UserDefaultKeyConstants.userKeywords]))
            }
        }

        tagsField.onDidRemoveTag = { _, tag in
            let keyword = tag.text

            if let removeIndex = Defaults[UserDefaultKeyConstants.userKeywords].index(where: { $0 == keyword }) {
                Defaults[UserDefaultKeyConstants.userKeywords].remove(at: removeIndex)

                logger.verbose("Removed tag \(keyword)")

                TrackingManager.shared.trackEvent(.didEditKeywords(user: OctokitManager.shared.user.value, action: "removed", keyword: keyword, keywords: Defaults[UserDefaultKeyConstants.userKeywords]))
            }
        }

        tagsField.placeholder = "Enter a skill or keyword"
        tagsField.translatesAutoresizingMaskIntoConstraints = false
        tagFieldViewContainer.addSubview(tagsField)

        NSLayoutConstraint.activate([
            tagsField.topAnchor.constraint(equalTo: tagFieldViewContainer.topAnchor),
            tagsField.leadingAnchor.constraint(equalTo: tagFieldViewContainer.leadingAnchor),
            tagsField.trailingAnchor.constraint(equalTo: tagFieldViewContainer.trailingAnchor)
        ])

        tagsField.addTags(Defaults[UserDefaultKeyConstants.userKeywords])
    }

    func populateTagsFromApiKeywords(with user: User) {
        _ = GitcoinAPIService.shared.provider.rx
            .request(.userKeywords(user: user))
            .filterSuccessfulStatusCodes()
            .map(to: UserKeywordResult.self)
            .subscribeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] userKeywordResult in

                if let keywords = userKeywordResult.keywords {
                    for keyword in keywords {
                        self?.tagsField.addTag(keyword.lowercased())
                    }
                } else {

                }
                }, onError: { _ in

            })
    }
}
