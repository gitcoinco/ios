//
//  ProfileSignedOutViewController.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 12/10/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileSignedOutViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        observeUI()
    }
    
    func observeUI(){

        let signInButtonSubscription = signInButton.rx.tap.bind {
            let url = OctokitManager.shared.oAuthConfig.authenticate()
            
            UIApplication.shared.open(url!, options: [:], completionHandler: { _ in
                
            })

            return
        }

        disposeBag.insert(signInButtonSubscription)
    }
}
