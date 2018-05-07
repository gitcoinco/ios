//
//  ProfileContainerViewController.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/15/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyUserDefaults
import Octokit

class ProfileContainerViewController: UIViewController {
    
    @IBOutlet weak var signedInContainerView: UIView!
    
    @IBOutlet weak var signedOutContainerView: UIView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if OctokitManager.shared.isSignedIn {
            showSignedInViews()
        }else{
            showSignedOutViews()
        }
        
        observeUser()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TrackingManager.shared.trackEvent(.didViewProfile)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        TrackingManager.shared.trackEvent(.didCloseProfile)
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
                if let _ = user {
                    self?.showSignedInViews()
                }else{
                    self?.showSignedOutViews()
                }
            })

        disposeBag.insert(subscription)
    }

    fileprivate func showSignedInViews() {
        signedOutContainerView.isHidden = true
        signedInContainerView.isHidden = false

        signedOutContainerView.alpha = 0
        UIView.animate(withDuration: 1.0) {
            self.signedOutContainerView.alpha = 1
        }

        signedInContainerView.alpha = 1.0
        UIView.animate(withDuration: 1.0) {
            self.signedOutContainerView.alpha = 0
        }
    }
    
    fileprivate func showSignedOutViews() {
        signedOutContainerView.isHidden = false
        signedInContainerView.isHidden = true

        signedOutContainerView.alpha = 1.0
        UIView.animate(withDuration: 1.0) {
            self.signedOutContainerView.alpha = 0
        }

        signedInContainerView.alpha = 0
        UIView.animate(withDuration: 1.0) {
            self.signedOutContainerView.alpha = 1.0
        }
    }
}
