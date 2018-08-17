//
//  Fonts.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 12/9/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit

extension UIFont {
    class func futuraFont(size fontSize: CGFloat = 14.0) -> UIFont {
        return UIFont(name: "Futura", size: fontSize)!
    }

    class func robotoRegularFont(size fontSize: CGFloat = 14.0) -> UIFont {
        return UIFont(name: "Roboto-Regular", size: fontSize)!
    }

    class func robotoMediumFont(size fontSize: CGFloat = 14.0) -> UIFont {
        return UIFont(name: "Roboto-Medium", size: fontSize)!
    }
}
