//
//  Globals.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/7/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import SwiftyBeaver
import SCLAlertView

let logger = SwiftyBeaver.self

/// UserDefaultKeyConstants: All UserDefaults persisted key definitions
struct UserDefaultKeyConstants {
    static let lastViewedBountyId = DefaultsKey<Int?>("lastViewedBountyId")
    
    static let userKeywords = DefaultsKey<[String]>("userKeywords")
    
    static let seenSwipeRightBountyAlert = DefaultsKey<Bool>("seenSwipeRightBountyAlert")
}

func gitcoinAppearance(kDefaultShadowOpacity: CGFloat = 0.7,
                       kCircleTopPosition: CGFloat = -12.0,
                       kCircleBackgroundTopPosition: CGFloat = -15.0,
                       kCircleHeight: CGFloat = 56.0,
                       kCircleIconHeight: CGFloat = 20.0,
                       kTitleTop:CGFloat = 30.0,
                       kTitleHeight:CGFloat = 45.0,
                       kTextHeight: CGFloat = 90.0,
                       kTextFieldHeight: CGFloat = 50.0,
                       kTextViewdHeight: CGFloat = 80.0,
                       kButtonHeight: CGFloat = 50.0,
                       kTitleFont: UIFont = UIFont.futuraFont(size: 20.0),
                       kTextFont: UIFont = UIFont.robotoRegularFont(size: 14.0),
                       kButtonFont: UIFont = UIFont.futuraFont(size: 16.0),
                       showCloseButton: Bool = true,
                       showCircularIcon: Bool = true,
                       shouldAutoDismiss: Bool = true,
                       contentViewCornerRadius: CGFloat = 25.0,
                       fieldCornerRadius: CGFloat = 3.0,
                       buttonCornerRadius: CGFloat = 15.0,
                       hideWhenBackgroundViewIsTapped: Bool = false,
                       contentViewColor: UIColor = .white,
                       contentViewBorderColor: UIColor = .lightGray,
                       titleColor: UIColor = .darkText) -> SCLAlertView.SCLAppearance {
    
    let screenSize = UIScreen.main.bounds
    let screenWidth = screenSize.width
    
    let kWindowWidth = screenWidth*0.7866666667
    let kWindowHeight = kWindowWidth
    
    return SCLAlertView.SCLAppearance(kDefaultShadowOpacity: kDefaultShadowOpacity, kCircleTopPosition: kCircleTopPosition, kCircleBackgroundTopPosition: kCircleBackgroundTopPosition, kCircleHeight: kCircleHeight, kCircleIconHeight: kCircleIconHeight, kTitleTop: kTitleTop, kTitleHeight: kTitleHeight, kWindowWidth: kWindowWidth, kWindowHeight: kWindowHeight, kTextHeight: kTextHeight, kTextFieldHeight: kTextFieldHeight, kTextViewdHeight: kTextViewdHeight, kButtonHeight: kButtonHeight, kTitleFont: kTitleFont, kTextFont: kTextFont, kButtonFont: kButtonFont, showCloseButton: showCloseButton, showCircularIcon: showCircularIcon, shouldAutoDismiss: shouldAutoDismiss, contentViewCornerRadius: contentViewCornerRadius, fieldCornerRadius: fieldCornerRadius, buttonCornerRadius: buttonCornerRadius, hideWhenBackgroundViewIsTapped: hideWhenBackgroundViewIsTapped, contentViewColor: contentViewColor, contentViewBorderColor: contentViewBorderColor, titleColor: titleColor)
}
