//
//  EndOfBountiesCardView.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/16/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import RxSwift

class EndOfBountiesCardView: UIView {

    @IBOutlet weak var joinSlackButton: UIButton!
    @IBOutlet weak var refreshBountiesButton: UIButton!

    let disposeBag = DisposeBag()

    var refreshBountiesClosure: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        observeUI()
    }

    /// Subscribe to actions on various ui/buttons
    func observeUI() {
        let joinSlackButtonSubscription = joinSlackButton.rx.tap.bind {

            UIApplication.shared.open(URL(string: "https://gitcoin.co/slack")!, options: [:], completionHandler: { _ in

                TrackingManager.shared.trackEvent(.didTapJoinSlack)
            })
        }

        disposeBag.insert(joinSlackButtonSubscription)

        let refreshBountiesButtonSubscription = refreshBountiesButton.rx.tap.bind {
            if let refreshBountiesClosure = self.refreshBountiesClosure {
                TrackingManager.shared.trackEvent(.didTapRefreshBounties)

                refreshBountiesClosure()
            }
        }

        disposeBag.insert(refreshBountiesButtonSubscription)
    }
}
