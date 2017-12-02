//
//  SideMenuTableViewController.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/5/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import AlamofireImage
import SwiftyUserDefaults
import SCLAlertView

class SideMenuTableViewController: UITableViewController {

    @IBOutlet weak var authButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var keywordSkillButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeUI()
        
        observeUser()
    }
    
    func observeUI(){
        
        let keywordButtonSubscription = keywordSkillButton.rx.tap.bind {
            
            if let user = OctokitManager.shared.user.value {
                _ = GitcoinAPIService.shared.provider.rx
                    .request(.userKeywords(user: user))
                    .filterSuccessfulStatusCodes()
                    .map(to: UserKeywordResult.self)
                    .subscribe(onSuccess: { userKeywordResult in
                        
                        if let keywords = userKeywordResult.keywords {
                            SCLAlertView().showInfo("Your Skills are...", subTitle: keywords.joined(separator: ","))
                        }else{
                            SCLAlertView().showWarning("You Got No Skills!??", subTitle: "")
                        }
                }, onError: { error in
                    
                })
            }else{
                SCLAlertView().showWarning("Gotta login yo", subTitle: "")
            }
        }
        
        disposeBag.insert(keywordButtonSubscription)
        
        let authButtonSubscription = authButton.rx.tap.bind {
            if OctokitManager.shared.isSignedIn {
                
                OctokitManager.shared.signOut()
                
                return
            }
            
            let url = OctokitManager.shared.oAuthConfig.authenticate()
            
            UIApplication.shared.open(url!, options: [:], completionHandler: { _ in
                
            })
        }
        
        disposeBag.insert(authButtonSubscription)
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
                    
                    if let name = user.name {
                        self?.nameLabel.text = "Hi, \(name)"
                    }
                    
                    self?.authButton.setTitle("Sign out",for: .normal)
                    
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
                    self?.nameLabel.text = "Hi, Bounty Hunter"
                    
                    // TODO: persist these defaults in one place, right now its in storyboard
                    self?.authButton.setTitle("Sign in",for: .normal)
                    
                    self?.avatarImage.image = #imageLiteral(resourceName: "guy1_black")
                }
            })
        
        disposeBag.insert(subscription)
    }
}
