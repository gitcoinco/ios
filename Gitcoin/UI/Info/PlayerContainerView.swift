//
//  PlayerContainerView.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 12/14/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit

/// Since stack view's with fill proportionally distribution needs sub views
/// with an intrinsic content size, and uiviews dont have this we need this
/// container
class PlayerContainerView: UIView {
    override var intrinsicContentSize: CGSize {

        var height = 177.0

        if Device.IS_3_5_INCHES() {
            height = 100.0
        } else if Device.IS_4_INCHES() {
            height = 120.0
        } else if Device.IS_4_7_INCHES() {
            height = 150.0
        }

        return CGSize(width: 1.0, height: height)
    }
}
