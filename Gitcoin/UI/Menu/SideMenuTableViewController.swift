//
//  SideMenuTableViewController.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/5/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire
import AlamofireImage
import Crashlytics

class SideMenuTableViewController: UITableViewController {

    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let subscription = OctokitManager.shared.user.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                if let user = user {
                    
                    if let name = user.name {
                        self?.nameLabel.text = "Hi, \(name)"
                    }
                    
                    self?.button.setTitle("Sign out",for: .normal)
                    
                    if let avatarUrl = user.avatarURL {
                        
                        Alamofire.request(avatarUrl).responseImage { response in
                            
                            if let image = response.result.value {
                                let circularImage = image.af_imageRoundedIntoCircle()
                                
                                self?.avatarImage.image = circularImage
                            }
                        }
                    }
                }else{
                    self?.nameLabel.text = "Hi, Bounty Hunter"
                    
                    // TODO: persist these defaults in one place, right now its in storyboard
                    self?.button.setTitle("Sign in",for: .normal)
                    
                    self?.avatarImage.image = #imageLiteral(resourceName: "guy1_black")
                }
        })
        
        disposeBag.insert(subscription)
    }

    @IBAction func didTapButton() {
        
        if OctokitManager.shared.isSignedIn {
            
            OctokitManager.shared.signOut()
            
            Answers.logCustomEvent(withName: "Logout")
            
            return
        }
        
        let url = OctokitManager.shared.oAuthConfig.authenticate()
        
        Answers.logCustomEvent(withName: "Login")
        
        UIApplication.shared.open(url!, options: [:], completionHandler: { _ in
            
        })
    }
}
