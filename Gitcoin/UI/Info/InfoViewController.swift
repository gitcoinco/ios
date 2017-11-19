//
//  InfoViewController.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/15/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Crashlytics

class InfoViewController: UIViewController {
    @IBOutlet weak var doneButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        observeUI()
        
        Answers.logContentView(withName: "Info", contentType: "View", contentId: nil)
    }
    
    func observeUI(){
        
        let doneButtonSubscription = doneButton.rx.tap.bind {
            self.dismiss(animated: true, completion: {
                Answers.logCustomEvent(withName: "Info Done Button Tapped")
            })
        }
        
        disposeBag.insert(doneButtonSubscription)
    }
}
