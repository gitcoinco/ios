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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webviewSegue",
            let destination = segue.destination as? WebViewController {
            
            destination.title = "SIGN IN"
            
            destination.currentURL = OctokitManager.shared.oAuthConfig.authenticate()
        }
    }
    
    func observeUI(){

        let signInButtonSubscription = signInButton.rx.tap.bind {
            self.performSegue(withIdentifier: "webviewSegue", sender: nil)
        }

        disposeBag.insert(signInButtonSubscription)
    }
}
