//
//  SideMenuTableViewController.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/5/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import RxSwift

class SideMenuTableViewController: UITableViewController {

    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
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
            }else{
                self?.nameLabel.text = "Hi, Bounty Hunter"
                
                // TODO: persist these defaults in one place, right now its in storyboard
                self?.button.setTitle("Sign in",for: .normal)
            }
        }, onError: { error in
            // error
            print("error")
        }, onCompleted: {
            //completed
            print("completed")
        }) {
            // disposed
            print("disposed")
        }
        
        disposeBag.insert(subscription)
    }

    @IBAction func didTapButton() {
        
        if OctokitManager.shared.isSignedIn {
            
            OctokitManager.shared.signOut()
            
            return
        }
        
        let url = OctokitManager.shared.oAuthConfig.authenticate()
        
        UIApplication.shared.open(url!, options: [:], completionHandler: { _ in
            
        })
    }
}
