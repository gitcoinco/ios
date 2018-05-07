//
//  BountyDiscussView.swift
//  Gitcoin
//
//  Created by John Brunelle on 3/4/18.
//  Copyright © 2018 Gitcoin. All rights reserved.
//

//import UIKit
//
//class BountyDiscussView: UIView {
//
//    let nibName = "BountyDiscussView"
//    var contentView: UIView?
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//
//        guard let view = loadViewFromNib() else { return }
//        view.frame = self.bounds
//        self.addSubview(view)
//        contentView = view
//    }
//
//    func loadViewFromNib() -> UIView? {
//        let bundle = Bundle(for: type(of: self))
//        let nib = UINib(nibName: nibName, bundle: bundle)
//        return nib.instantiate(withOwner: self, options: nil).first as? UIView
//    }
//
//
//    func populate(with bounty: Bounty?){
//
//        guard let bounty = bounty else { return }
//
//        print("2+++ \(bounty) ")
//    }
//
//}

