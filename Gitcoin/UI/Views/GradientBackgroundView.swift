//
//  GradientBackgroundView.swift
//  Gitcoin
//
//  Created by Craig Heneveld on 12/9/17.
//  Copyright © 2017 Gitcoin. All rights reserved.
//

import UIKit

@IBDesignable
class GradientBackgroundView: UIView {

    @IBInspectable var topColor: UIColor = .clear {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var bottomColor: UIColor = .clear {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    func updateView(){
        let layer = self.layer as! CAGradientLayer
        
        layer.colors = [topColor.cgColor, bottomColor.cgColor]
    }
}
