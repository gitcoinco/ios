//
//  BountyCardOverlayView.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 10/31/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import Koloda

class BountyCardOverlayView: OverlayView {

    let overlayRightImageName = "overlay_like"
    let overlayLeftImageName = "overlay_skip"

    @IBOutlet lazy var overlayImageView: UIImageView! = {
    [unowned self] in

        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)

        return imageView
    }()

    override var overlayState: SwipeResultDirection? {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageView.image = UIImage(named: overlayLeftImageName)
            case .right? :
                overlayImageView.image = UIImage(named: overlayRightImageName)
            default:
                overlayImageView.image = nil
            }
        }
    }
}
