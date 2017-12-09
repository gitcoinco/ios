//
//  ProfileViewController.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/15/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import AlamofireImage
import SwiftyUserDefaults
import Octokit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var signOutButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var tagFieldViewContainer: UIView!
    @IBOutlet weak var signedOutStateView: UIView!
    @IBOutlet weak var signedInStateView: UIView!
    
    @IBOutlet weak var signInButton: UIButton!
    
    let tagsField = GitCoinWSTagField()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTagField()
        
        if OctokitManager.shared.isSignedIn {
            showSignedInViews()
        }else{
            showSignedOutViews()
        }
        
        observeUI()
        
        observeUser()
        
        observeUserActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TrackingManager.shared.trackEvent(.didViewProfile)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        TrackingManager.shared.trackEvent(.didCloseProfile)
    }

    func observeUI(){
        
        let signedOutButtonSubscription = signOutButton.rx.tap.bind {
            OctokitManager.shared.signOut()
            
            return
        }
        
        disposeBag.insert(signedOutButtonSubscription)
        
        let signedInButtonSubscription = signInButton.rx.tap.bind {
            let url = OctokitManager.shared.oAuthConfig.authenticate()
            
            UIApplication.shared.open(url!, options: [:], completionHandler: { _ in
                
            })
        }
        
        disposeBag.insert(signedInButtonSubscription)
    }
    
    /// Observe User Object: This subscription listens for changes in the user instance
    /// So this will be called anytime time OctokitManager.shared.user
    /// is changed.  There by updating the ui base on the state of that
    /// user object
    func observeUser(){
        
        let subscription = OctokitManager.shared.user.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                
                // User logged in
                if let user = user {
                    self?.showSignedInViews()
                    
                    if let name = user.name {
                        self?.nameLabel.text = "Hi, \(name)"
                    }
                    
                    if let avatarUrl = user.avatarURL {
                        
                        Alamofire.request(avatarUrl).responseImage { response in
                            
                            if let image = response.result.value {
                                let circularImage = image.af_imageRoundedIntoCircle()
                                
                                self?.avatarImage.image = circularImage
                            }
                        }
                    }
                    // User logged out
                }else{
                    self?.showSignedOutViews()
                }
            })
        
        disposeBag.insert(subscription)
    }
    
    /// Subscribe to user actions
    func observeUserActions(){
        
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
        tagsField.delimiter = ","
        
        // Events
        tagsField.onDidAddTag = { _, tag in
            let keyword = tag.text.lowercased()
            
            if !Defaults[UserDefaultKeyConstants.userKeywords].contains(keyword) {
                Defaults[UserDefaultKeyConstants.userKeywords].append(keyword)
                
                logger.verbose("Persisted tag \(keyword) to defaults")
                
                TrackingManager.shared.trackEvent(.didEditKeywords(user: OctokitManager.shared.user.value, action: "added", keyword: keyword))
            }
        }
        
        tagsField.onDidRemoveTag = { _, tag in
            let keyword = tag.text
            
            if let removeIndex = Defaults[UserDefaultKeyConstants.userKeywords].index(where: { $0 == keyword }) {
                Defaults[UserDefaultKeyConstants.userKeywords].remove(at: removeIndex)
                
                logger.verbose("Removed tag \(keyword)")
                
                TrackingManager.shared.trackEvent(.didEditKeywords(user: OctokitManager.shared.user.value, action: "removed", keyword: keyword))
            }
        }
        
        tagsField.placeholder = "Enter a skill or keyword"
        tagsField.translatesAutoresizingMaskIntoConstraints = false
        tagFieldViewContainer.addSubview(tagsField)
        
        NSLayoutConstraint.activate([
            tagsField.topAnchor.constraint(equalTo: tagFieldViewContainer.topAnchor),
            tagsField.leadingAnchor.constraint(equalTo: tagFieldViewContainer.leadingAnchor),
            tagsField.trailingAnchor.constraint(equalTo: tagFieldViewContainer.trailingAnchor),
            
        ])
        
        tagsField.addTags(Defaults[UserDefaultKeyConstants.userKeywords])
    }
    
    func populateTagsFromApiKeywords(with user: User){
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
                }else{
                    
                }
                }, onError: { error in
                    
            })
    }
    
    fileprivate func showSignedInViews() {
        signedOutStateView.alpha = 0.0
        signedOutStateView.isHidden = true
        
        signedInStateView.alpha = 1.0
        signedInStateView.isHidden = false
    }
    
    fileprivate func showSignedOutViews() {
        signedOutStateView.alpha = 1.0
        signedOutStateView.isHidden = false
        
        signedInStateView.alpha = 0.0
        signedInStateView.isHidden = true
    }
}
