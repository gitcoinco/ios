//
//  NavigationController.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 12/9/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import Whisper
import RxSwift

class NavigationController: UINavigationController {

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        observeNetwork()
    }

    func observeNetwork() {
        let networkSubscription = NetworkReachability.shared.isConnected
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { isConnected in

                if !isConnected {
                    let message = Message(title: "No Connection", backgroundColor: UIColor.gitCoin.regulusRed)

                    Whisper.show(whisper: message, to: self, action: .present)
                } else {
                    Whisper.hide(whisperFrom: self)
                }
            })

        disposeBag.insert(networkSubscription)
    }

}
