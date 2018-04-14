//
//  GitCoinWSTagField.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 11/24/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit
import WSTagsField

class GitCoinWSTagField: WSTagsField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        internalInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalInit()
    }

    fileprivate func internalInit(){
        contentInset = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 10.0, right: 10.0)
        spaceBetweenTags = 10.0
        font = UIFont.robotoMediumFont(size: 12.0)
        tintColor = UIColor.gitCoin.midnightBlue
        textColor = .white
        fieldTextColor = .black
        selectedColor = UIColor.gitCoin.polarisBlue
        selectedTextColor = UIColor.gitCoin.celestialWhite
    }
}
