//
//  UIViewController+Spinner.swift
//  Gitcoin
//
//  Created by John Brunelle on 4/22/18.
//  Copyright © 2018 Gitcoin. All rights reserved.
//

import UIKit

extension UIViewController{
    
    func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100.0, height: 100.0))
        let screen = UIScreen.main.bounds
        let heightOffset:CGFloat = 0.0
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.layer.cornerRadius = 05
        activityIndicator.isOpaque = false
        activityIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        UIApplication.shared.keyWindow?.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: screen.width / 2, y: (screen.height / 2) + heightOffset)
        
        return activityIndicator
    }
}
